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
  static const textPrimary   = Color(0xFFF0F4FF);
  static const textSecondary = Color(0xFF8DA0C4);
  static const textMuted     = Color(0xFF4A6080);
  static const cardBg        = Color(0xB30F2347);
  static const border        = Color(0x263B82F6);
}

// ─────────────────────────────────────────
// SIGN UP SCREEN
// ─────────────────────────────────────────
class SignUpScreen extends StatefulWidget {
  /// Called when user taps "Sign In"
  final VoidCallback? onNavigateToLogin;

  /// Called after successful sign up
  final VoidCallback? onSignUpSuccess;

  const SignUpScreen({
    super.key,
    this.onNavigateToLogin,
    this.onSignUpSuccess,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms  = false;
  bool _isLoading      = false;

  late AnimationController _fadeCtrl;
  late List<Animation<double>> _anims;

  // ── Password strength ─────────────────────
  double get _strength {
    final p = _passCtrl.text;
    if (p.isEmpty) return 0;
    double s = 0;
    if (p.length >= 8)                           s += 0.25;
    if (p.contains(RegExp(r'[A-Z]')))            s += 0.25;
    if (p.contains(RegExp(r'[0-9]')))            s += 0.25;
    if (p.contains(RegExp(r'[!@#\$&*~_\-]')))   s += 0.25;
    return s;
  }

  Color get _strengthColor {
    if (_strength <= 0.25) return _C.red;
    if (_strength <= 0.50) return _C.amber;
    if (_strength <= 0.75) return _C.blueLight;
    return _C.green;
  }

  String get _strengthLabel {
    if (_strength == 0)    return '';
    if (_strength <= 0.25) return 'Weak';
    if (_strength <= 0.50) return 'Fair';
    if (_strength <= 0.75) return 'Good';
    return 'Strong';
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _anims = List.generate(9, (i) {
      final s = (i * 0.08).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _fadeCtrl,
        curve: Interval(s, (s + 0.4).clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });
    _fadeCtrl.forward();
    _passCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Widget _fs(int i, Widget child) => FadeTransition(
        opacity: _anims[i],
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.18), end: Offset.zero)
              .animate(_anims[i]),
          child: child,
        ),
      );

  Future<void> _handleSignUp() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() => _isLoading = false);
      widget.onSignUpSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        // ── Ambient glows ────────────────────
        Positioned(
          top: -80, left: -80,
          child: _Glow(color: _C.bluePrimary, size: 300, opacity: 0.12),
        ),
        Positioned(
          bottom: 120, right: -80,
          child: _Glow(color: _C.green, size: 220, opacity: 0.07),
        ),

        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── Back + Logo ──────────────
                _fs(0, _buildTopBar()),
                const SizedBox(height: 28),

                // ── Welcome text ─────────────
                _fs(1, _buildWelcomeText()),
                const SizedBox(height: 22),

                // ── Step indicator ───────────
                _fs(1, const _StepIndicator(currentStep: 1)),
                const SizedBox(height: 24),

