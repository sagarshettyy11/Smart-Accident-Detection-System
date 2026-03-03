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
// Profile Screen
// ─────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {

  // Notification toggles
  bool _emergencyAlerts  = true;
  bool _systemReports    = true;
  bool _locationSharing  = false;

  late AnimationController _fadeCtrl;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anims = List.generate(8, (i) {
      final s = (i * 0.08).clamp(0.0, 1.0);
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
        Positioned(top: -80, right: -70,
            child: _Glow(color: _C.bluePrimary, size: 260, opacity: 0.14)),
        Positioned(bottom: 80, left: -60,
            child: _Glow(color: _C.purple, size: 200, opacity: 0.07)),

        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header (gradient bg) ───────────
              SliverToBoxAdapter(
                child: _fs(0, _buildProfileHeader()),
              ),

              // ── Stats strip ────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                  child: _fs(1, _buildStatsStrip()),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Personal Info
                    _fs(2, _buildPersonalInfo()),
                    const SizedBox(height: 14),

                    // Vehicle / System info
                    _fs(3, _buildSystemInfo()),
                    const SizedBox(height: 14),

                    // Notifications
                    _fs(4, _buildNotifications()),
                    const SizedBox(height: 14),

                    // Account settings
                    _fs(5, _buildAccountSettings()),
                    const SizedBox(height: 14),

                    // Logout
                    _fs(6, _buildLogoutButton()),
                    const SizedBox(height: 10),

                    // Version
                    _fs(7, Center(
                      child: Text('SADAR v2.4.1 · Build 2024.03',
                          style: TextStyle(
                              fontSize: 10, color: _C.textMuted)),
                    )),
                    const SizedBox(height: 28),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Profile Header ───────────────────────
  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F2347), _C.bg],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      child: Column(children: [
        // Topbar
        Row(children: [
          const Text('My Profile',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                  letterSpacing: -0.3)),
          const Spacer(),
          _IconBtn(icon: Icons.notifications_outlined),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.settings_outlined),
        ]),
        const SizedBox(height: 24),

        // Avatar
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_C.bluePrimary, _C.blueLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                    color: _C.bluePrimary.withValues(alpha:0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: const Center(
              child: Text('AK',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
          Positioned(
            bottom: -4, right: -4,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: _C.bluePrimary,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _C.bg, width: 2),
                boxShadow: [
                  BoxShadow(color: _C.bluePrimary.withValues(alpha:0.4), blurRadius: 8),
                ],
              ),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
            ),
          ),
        ]),
        const SizedBox(height: 14),

        const Text('Ahmed Khan',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
                letterSpacing: -0.3)),
        const SizedBox(height: 3),
        Text('ID: SADAR-2024-AK · Member since Jan 2024',
            style: TextStyle(fontSize: 11, color: _C.textSecondary)),
        const SizedBox(height: 12),

        // Badges
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Badge(label: '● Active',  bg: _C.green.withValues(alpha: 0.12),   border: _C.green.withValues(alpha: 0.3),   color: _C.green),
          const SizedBox(width: 8),
          _Badge(label: 'Pro Plan',  bg: _C.blueLight.withValues(alpha: 0.12), border: _C.blueLight.withValues(alpha: 0.3), color: _C.blueLight),
          const SizedBox(width: 8),
          _Badge(label: 'Verified',  bg: _C.purple.withValues(alpha: 0.12),  border: _C.purple.withValues(alpha: 0.3),  color: _C.purple),
        ]),
      ]),
    );
  }

  // ── Stats Strip ──────────────────────────
  Widget _buildStatsStrip() {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Row(children: [
        Expanded(child: _StatCell(value: '0',   label: 'Incidents', color: _C.green,      isLast: false)),
        Expanded(child: _StatCell(value: '24h', label: 'Uptime',    color: _C.blueLight,  isLast: false)),
        Expanded(child: _StatCell(value: '3',   label: 'Contacts',  color: _C.amber,      isLast: true)),
      ]),
    );
  }

  // ── Personal Info ────────────────────────
  Widget _buildPersonalInfo() {
    return _DashCard(
      title: 'Personal Info',
      icon: Icons.person_outline_rounded,
      iconBg: _C.bluePrimary.withValues(alpha: 0.12),
      actionLabel: 'Edit',
      child: Column(children: [
        _InfoRow(icon: Icons.email_outlined,    iconBg: _C.blueLight.withValues(alpha: 0.1), label: 'Email',       value: 'ahmed.khan@email.com'),
        _InfoRow(icon: Icons.phone_outlined,    iconBg: _C.green.withValues(alpha: 0.1),     label: 'Phone',       value: '+1 (555) 012-3456'),
        _InfoRow(icon: Icons.location_on_outlined, iconBg: _C.amber.withValues(alpha: 0.1), label: 'Location',    value: 'San Francisco, CA'),
        _InfoRow(icon: Icons.bloodtype_outlined, iconBg: _C.red.withValues(alpha: 0.1),     label: 'Blood Group', value: 'O+ (Positive)', isLast: true),
      ]),
    );
  }

  // ── System Info ──────────────────────────
  Widget _buildSystemInfo() {
    return _DashCard(
      title: 'System Info',
      icon: Icons.shield_outlined,
      iconBg: _C.green.withValues(alpha: 0.12),
      iconColor: _C.green,
      child: Column(children: [
        _InfoRow(icon: Icons.camera_outlined,      iconBg: _C.blueLight.withValues(alpha: 0.1), label: 'Camera Model',   value: 'SADAR Cam Pro v2'),
        _InfoRow(icon: Icons.satellite_alt_rounded, iconBg: _C.green.withValues(alpha: 0.1),   label: 'GPS Module',      value: 'NEO-M8N · 4 Satellites'),
        _InfoRow(icon: Icons.memory_rounded,        iconBg: _C.purple.withValues(alpha: 0.1),  label: 'Firmware',        value: 'v2.4.1 (Up to date)', isLast: true),
      ]),
    );
  }

  // ── Notifications ────────────────────────
  Widget _buildNotifications() {
    return _DashCard(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      iconBg: _C.amber.withValues(alpha: 0.12),
      iconColor: _C.amber,
      child: Column(children: [
        _ToggleRow(
          icon: Icons.emergency_rounded,
          iconBg: _C.red.withValues(alpha: 0.1),
          iconColor: _C.red,
          title: 'Emergency Alerts',
          subtitle: 'Instant SMS + push on detection',
          value: _emergencyAlerts,
          onChanged: (v) => setState(() => _emergencyAlerts = v),
        ),
        _ToggleRow(
          icon: Icons.bar_chart_rounded,
          iconBg: _C.blueLight.withValues(alpha: 0.1),
          iconColor: _C.blueLight,
          title: 'System Reports',
          subtitle: 'Daily summary digest',
          value: _systemReports,
          onChanged: (v) => setState(() => _systemReports = v),
        ),
        _ToggleRow(
          icon: Icons.location_on_outlined,
          iconBg: _C.green.withValues(alpha: 0.1),
          iconColor: _C.green,
          title: 'Location Sharing',
          subtitle: 'Share live GPS with contacts',
          value: _locationSharing,
          onChanged: (v) => setState(() => _locationSharing = v),
          isLast: true,
        ),
      ]),
    );
  }

  // ── Account Settings ─────────────────────
  Widget _buildAccountSettings() {
    return _DashCard(
      title: 'Account',
      icon: Icons.manage_accounts_outlined,
      iconBg: _C.purple.withValues(alpha: 0.12),
      iconColor: _C.purple,
      child: Column(children: [
        _TapRow(icon: Icons.lock_outline_rounded,   iconBg: _C.bluePrimary.withValues(alpha: 0.1), title: 'Change Password',    subtitle: 'Last changed 30 days ago'),
        _TapRow(icon: Icons.phone_android_rounded,  iconBg: _C.green.withValues(alpha: 0.1),       title: 'Linked Devices',     subtitle: '2 devices active'),
        _TapRow(icon: Icons.delete_outline_rounded, iconBg: _C.red.withValues(alpha: 0.1),         title: 'Delete Account',     subtitle: 'Permanently remove account', isLast: true, isDanger: true),
      ]),
    );
  }

  // ── Logout Button ────────────────────────
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => HapticFeedback.mediumImpact(),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: _C.red.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.red.withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout_rounded, color: _C.red, size: 20),
          const SizedBox(width: 9),
          Text('Sign Out',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _C.red)),
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

