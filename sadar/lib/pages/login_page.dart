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
  static const textPrimary   = Color(0xFFF0F4FF);
  static const textSecondary = Color(0xFF8DA0C4);
  static const textMuted     = Color(0xFF4A6080);
  static const cardBg        = Color(0xB30F2347);
  static const border        = Color(0x263B82F6);
}

// ─────────────────────────────────────────
// LOGIN SCREEN
// ─────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  /// Called when user taps "Sign Up"
  final VoidCallback? onNavigateToSignUp;

  /// Called after successful login
  final VoidCallback? onLoginSuccess;

  const LoginScreen({
    super.key,
    this.onNavigateToSignUp,
    this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool  _obscurePass  = true;
  bool  _rememberMe   = true;
  bool  _isLoading    = false;

  late AnimationController _fadeCtrl;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _anims = List.generate(7, (i) {
      final s = (i * 0.1).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _fadeCtrl,
        curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Staggered fade + slide helper
  Widget _fs(int i, Widget child) => FadeTransition(
        opacity: _anims[i],
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.18), end: Offset.zero)
              .animate(_anims[i]),
          child: child,
        ),
      );

  Future<void> _handleLogin() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) {
      setState(() => _isLoading = false);
      widget.onLoginSuccess?.call();
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
          top: -100, right: -80,
          child: _Glow(color: _C.bluePrimary, size: 320, opacity: 0.14),
        ),
        Positioned(
          bottom: 80, left: -80,
          child: _Glow(color: _C.green, size: 240, opacity: 0.07),
        ),

        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // ── Brand row ────────────────
                _fs(0, _buildBrandRow()),
                const SizedBox(height: 36),

                // ── Welcome text ─────────────
                _fs(1, _buildWelcomeText()),
                const SizedBox(height: 32),

                // ── Email field ──────────────
                _fs(2, _InputField(
                  controller: _emailCtrl,
                  label: 'Email Address',
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                )),
                const SizedBox(height: 14),

                // ── Password field ───────────
                _fs(2, _InputField(
                  controller: _passwordCtrl,
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
                const SizedBox(height: 16),

                // ── Remember me + Forgot ─────
                _fs(3, _buildRememberRow()),
                const SizedBox(height: 28),

                // ── Login button ─────────────
                _fs(4, _PrimaryButton(
                  label: 'Sign In',
                  icon: Icons.login_rounded,
                  isLoading: _isLoading,
                  onTap: _handleLogin,
                )),
                const SizedBox(height: 24),

                // ── Or divider ───────────────
                _fs(4, const _OrDivider()),
                const SizedBox(height: 22),

                // ── Social buttons ───────────
                _fs(5, _buildSocialRow()),
                const SizedBox(height: 36),

                // ── Sign up link ─────────────
                _fs(6, _buildSignUpLink()),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ── Brand Row ────────────────────────────
  Widget _buildBrandRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo + name
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_C.bluePrimary, _C.blueLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: _C.bluePrimary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: const Center(
              child: Text('S',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 9),
          const Text('SADAR',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                  letterSpacing: 1)),
        ]),

        // System online pill
        _SystemOnlinePill(),
      ],
    );
  }

  // ── Welcome Text ─────────────────────────
  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Welcome back',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
                letterSpacing: -0.5,
                height: 1.1)),
        const SizedBox(height: 6),
        const Text('Sign in to your SADAR account to\ncontinue monitoring.',
            style: TextStyle(
                fontSize: 13,
                color: _C.textSecondary,
                height: 1.55)),
      ],
    );
  }

  // ── Remember + Forgot ────────────────────
  Widget _buildRememberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: _rememberMe ? _C.bluePrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _rememberMe ? _C.bluePrimary : _C.textMuted,
                  width: 1.5,
                ),
              ),
              child: _rememberMe
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 9),
            const Text('Remember me',
                style: TextStyle(
                    fontSize: 12,
                    color: _C.textSecondary,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: const Text('Forgot password?',
              style: TextStyle(
                  fontSize: 12,
                  color: _C.blueLight,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // ── Social Row ───────────────────────────
  Widget _buildSocialRow() {
    return Row(children: [
      Expanded(child: _SocialButton(label: 'Google', emoji: '🌐')),
      const SizedBox(width: 12),
      Expanded(child: _SocialButton(label: 'Apple',  emoji: '🍎')),
    ]);
  }

  // ── Sign Up Link ─────────────────────────
  Widget _buildSignUpLink() {
    return Center(
      child: GestureDetector(
        onTap: widget.onNavigateToSignUp,
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 13, color: _C.textSecondary),
            children: [
              TextSpan(text: "Don't have an account? "),
              TextSpan(
                text: 'Sign Up',
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
// Shared / Reusable Widgets
// ═════════════════════════════════════════

// Ambient radial glow
class _Glow extends StatelessWidget {
  final Color color;
  final double size, opacity;
  const _Glow(
      {required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withValues(alpha: opacity), Colors.transparent]),
        ),
      );
}

// System online animated pill
class _SystemOnlinePill extends StatefulWidget {
  @override
  State<_SystemOnlinePill> createState() => _SystemOnlinePillState();
}

class _SystemOnlinePillState extends State<_SystemOnlinePill>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _C.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.green.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        FadeTransition(
          opacity:
              Tween<double>(begin: 1.0, end: 0.3).animate(_ctrl),
          child: Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
                color: _C.green, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 6),
        const Text('System Online',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _C.green)),
      ]),
    );
  }
}

// Focused input field
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

// Gradient primary button
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
        height: 56,
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
    );
  }
}

// "Or continue with" divider
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Divider(color: _C.border, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text('or continue with',
            style: TextStyle(
                fontSize: 11,
                color: _C.textMuted,
                fontWeight: FontWeight.w500)),
      ),
      Expanded(child: Divider(color: _C.border, thickness: 1)),
    ]);
  }
}

// Google / Apple social button
class _SocialButton extends StatelessWidget {
  final String label, emoji;
  const _SocialButton({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 17)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _C.textSecondary)),
        ]),
      ),
    );
  }
}