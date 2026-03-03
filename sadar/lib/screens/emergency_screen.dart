import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────
// Color Constants
// ─────────────────────────────────────────
class _C {
  static const bg            = Color(0xFF060E1D);
  static const bluePrimary   = Color(0xFF1A56DB);
  static const blueLight     = Color(0xFF3B82F6);
  static const green         = Color(0xFF10B981);
  static const red           = Color(0xFFEF4444);
  static const amber         = Color(0xFFF59E0B);
  static const purple        = Color(0xFF8B5CF6);
  static const textPrimary   = Color(0xFFF0F4FF);
  static const textSecondary = Color(0xFF8DA0C4);
  static const textMuted     = Color(0xFF4A6080);
  static const cardBg        = Color(0xB30F2347);
  static const border        = Color(0x263B82F6);
}

// ─────────────────────────────────────────
// Contact Model
// ─────────────────────────────────────────
class EmergencyContact {
  final String name;
  final String relation;
  final String phone;
  final String emoji;
  final Color avatarColor;
  final int priority;
  final Color priorityColor;
  bool notifyOnSOS;

  EmergencyContact({
    required this.name,
    required this.relation,
    required this.phone,
    required this.emoji,
    required this.avatarColor,
    required this.priority,
    required this.priorityColor,
    this.notifyOnSOS = true,
  });
}