class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});
  @override
  Widget build(BuildContext context) => Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: _C.border),
        ),
        child: Icon(icon, color: _C.textSecondary, size: 18),
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg, border, color;
  const _Badge({required this.label, required this.bg, required this.border, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      );
}

class _StatCell extends StatelessWidget {
  final String value, label;
  final Color color;
  final bool isLast;
  const _StatCell({required this.value, required this.label, required this.color, required this.isLast});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          border: isLast ? null : Border(right: BorderSide(color: _C.border)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.5,
                  height: 1)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  color: _C.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6)),
        ]),
      );
}

class _DashCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconBg, iconColor;
  final String? actionLabel;
  final Widget child;

  const _DashCard({
    required this.title,
    required this.icon,
    this.iconBg,
    this.iconColor,
    this.actionLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: iconBg ?? _C.bluePrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? _C.blueLight, size: 17),
            ),
            const SizedBox(width: 9),
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary)),
            const Spacer(),
            if (actionLabel != null)
              Text(actionLabel!,
                  style: const TextStyle(
                      fontSize: 11,
                      color: _C.blueLight,
                      fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 14),
          child,
        ]),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label, value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 17),
          ),
          const SizedBox(width: 13),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: _C.textMuted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary)),
            ],
          )),
        ]),
      ),
      if (!isLast) Divider(height: 1, thickness: 1, color: Colors.white.withValues(alpha: 0.05)),
    ]);
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 13),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _C.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(fontSize: 10, color: _C.textMuted)),
            ],
          )),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(!value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 44, height: 26,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: value ? _C.bluePrimary : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
      if (!isLast) Divider(height: 1, thickness: 1, color: Colors.white.withValues(alpha:0.05)),
    ]);
  }
}

class _TapRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title, subtitle;
  final bool isLast, isDanger;

  const _TapRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.isLast = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: isDanger ? _C.red : Colors.white.withValues(alpha: 0.7), size: 17),
            ),
            const SizedBox(width: 13),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDanger ? _C.red : _C.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 10, color: _C.textMuted)),
              ],
            )),
            Icon(Icons.chevron_right_rounded, color: _C.textMuted, size: 20),
          ]),
        ),
      ),
      if (!isLast) Divider(height: 1, thickness: 1, color: Colors.white.withValues(alpha: 0.05)),
    ]);
  }
}