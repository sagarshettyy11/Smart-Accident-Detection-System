import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sadar/screens/dashboard.dart';

// ─────────────────────────────────────────
// Color Constants
// ─────────────────────────────────────────
class _C {
  static const bg = Color(0xFF060E1D);
  static const bluePrimary = Color(0xFF1A56DB);
  static const blueLight = Color(0xFF3B82F6);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFF0F4FF);
  static const textSecondary = Color(0xFF8DA0C4);
  static const textMuted = Color(0xFF4A6080);
  static const cardBg = Color(0xB30F2347);
  static const border = Color(0x263B82F6);
}

// ─────────────────────────────────────────
// Contact Model
// ─────────────────────────────────────────
class _ContactEntry {
  final String id;
  String name;
  String relation;
  String phone;
  final String emoji;
  final Color color;
  int priority;
  bool notifyOnSOS;

  _ContactEntry({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
    required this.emoji,
    required this.color,
    required this.priority,
    this.notifyOnSOS = true,
  });
}

// ─────────────────────────────────────────
// Contacts Setup Screen  (Step 3 of 3)
// ─────────────────────────────────────────
class ContactsSetupScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onFinish;

  const ContactsSetupScreen({super.key, this.onBack, this.onFinish});

  @override
  State<ContactsSetupScreen> createState() => _ContactsSetupScreenState();
}

