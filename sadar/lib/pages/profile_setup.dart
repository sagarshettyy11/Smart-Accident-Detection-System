import 'package:flutter/material.dart';
import 'package:sadar/pages/contacts_setup.dart';

// ─────────────────────────────────────────
// Color Constants
// ─────────────────────────────────────────
class _C {
  static const bg = Color(0xFF060E1D);
  static const bluePrimary = Color(0xFF1A56DB);
  static const blueLight = Color(0xFF3B82F6);
  static const green = Color(0xFF10B981);
  static const purple = Color(0xFF8B5CF6);
  static const textPrimary = Color(0xFFF0F4FF);
  static const textSecondary = Color(0xFF8DA0C4);
  static const textMuted = Color(0xFF4A6080);
  static const cardBg = Color(0xB30F2347);
  static const border = Color(0x263B82F6);
}

// ─────────────────────────────────────────
// Profile Setup Screen  (Step 2 of 3)
// ─────────────────────────────────────────
class ProfileSetupScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final VoidCallback? onSkip;

  const ProfileSetupScreen({
    super.key,
    this.onBack,
    this.onContinue,
    this.onSkip,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  // Personal
  final _firstNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _medicalCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  String? _selectedGender;
  String? _selectedBloodGroup;

  // Vehicle
  final _carModelCtrl = TextEditingController();
  final _licenceCtrl = TextEditingController();
  final _rcCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  String? _selectedCarColour;

  final bool _isLoading = false;

  late AnimationController _fadeCtrl;
  late List<Animation<double>> _anims;

  final _genderOptions = ['Male', 'Female', 'Other'];
  final _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final _carColourOptions = [
    'White',
    'Black',
    'Silver',
    'Red',
    'Blue',
    'Grey',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
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
    _firstNameCtrl.dispose();
    _dobCtrl.dispose();
    _nationalIdCtrl.dispose();
    _addressCtrl.dispose();
    _medicalCtrl.dispose();
    _allergiesCtrl.dispose();
    _carModelCtrl.dispose();
    _licenceCtrl.dispose();
    _rcCtrl.dispose();
    _yearCtrl.dispose();
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

  void _handleContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ContactsSetupScreen(), // or ProfileSetupScreen()
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -70,
            child: _Glow(color: _C.bluePrimary, size: 260, opacity: 0.13),
          ),
          Positioned(
            bottom: 80,
            left: -60,
            child: _Glow(color: _C.purple, size: 200, opacity: 0.07),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar (fixed) ──────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: _fs(0, _buildTopBar()),
                ),
                const SizedBox(height: 16),

                // ── Step indicator (fixed) ───────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _fs(0, const _StepIndicator(currentStep: 2)),
                ),
                const SizedBox(height: 4),

                // ── Scrollable content ───────────
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

                        // Avatar
                        _fs(1, _buildAvatarPicker()),
                        const SizedBox(height: 20),

                        // ── Personal Info ──────────────
                        _fs(2, _buildSectionLabel('Personal Info')),
                        const SizedBox(height: 12),

                        // First Name
                        _fs(
                          2,
                          _InputField(
                            controller: _firstNameCtrl,
                            label: 'First Name',
                            hint: 'Ahmed',
                            icon: Icons.person_outline_rounded,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // DOB + Gender row
                        _fs(
                          2,
                          Row(
                            children: [
                              Expanded(
                                child: _InputField(
                                  controller: _dobCtrl,
                                  label: 'Date of Birth',
                                  hint: 'DD / MM / YYYY',
                                  icon: Icons.cake_outlined,
                                  keyboardType: TextInputType.datetime,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DropdownField(
                                  label: 'Gender',
                                  hint: 'Select',
                                  icon: Icons.wc_rounded,
                                  value: _selectedGender,
                                  items: _genderOptions,
                                  onChanged: (v) =>
                                      setState(() => _selectedGender = v),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Blood Group + National ID row
                        _fs(
                          3,
                          Row(
                            children: [
                              Expanded(
                                child: _DropdownField(
                                  label: 'Blood Group',
                                  hint: 'Select',
                                  icon: Icons.bloodtype_outlined,
                                  value: _selectedBloodGroup,
                                  items: _bloodGroups,
                                  onChanged: (v) =>
                                      setState(() => _selectedBloodGroup = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InputField(
                                  controller: _nationalIdCtrl,
                                  label: 'National ID',
                                  hint: 'ID Number',
                                  icon: Icons.credit_card_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Home Address
                        _fs(
                          3,
                          _InputField(
                            controller: _addressCtrl,
                            label: 'Home Address',
                            hint: '123 Main St, San Francisco, CA',
                            icon: Icons.home_outlined,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Medical conditions
                        _fs(
                          4,
                          _InputField(
                            controller: _medicalCtrl,
                            label: 'Medical Conditions (Optional)',
                            hint: 'e.g. Diabetes, Hypertension',
                            icon: Icons.medical_information_outlined,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Allergies
                        _fs(
                          4,
                          _InputField(
                            controller: _allergiesCtrl,
                            label: 'Allergies (Optional)',
                            hint: 'e.g. Penicillin, Peanuts',
                            icon: Icons.warning_amber_outlined,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // ── Vehicle Details ────────────
                        _fs(5, _buildSectionLabel('🚗  Vehicle Details')),
                        const SizedBox(height: 12),

                        // Car Model
                        _fs(
                          5,
                          _InputField(
                            controller: _carModelCtrl,
                            label: 'Car Model',
                            hint: 'e.g. Toyota Camry 2022',
                            icon: Icons.directions_car_outlined,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Licence Number
                        _fs(
                          5,
                          _InputField(
                            controller: _licenceCtrl,
                            label: 'Licence Number',
                            hint: 'DL-XXXXXXXXXX',
                            icon: Icons.credit_card_outlined,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // RC Number
                        _fs(
                          6,
                          _InputField(
                            controller: _rcCtrl,
                            label: 'RC Number',
                            hint: 'RC-XXXXXXXXXX',
                            icon: Icons.description_outlined,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Car Colour + Year row
                        _fs(
                          6,
                          Row(
                            children: [
                              Expanded(
                                child: _DropdownField(
                                  label: 'Car Colour',
                                  hint: 'Select',
                                  icon: Icons.palette_outlined,
                                  value: _selectedCarColour,
                                  items: _carColourOptions,
                                  onChanged: (v) =>
                                      setState(() => _selectedCarColour = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InputField(
                                  controller: _yearCtrl,
                                  label: 'Year',
                                  hint: 'e.g. 2022',
                                  icon: Icons.calendar_today_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Info banner
                        _fs(7, _buildInfoBanner()),
                        const SizedBox(height: 24),

                        // Continue button
                        _fs(
                          8,
                          _PrimaryButton(
                            label: 'Continue to Contacts',
                            icon: Icons.arrow_forward_rounded,
                            isLoading: _isLoading,
                            onTap: _handleContinue,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Skip
                        _fs(
                          8,
                          GestureDetector(
                            onTap: widget.onSkip,
                            child: const Center(
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _C.textMuted,
                                  ),
                                  children: [
                                    TextSpan(text: 'Complete later? '),
                                    TextSpan(
                                      text: 'Skip for now',
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

  // ── Top Bar ──────────────────────────────
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
          'Profile Setup',
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
            color: _C.bluePrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.border),
          ),
          child: const Text(
            'Step 2 of 3',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _C.blueLight,
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
          'Your Profile',
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
          'Help us personalise your SADAR experience\nand improve emergency response accuracy.',
          style: TextStyle(fontSize: 13, color: _C.textSecondary, height: 1.55),
        ),
      ],
    );
  }

  // ── Avatar picker ─────────────────────────
  Widget _buildAvatarPicker() {
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.bluePrimary, _C.blueLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: _C.blueLight.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _C.bluePrimary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'AK',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -5,
                right: -5,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _C.bluePrimary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _C.bg, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tap to upload a photo',
            style: TextStyle(fontSize: 11, color: _C.textMuted),
          ),
        ],
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

  // ── Info banner ───────────────────────────
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.bluePrimary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.blueLight.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 11,
                  color: _C.textSecondary,
                  height: 1.55,
                ),
                children: const [
                  TextSpan(text: 'Your medical & vehicle info is '),
                  TextSpan(
                    text: 'encrypted',
                    style: TextStyle(
                      color: _C.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' and only shared with responders during a detected emergency.',
                  ),
                ],
              ),
            ),
          ),
        ],
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

// Focused input field
class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _C.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 7),
        Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 50,
            decoration: BoxDecoration(
              color: _focused
                  ? _C.bluePrimary.withValues(alpha: 0.08)
                  : _C.cardBg,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: _focused
                    ? _C.bluePrimary.withValues(alpha: 0.6)
                    : _C.border,
                width: _focused ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  widget.icon,
                  color: _focused ? _C.blueLight : _C.textMuted,
                  size: 17,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _C.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: _C.blueLight,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: _C.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Dropdown field
class _DropdownField extends StatefulWidget {
  final String label, hint;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<_DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<_DropdownField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _C.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: _focused
                ? _C.bluePrimary.withValues(alpha: 0.08)
                : _C.cardBg,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: _focused
                  ? _C.bluePrimary.withValues(alpha: 0.6)
                  : _C.border,
              width: _focused ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(widget.icon, color: _C.textMuted, size: 17),
              const SizedBox(width: 9),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.value,
                    hint: Text(
                      widget.hint,
                      style: const TextStyle(fontSize: 12, color: _C.textMuted),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: _C.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: const Color(0xFF0F2347),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _C.textMuted,
                      size: 18,
                    ),
                    onTap: () => setState(() => _focused = true),
                    onChanged: (v) {
                      setState(() => _focused = false);
                      widget.onChanged(v);
                    },
                    items: widget.items
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 3-step indicator
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepDot(number: 1, label: 'Account', state: _state(1)),
        Expanded(child: _StepLine(state: _lineState(1))),
        _StepDot(number: 2, label: 'Profile', state: _state(2)),
        Expanded(child: _StepLine(state: _lineState(2))),
        _StepDot(number: 3, label: 'Contacts', state: _state(3)),
      ],
    );
  }

  _DS _state(int s) {
    if (s < currentStep) return _DS.done;
    if (s == currentStep) return _DS.active;
    return _DS.inactive;
  }

  _DS _lineState(int afterStep) {
    if (afterStep < currentStep) return _DS.done;
    if (afterStep == currentStep) return _DS.active;
    return _DS.inactive;
  }
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

// Primary button
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_C.bluePrimary, Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _C.bluePrimary.withValues(alpha: 0.38),
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
                    Icon(icon, color: Colors.white, size: 19),
                    const SizedBox(width: 9),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