                // ── Full name ────────────────
                _fs(2, _InputField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  hint: 'John Doe',
                  icon: Icons.person_outline_rounded,
                )),
                const SizedBox(height: 14),

                // ── Email ────────────────────
                _fs(2, _InputField(
                  controller: _emailCtrl,
                  label: 'Email Address',
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                )),
                const SizedBox(height: 14),

                // ── Phone ────────────────────
                _fs(3, _InputField(
                  controller: _phoneCtrl,
                  label: 'Phone Number',
                  hint: '+1 (555) 000-0000',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                )),
                const SizedBox(height: 14),

                // ── Password ─────────────────
                _fs(3, _InputField(
                  controller: _passCtrl,
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePass,
                  suffix: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePass = !_obscurePass),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Icon(
                        _obscurePass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _C.textMuted,
                        size: 20,
                      ),
                    ),
                  ),
                )),

                // ── Strength bar ─────────────
                if (_passCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _fs(3, _PasswordStrengthBar(
                    strength: _strength,
                    color: _strengthColor,
                    label: _strengthLabel,
                  )),
                ],
                const SizedBox(height: 14),

                // ── Confirm password ─────────
                _fs(4, _InputField(
                  controller: _confirmCtrl,
                  label: 'Confirm Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureConfirm,
                  suffix: GestureDetector(
                    onTap: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _C.textMuted,
                        size: 20,
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 22),

                // ── Terms checkbox ───────────
                _fs(5, _buildTermsRow()),
                const SizedBox(height: 28),

                // ── Sign up button ───────────
                _fs(6, _PrimaryButton(
                  label: 'Create Account',
                  icon: Icons.person_add_rounded,
                  isLoading: _isLoading,
                  disabled: !_agreedToTerms,
                  onTap: _agreedToTerms ? _handleSignUp : null,
                )),
                const SizedBox(height: 24),

                // ── Sign in link ─────────────
                _fs(7, _buildSignInLink()),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ── Top Bar ──────────────────────────────
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        GestureDetector(
          onTap: widget.onNavigateToLogin,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _C.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.border),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _C.textSecondary, size: 16),
          ),
        ),

        // Logo chip
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_C.bluePrimary, _C.blueLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                    color: _C.bluePrimary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: const Center(
              child: Text('S',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          const Text('SADAR',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                  letterSpacing: 1)),
        ]),
      ],
    );
  }

  // ── Welcome text ─────────────────────────
  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Create Account',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
                letterSpacing: -0.5,
                height: 1.1)),
        const SizedBox(height: 6),
        const Text(
            'Join SADAR and set up your\nautomated emergency response system.',
            style: TextStyle(
                fontSize: 13,
                color: _C.textSecondary,
                height: 1.55)),
      ],
    );
  }

  // ── Terms row ────────────────────────────
  Widget _buildTermsRow() {
    return GestureDetector(
      onTap: () =>
          setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20, height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: _agreedToTerms ? _C.bluePrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color:
                    _agreedToTerms ? _C.bluePrimary : _C.textMuted,
                width: 1.5,
              ),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 13)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 12,
                    color: _C.textSecondary,
                    height: 1.55),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text('Terms of Service',
                          style: TextStyle(
                              fontSize: 12,
                              color: _C.blueLight,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text('Privacy Policy',
                          style: TextStyle(
                              fontSize: 12,
                              color: _C.blueLight,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sign in link ─────────────────────────
  Widget _buildSignInLink() {
    return Center(
      child: GestureDetector(
        onTap: widget.onNavigateToLogin,
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 13, color: _C.textSecondary),
            children: [
              TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                    color: _C.blueLight, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════
// Reusable Widgets (shared across screens)
// ═════════════════════════════════════════

// Ambient radial glow
class _Glow extends StatelessWidget {
  final Color color;
  final double size, opacity;
  const _Glow(
      {required this.color, required this.size, required this.opacity});

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

// Focused input field with animated border
class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscure;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.suffix,
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
        Text(widget.label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.textSecondary,
                letterSpacing: 0.3)),
        const SizedBox(height: 7),
        Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: BoxDecoration(
              color: _focused
                  ? _C.bluePrimary.withValues(alpha: 0.08)
                  : _C.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _focused
                    ? _C.bluePrimary.withValues(alpha: 0.6)
                    : _C.border,
                width: _focused ? 1.5 : 1,
              ),
            ),
            child: Row(children: [
              const SizedBox(width: 14),
              Icon(widget.icon,
                  color: _focused ? _C.blueLight : _C.textMuted,
                  size: 19),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscure,
                  style: const TextStyle(
                      fontSize: 14,
                      color: _C.textPrimary,
                      fontWeight: FontWeight.w500),
                  cursorColor: _C.blueLight,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                        fontSize: 13, color: _C.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (widget.suffix != null) widget.suffix!,
            ]),
          ),
        ),
      ],
    );
  }
}

// Gradient primary button with disabled state
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool disabled;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLoading || disabled) ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.45 : 1.0,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.bluePrimary, Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: disabled
                ? []
                : [
                    BoxShadow(
                        color: _C.bluePrimary.withValues(alpha: 0.38),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(label,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.1)),
                  ]),
          ),
        ),
      ),
    );
  }
}

// 3-step progress indicator
class _StepIndicator extends StatelessWidget {
  final int currentStep; // 1, 2, or 3

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepDot(
            number: 1,
            label: 'Account',
            state: _stepState(1)),
        Expanded(child: _StepLine(active: currentStep > 1)),
        _StepDot(
            number: 2,
            label: 'Profile',
            state: _stepState(2)),
        Expanded(child: _StepLine(active: currentStep > 2)),
        _StepDot(
            number: 3,
            label: 'Contacts',
            state: _stepState(3)),
      ],
    );
  }

  _DotState _stepState(int step) {
    if (step < currentStep) return _DotState.done;
    if (step == currentStep) return _DotState.active;
    return _DotState.inactive;
  }
}

enum _DotState { active, done, inactive }

class _StepDot extends StatelessWidget {
  final int number;
  final String label;
  final _DotState state;

  const _StepDot(
      {required this.number, required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    final isActive   = state == _DotState.active;
    final isDone     = state == _DotState.done;
    final isInactive = state == _DotState.inactive;

    return Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: isActive
              ? _C.bluePrimary
              : isDone
                  ? _C.green
                  : _C.cardBg,
          shape: BoxShape.circle,
          border: isInactive
              ? Border.all(color: _C.border, width: 1.5)
              : null,
        ),
        child: Center(
          child: isDone
              ? const Icon(Icons.check_rounded,
                  color: Colors.white, size: 14)
              : Text('$number',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? Colors.white
                          : _C.textMuted)),
        ),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: isActive ? _C.blueLight : _C.textMuted)),
    ]);
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) => Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
        decoration: BoxDecoration(
          color: active
              ? _C.bluePrimary.withValues(alpha: 0.45)
              : _C.border,
          borderRadius: BorderRadius.circular(1),
        ),
      );
}

// Animated password strength bar
class _PasswordStrengthBar extends StatelessWidget {
  final double strength;
  final Color color;
  final String label;

  const _PasswordStrengthBar({
    required this.strength,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Stack(children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 300),
            widthFactor: strength,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 5),
                ],
              ),
            ),
          ),
        ]),
      ),
      const SizedBox(width: 10),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(label,
            key: ValueKey(label),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color)),
      ),
    ]);
  }
}