class _ContactsSetupScreenState extends State<ContactsSetupScreen>
    with TickerProviderStateMixin {
  bool _smsOnDetection = true;
  bool _autoCallP1 = true;
  bool _shareLiveLocation = false;
  bool _isLoading = false;

  late AnimationController _fadeCtrl;
  late List<Animation<double>> _anims;

  final List<_ContactEntry> _contacts = [
    _ContactEntry(
      id: 'c1',
      name: 'Sarah Ahmed',
      relation: 'Spouse · Primary Contact',
      phone: '+1 (555) 020-1110',
      emoji: '👩',
      color: Color(0xFFEF4444),
      priority: 1,
    ),
  ];

  final _avatarEmojis = [
    '👩',
    '👨',
    '👧',
    '👦',
    '👩‍⚕️',
    '👨‍⚕️',
    '👴',
    '👵',
    '🧑',
  ];
  final _avatarColors = [
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
  ];
  int _idCounter = 2;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anims = List.generate(9, (i) {
      final s = (i * 0.07).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _fadeCtrl,
        curve: Interval(s, (s + 0.4).clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Widget _fs(int i, Widget child) => FadeTransition(
    opacity: _anims[i],
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(_anims[i]),
      child: child,
    ),
  );

  Future<void> _handleFinish() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() => _isLoading = false);
      widget.onFinish?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: _Glow(color: _C.red, size: 240, opacity: 0.09),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: _Glow(color: _C.bluePrimary, size: 200, opacity: 0.1),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Fixed header ─────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: _fs(0, _buildTopBar()),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _fs(0, const _StepIndicator(currentStep: 3)),
                ),
                const SizedBox(height: 4),

                // ── Scrollable content ────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome
                        _fs(1, _buildWelcomeText()),
                        const SizedBox(height: 20),

                        // Auto dispatch
                        _fs(1, _buildSectionLabel('Auto Dispatch')),
                        const SizedBox(height: 10),
                        _fs(2, _buildSOSCard()),
                        const SizedBox(height: 20),

                        // Contacts
                        _fs(
                          2,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionLabel(
                                'Your Contacts (${_contacts.length})',
                              ),
                              GestureDetector(
                                onTap: () => _showAddContactSheet(context),
                                child: Text(
                                  '+ Add',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _C.blueLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Contact list
                        ..._contacts.asMap().entries.map(
                          (e) => _fs(
                            3 + (e.key % 3),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ContactCard(
                                contact: e.value,
                                onDelete: () =>
                                    setState(() => _contacts.remove(e.value)),
                                onNotifyToggle: (v) =>
                                    setState(() => e.value.notifyOnSOS = v),
                              ),
                            ),
                          ),
                        ),

                        // Add tile
                        _fs(4, _buildAddTile()),
                        const SizedBox(height: 20),

                        // Notification prefs
                        _fs(5, _buildSectionLabel('Notification Preferences')),
                        const SizedBox(height: 10),

                        _fs(
                          5,
                          _ToggleRow(
                            icon: Icons.notifications_active_rounded,
                            iconBg: _C.red.withValues(alpha: 0.1),
                            iconColor: _C.red,
                            title: 'SMS on Detection',
                            subtitle: 'Send text with GPS link to all contacts',
                            value: _smsOnDetection,
                            onChanged: (v) =>
                                setState(() => _smsOnDetection = v),
                          ),
                        ),
                        const SizedBox(height: 10),

                        _fs(
                          6,
                          _ToggleRow(
                            icon: Icons.call_rounded,
                            iconBg: _C.blueLight.withValues(alpha: 0.1),
                            iconColor: _C.blueLight,
                            title: 'Auto-Call P1 Contact',
                            subtitle: 'Calls primary contact immediately',
                            value: _autoCallP1,
                            onChanged: (v) => setState(() => _autoCallP1 = v),
                          ),
                        ),
                        const SizedBox(height: 10),

                        _fs(
                          6,
                          _ToggleRow(
                            icon: Icons.location_on_rounded,
                            iconBg: _C.green.withValues(alpha: 0.1),
                            iconColor: _C.green,
                            title: 'Share Live Location',
                            subtitle: 'Continuous GPS until help arrives',
                            value: _shareLiveLocation,
                            onChanged: (v) =>
                                setState(() => _shareLiveLocation = v),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Finish button
                        _fs(
                          7,
                          _FinishButton(
                            isLoading: _isLoading,
                            onTap: _handleFinish,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Add another link
                        _fs(
                          8,
                          GestureDetector(
                            onTap: () => _showAddContactSheet(context),
                            child: const Center(
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _C.textMuted,
                                  ),
                                  children: [
                                    TextSpan(text: 'Want more coverage? '),
                                    TextSpan(
                                      text: 'Add another contact',
                                      style: TextStyle(
                                        color: _C.blueLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ──────────────────────────────
  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onBack,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _C.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _C.textSecondary,
              size: 16,
            ),
          ),
        ),
        const Spacer(),
        const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _C.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _C.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.green.withValues(alpha: 0.3)),
          ),
          child: const Text(
            'Step 3 of 3',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _C.green,
            ),
          ),
        ),
      ],
    );
  }

  // ── Welcome text ─────────────────────────
  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Who to notify?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _C.textPrimary,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Add people to contact if an accident is detected.\nThey\'ll receive your GPS location instantly.',
          style: TextStyle(fontSize: 13, color: _C.textSecondary, height: 1.55),
        ),
      ],
    );
  }

  // ── SOS card ─────────────────────────────
  Widget _buildSOSCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _C.red.withValues(alpha: 0.09),
            _C.red.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.red.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _C.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🚑', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Services',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  '911 auto-dispatched on detection\nLocation sent automatically',
                  style: TextStyle(
                    fontSize: 11,
                    color: _C.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: _C.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _C.red.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'AUTO',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: _C.red,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Add contact tile ──────────────────────
  Widget _buildAddTile() {
    return GestureDetector(
      onTap: () => _showAddContactSheet(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _C.blueLight.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _C.bluePrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _C.blueLight.withValues(alpha: 0.25)),
              ),
              child: const Icon(
                Icons.person_add_rounded,
                color: _C.blueLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Emergency Contact',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.blueLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Recommended: at least 2–3 contacts',
                    style: TextStyle(fontSize: 11, color: _C.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _C.blueLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section label ─────────────────────────
  Widget _buildSectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: _C.textMuted,
      letterSpacing: 1.3,
    ),
  );

  // ── Add contact bottom sheet ──────────────
  void _showAddContactSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relCtrl = TextEditingController();
    // String selectedPriority = '${_contacts.length + 1}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF0A1628),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Add Emergency Contact',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              _SheetField(
                ctrl: nameCtrl,
                icon: Icons.person_outline_rounded,
                hint: 'Full Name',
              ),
              const SizedBox(height: 12),
              _SheetField(
                ctrl: phoneCtrl,
                icon: Icons.phone_outlined,
                hint: 'Phone Number',
                type: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _SheetField(
                ctrl: relCtrl,
                icon: Icons.group_outlined,
                hint: 'Relationship (e.g. Spouse)',
              ),
              const SizedBox(height: 20),

              // Save button
              GestureDetector(
                onTap: () {
                  if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                  final emoji =
                      _avatarEmojis[_idCounter % _avatarEmojis.length];
                  final color =
                      _avatarColors[_idCounter % _avatarColors.length];
                  setState(() {
                    _contacts.add(
                      _ContactEntry(
                        id: 'c${_idCounter++}',
                        name: nameCtrl.text,
                        relation: relCtrl.text.isNotEmpty
                            ? relCtrl.text
                            : 'Contact',
                        phone: phoneCtrl.text,
                        emoji: emoji,
                        color: color,
                        priority: _contacts.length + 1,
                      ),
                    );
                  });
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_C.bluePrimary, Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _C.bluePrimary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Save Contact',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════
// Reusable Widgets
// ═════════════════════════════════════════

class _Glow extends StatelessWidget {
  final Color color;
  final double size, opacity;
  const _Glow({required this.color, required this.size, required this.opacity});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          Colors.transparent,
        ],
      ),
    ),
  );
}