// ─────────────────────────────────────────
// Emergency Contacts Screen
// ─────────────────────────────────────────
class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen>
    with TickerProviderStateMixin {

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _autoNotifyAll = true;
  String _timeoutSetting = '2 minutes';

  late AnimationController _fadeCtrl;
  late List<Animation<double>> _anims;

  final List<EmergencyContact> _contacts = [
    EmergencyContact(
      name: 'Sarah Ahmed', relation: 'Spouse · Primary Contact',
      phone: '+1 (555) 020-1110', emoji: '👩',
      avatarColor: const Color(0xFFEF4444), priority: 1,
      priorityColor: _C.red,
    ),
    EmergencyContact(
      name: 'Dr. James R.', relation: 'Family Doctor',
      phone: '+1 (555) 030-2220', emoji: '👨',
      avatarColor: const Color(0xFFF59E0B), priority: 2,
      priorityColor: _C.amber,
    ),
    EmergencyContact(
      name: 'Michael Lee', relation: 'Neighbour · Nearby Responder',
      phone: '+1 (555) 040-3330', emoji: '👨‍⚕️',
      avatarColor: const Color(0xFF8B5CF6), priority: 3,
      priorityColor: _C.purple,
    ),
  ];

  List<EmergencyContact> get _filtered => _searchQuery.isEmpty
      ? _contacts
      : _contacts
          .where((c) =>
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.relation.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anims = List.generate(9, (i) {
      final s = (i * 0.07).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _fadeCtrl,
        curve: Interval(s, (s + 0.4).clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });
    _fadeCtrl.forward();
    _searchCtrl.addListener(() =>
        setState(() => _searchQuery = _searchCtrl.text));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _fs(int i, Widget child) => FadeTransition(
        opacity: _anims[i],
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.12), end: Offset.zero)
              .animate(_anims[i]),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(children: [
        // Ambient glows
        Positioned(top: -60, right: -60,
            child: _Glow(color: _C.red, size: 240, opacity: 0.09)),
        Positioned(bottom: 100, left: -60,
            child: _Glow(color: _C.bluePrimary, size: 200, opacity: 0.1)),

        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── Top bar ─────────────────
                    _fs(0, _buildTopBar()),
                    const SizedBox(height: 20),

                    // ── Search ──────────────────
                    _fs(1, _buildSearchBox()),
                    const SizedBox(height: 20),

                    // ── Auto Dispatch ────────────
                    _fs(2, _buildSectionLabel('Auto Dispatch')),
                    const SizedBox(height: 10),
                    _fs(2, _buildSOSCard()),
                    const SizedBox(height: 20),

                    // ── Contacts list ────────────
                    _fs(3, _buildSectionLabel(
                        'Priority Contacts (${_filtered.length})')),
                    const SizedBox(height: 10),

                    ..._filtered.asMap().entries.map((e) =>
                        _fs(4 + (e.key % 3), Column(children: [
                          _ContactCard(
                            contact: e.value,
                            onNotifyToggle: (v) => setState(
                                () => e.value.notifyOnSOS = v),
                            onDelete: () => setState(
                                () => _contacts.remove(e.value)),
                          ),
                          const SizedBox(height: 10),
                        ]))),

                    // Empty state
                    if (_filtered.isEmpty)
                      _fs(4, _buildEmptyState()),

                    // ── Add Contact ──────────────
                    const SizedBox(height: 4),
                    _fs(6, _buildAddContactTile()),
                    const SizedBox(height: 20),

                    // ── Alert Settings ───────────
                    _fs(7, _buildSectionLabel('Alert Settings')),
                    const SizedBox(height: 10),
                    _fs(7, _buildAlertSettings()),
                    const SizedBox(height: 20),

                    // ── SOS Info Banner ──────────
                    _fs(8, _buildSOSBanner()),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Top Bar ──────────────────────────────
  Widget _buildTopBar() {
    return Row(children: [
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Emergency Contacts',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                  letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text('${_contacts.length} contacts · Auto-notified on detection',
              style: const TextStyle(fontSize: 11, color: _C.textMuted)),
        ],
      )),
      GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _showAddContactSheet(context);
        },
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_C.bluePrimary, Color(0xFF2563EB)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: _C.bluePrimary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        ),
      ),
    ]);
  }

  // ── Search ───────────────────────────────
  Widget _buildSearchBox() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      child: Row(children: [
        const SizedBox(width: 14),
        Icon(Icons.search_rounded, color: _C.textMuted, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(fontSize: 13, color: _C.textPrimary),
            cursorColor: _C.blueLight,
            decoration: const InputDecoration(
              hintText: 'Search contacts...',
              hintStyle: TextStyle(fontSize: 13, color: _C.textMuted),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty)
          GestureDetector(
            onTap: () {
              _searchCtrl.clear();
              setState(() => _searchQuery = '');
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.close_rounded, color: _C.textMuted, size: 16),
            ),
          ),
      ]),
    );
  }

  // ── Section Label ────────────────────────
  Widget _buildSectionLabel(String label) => Text(label,
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _C.textMuted,
          letterSpacing: 1.2));

  // ── SOS Auto Dispatch Card ───────────────
  Widget _buildSOSCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          _C.red.withValues(alpha: 0.1),
          _C.red.withValues(alpha: 0.04),
        ]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.red.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: _C.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.red.withValues(alpha: 0.2)),
          ),
          child: const Center(child: Text('🚑', style: TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emergency Services',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 3),
            const Text('911 · Auto-dispatched on detection\nLocation sent automatically',
                style: TextStyle(
                    fontSize: 11, color: _C.textSecondary, height: 1.45)),
          ],
        )),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: _C.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _C.red.withValues(alpha: 0.3)),
          ),
          child: const Text('AUTO',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _C.red,
                  letterSpacing: 0.5)),
        ),
      ]),
    );
  }

  // ── Add Contact Tile ─────────────────────
  Widget _buildAddContactTile() {
    return GestureDetector(
      onTap: () => _showAddContactSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _C.blueLight.withValues(alpha: 0.3),
              style: BorderStyle.solid),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _C.bluePrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _C.blueLight.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.person_add_rounded,
                color: _C.blueLight, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Emergency Contact',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.blueLight)),
              const SizedBox(height: 2),
              Text('Recommended: 3–5 contacts',
                  style: TextStyle(fontSize: 11, color: _C.textMuted)),
            ],
          )),
          Icon(Icons.chevron_right_rounded, color: _C.blueLight, size: 20),
        ]),
      ),
    );
  }

  // ── Alert Settings ───────────────────────
  Widget _buildAlertSettings() {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        // Auto notify toggle
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _C.bluePrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bolt_rounded, color: _C.blueLight, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Auto-Notify All on SOS',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary)),
                const SizedBox(height: 2),
                Text('SMS + call in priority order',
                    style: TextStyle(fontSize: 10, color: _C.textMuted)),
              ],
            )),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _autoNotifyAll = !_autoNotifyAll);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 44, height: 26,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _autoNotifyAll ? _C.bluePrimary.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  alignment: _autoNotifyAll ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),

        Divider(height: 1, thickness: 1, color: Colors.white.withValues(alpha: 0.05)),

        // Timeout setting
        GestureDetector(
          onTap: () => _showTimeoutPicker(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _C.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.timer_outlined, color: _C.amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Response Timeout',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Escalate after $_timeoutSetting',
                      style: TextStyle(fontSize: 10, color: _C.textMuted)),
                ],
              )),
              Icon(Icons.chevron_right_rounded, color: _C.textMuted, size: 20),
            ]),
          ),
        ),

        Divider(height: 1, thickness: 1, color: Colors.white.withValues(alpha: 0.05)),

        // Notification method
        GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _C.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: _C.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notification Method',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary)),
                  const SizedBox(height: 2),
                  Text('SMS + Call + Push',
                      style: TextStyle(fontSize: 10, color: _C.textMuted)),
                ],
              )),
              Icon(Icons.chevron_right_rounded, color: _C.textMuted, size: 20),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── SOS Info Banner ──────────────────────
  Widget _buildSOSBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          _C.bluePrimary.withValues(alpha: 0.1),
          _C.bluePrimary.withValues(alpha: 0.04),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.blueLight.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Text('ℹ️', style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'All contacts are auto-notified with your real-time GPS location when an accident is detected.',
            style: TextStyle(
                fontSize: 11,
                color: _C.textSecondary,
                height: 1.5),
          ),
        ),
      ]),
    );
  }

  // ── Empty State ──────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(children: [
        Text('🔍', style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        const Text('No contacts found',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.textSecondary)),
        const SizedBox(height: 4),
        Text('Try a different search term',
            style: TextStyle(fontSize: 11, color: _C.textMuted)),
      ]),
    );
  }

  // ── Add Contact Bottom Sheet ─────────────
  void _showAddContactSheet(BuildContext context) {
    final nameCtrl  = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relCtrl   = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF0A1628),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('Add Contact',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const SizedBox(height: 20),
              _SheetField(ctrl: nameCtrl,  icon: Icons.person_outline_rounded, hint: 'Full Name'),
              const SizedBox(height: 12),
              _SheetField(ctrl: phoneCtrl, icon: Icons.phone_outlined,         hint: 'Phone Number', type: TextInputType.phone),
              const SizedBox(height: 12),
              _SheetField(ctrl: relCtrl,   icon: Icons.group_outlined,         hint: 'Relationship (e.g. Spouse)'),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                    setState(() {
                      _contacts.add(EmergencyContact(
                        name: nameCtrl.text,
                        relation: relCtrl.text.isNotEmpty ? relCtrl.text : 'Contact',
                        phone: phoneCtrl.text,
                        emoji: '👤',
                        avatarColor: _C.blueLight,
                        priority: _contacts.length + 1,
                        priorityColor: _C.blueLight,
                      ));
                    });
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                  }
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_C.bluePrimary, Color(0xFF2563EB)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: _C.bluePrimary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: const Center(
                    child: Text('Save Contact',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
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

  // ── Timeout Picker ───────────────────────
  void _showTimeoutPicker(BuildContext context) {
    final options = ['1 minute', '2 minutes', '3 minutes', '5 minutes'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0A1628),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text('Response Timeout',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 6),
            Text('Escalate to next contact if no response',
                style: TextStyle(fontSize: 12, color: _C.textMuted)),
            const SizedBox(height: 20),
            ...options.map((o) => GestureDetector(
                  onTap: () {
                    setState(() => _timeoutSetting = o);
                    Navigator.pop(context);
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _timeoutSetting == o
                          ? _C.bluePrimary.withValues(alpha: 0.12)
                          : _C.cardBg,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: _timeoutSetting == o
                            ? _C.bluePrimary.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(children: [
                      Text(o,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _timeoutSetting == o
                                  ? _C.blueLight
                                  : _C.textSecondary)),
                      const Spacer(),
                      if (_timeoutSetting == o)
                        Icon(Icons.check_circle_rounded,
                            color: _C.blueLight, size: 18),
                    ]),
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Contact Card Widget
// ─────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final ValueChanged<bool> onNotifyToggle;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.onNotifyToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        Row(children: [
          // Avatar
          Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [contact.avatarColor, contact.avatarColor.withValues(alpha: 0.65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(contact.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            Positioned(
              top: -4, right: -4,
              child: Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  color: contact.priorityColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _C.bg, width: 1.5),
                ),
                child: Center(
                  child: Text('P${contact.priority}',
                      style: const TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
            ),
          ]),
          const SizedBox(width: 13),

          // Info
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const SizedBox(height: 2),
              Text(contact.relation,
                  style: const TextStyle(fontSize: 11, color: _C.textSecondary)),
              const SizedBox(height: 2),
              Text(contact.phone,
                  style: TextStyle(
                      fontSize: 11,
                      color: _C.textMuted,
                      fontFamily: 'monospace')),
            ],
          )),

          // Action buttons
          Row(children: [
            _ActionBtn(
              icon: Icons.call_rounded,
              bg: _C.green.withValues(alpha: 0.1),
              border: _C.green.withValues(alpha: 0.3),
              color: _C.green,
              onTap: () => HapticFeedback.lightImpact(),
            ),
            const SizedBox(width: 7),
            _ActionBtn(
              icon: Icons.chat_bubble_outline_rounded,
              bg: _C.blueLight.withValues(alpha: 0.1),
              border: _C.blueLight.withValues(alpha: 0.3),
              color: _C.blueLight,
              onTap: () => HapticFeedback.lightImpact(),
            ),
            const SizedBox(width: 7),
            _ActionBtn(
              icon: Icons.more_horiz_rounded,
              bg: Colors.white.withValues(alpha: 0.04),
              border: Colors.white.withValues(alpha: 0.08),
              color: _C.textMuted,
              onTap: () => _showContactOptions(context),
            ),
          ]),
        ]),

        // Notify toggle strip
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(children: [
            Icon(Icons.notifications_outlined,
                color: contact.notifyOnSOS ? _C.blueLight : _C.textMuted,
                size: 15),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Notify on SOS',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: contact.notifyOnSOS ? _C.textSecondary : _C.textMuted)),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onNotifyToggle(!contact.notifyOnSOS);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36, height: 20,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: contact.notifyOnSOS
                      ? _C.bluePrimary
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: contact.notifyOnSOS
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 14, height: 14,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0A1628),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(contact.name,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
          const SizedBox(height: 20),
          _SheetOption(icon: Icons.edit_rounded,  color: _C.blueLight, label: 'Edit Contact',   onTap: () => Navigator.pop(context)),
          _SheetOption(icon: Icons.swap_vert_rounded, color: _C.amber, label: 'Change Priority', onTap: () => Navigator.pop(context)),
          _SheetOption(icon: Icons.delete_outline_rounded, color: _C.red, label: 'Remove Contact',
            onTap: () { Navigator.pop(context); onDelete(); HapticFeedback.mediumImpact(); }),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════
// Reusable Sub-Widgets
// ═════════════════════════════════════════

class _Glow extends StatelessWidget {
  final Color color;
  final double size, opacity;
  const _Glow({required this.color, required this.size, required this.opacity});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withValues(alpha: opacity), Colors.transparent]),
        ),
      );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color bg, border, color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.bg, required this.border, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
      );
}

class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final IconData icon;
  final String hint;
  final TextInputType type;
  const _SheetField({required this.ctrl, required this.icon, required this.hint, this.type = TextInputType.text});
  @override
  Widget build(BuildContext context) => Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xB30F2347),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0x263B82F6)),
        ),
        child: Row(children: [
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
        ]),
      );
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _SheetOption({required this.icon, required this.color, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      );
}