// Contact card
class _ContactCard extends StatelessWidget {
  final _ContactEntry contact;
  final VoidCallback onDelete;
  final ValueChanged<bool> onNotifyToggle;

  const _ContactCard({
    required this.contact,
    required this.onDelete,
    required this.onNotifyToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar + priority badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          contact.color,
                          contact.color.withValues(alpha: 0.65),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        contact.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: contact.color,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _C.bg, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          'P${contact.priority}',
                          style: const TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 13),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.relation,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _C.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      contact.phone,
                      style: TextStyle(
                        fontSize: 10,
                        color: _C.textMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              // Delete
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onDelete();
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _C.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.red.withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: _C.red,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Notify toggle strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: contact.notifyOnSOS ? _C.blueLight : _C.textMuted,
                  size: 15,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notify on SOS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: contact.notifyOnSOS
                          ? _C.textSecondary
                          : _C.textMuted,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onNotifyToggle(!contact.notifyOnSOS);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 22,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: contact.notifyOnSOS
                          ? _C.bluePrimary
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: contact.notifyOnSOS
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Toggle row
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: _C.textMuted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(!value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 44,
              height: 26,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: value
                    ? _C.bluePrimary
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Finish button (green gradient)
class _FinishButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _FinishButton({required this.isLoading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _C.green.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🚀', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 9),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const DashboardScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Finish Setup',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Sheet input field
class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final IconData icon;
  final String hint;
  final TextInputType type;

  const _SheetField({
    required this.ctrl,
    required this.icon,
    required this.hint,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    decoration: BoxDecoration(
      color: _C.cardBg,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: _C.border),
    ),
    child: Row(
      children: [
        const SizedBox(width: 14),
        Icon(icon, color: _C.textMuted, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: type,
            style: const TextStyle(fontSize: 13, color: _C.textPrimary),
            cursorColor: _C.blueLight,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: _C.textMuted),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    ),
  );
}

// 3-step indicator
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepDot(number: 1, label: 'Account', state: _s(1)),
        Expanded(child: _StepLine(state: _ls(1))),
        _StepDot(number: 2, label: 'Profile', state: _s(2)),
        Expanded(child: _StepLine(state: _ls(2))),
        _StepDot(number: 3, label: 'Contacts', state: _s(3)),
      ],
    );
  }

  _DS _s(int s) => s < currentStep
      ? _DS.done
      : s == currentStep
      ? _DS.active
      : _DS.inactive;
  _DS _ls(int s) => s < currentStep
      ? _DS.done
      : s == currentStep
      ? _DS.active
      : _DS.inactive;
}

enum _DS { active, done, inactive }

class _StepDot extends StatelessWidget {
  final int number;
  final String label;
  final _DS state;
  const _StepDot({
    required this.number,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: state == _DS.active
                ? _C.bluePrimary
                : state == _DS.done
                ? _C.green
                : _C.cardBg,
            shape: BoxShape.circle,
            border: state == _DS.inactive
                ? Border.all(color: _C.border, width: 1.5)
                : null,
          ),
          child: Center(
            child: state == _DS.done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: state == _DS.active ? Colors.white : _C.textMuted,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: state == _DS.active
                ? _C.blueLight
                : state == _DS.done
                ? _C.green
                : _C.textMuted,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final _DS state;
  const _StepLine({required this.state});
  @override
  Widget build(BuildContext context) => Container(
    height: 1.5,
    margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
    decoration: BoxDecoration(
      color: state == _DS.done
          ? _C.green.withValues(alpha: 0.5)
          : state == _DS.active
          ? _C.bluePrimary.withValues(alpha: 0.4)
          : _C.border,
      borderRadius: BorderRadius.circular(1),
    ),
  );
}
