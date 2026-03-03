import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sadar/screens/emergency_screen.dart';
import 'package:sadar/screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A1628),
  ));
  runApp(const SADARApp());
}

// ══════════════════════════════════════════════════════
// COLORS
// ══════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  static const Color background    = Color(0xFF060E1D);
  static const Color blueDark      = Color(0xFF0A1628);
  static const Color blueMid       = Color(0xFF0F2347);
  static const Color bluePrimary   = Color(0xFF1A56DB);
  static const Color blueLight     = Color(0xFF3B82F6);
  static const Color green         = Color(0xFF10B981);
  static const Color red           = Color(0xFFEF4444);
  static const Color amber         = Color(0xFFF59E0B);
  static const Color textPrimary   = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8DA0C4);
  static const Color textMuted     = Color(0xFF4A6080);

  static Color get cardBg     => const Color(0xFF0F2347).withValues(alpha: 0.7);
  static Color get cardBorder => blueLight.withValues(alpha: 0.15);
}

// ══════════════════════════════════════════════════════
// TYPOGRAPHY HELPER
// ══════════════════════════════════════════════════════

TextStyle inter({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = AppColors.textPrimary,
  double? letterSpacing,
  double? height,
}) =>
    GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

// ══════════════════════════════════════════════════════
// APP ROOT
// ══════════════════════════════════════════════════════

class SADARApp extends StatelessWidget {
  const SADARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SADAR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: const DashboardScreen(),
    );
  }
}

// ══════════════════════════════════════════════════════
// DASHBOARD SCREEN
// ══════════════════════════════════════════════════════

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _navIndex = 0;

  late AnimationController _pulseCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── BUILD ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _ambientGlow(),
          Column(
            children: [
              Expanded(child: _scrollContent(context)),
              _buildBottomNav(),
            ],
          ),
        ],
      ),
    );
  }

  // Background radial glows
  Widget _ambientGlow() {
    return Stack(children: [
      Positioned(
        top: -100, left: -60,
        child: _glowCircle(300, AppColors.bluePrimary.withValues(alpha: 0.12)),
      ),
      Positioned(
        bottom: 80, right: -60,
        child: _glowCircle(220, AppColors.green.withValues(alpha: 0.06)),
      ),
    ]);
  }

  Widget _glowCircle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      );

  Widget _scrollContent(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: MediaQuery.of(context).padding.top + 14),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildHeroCard(),
              const SizedBox(height: 14),
              _buildMonitorButton(),
              const SizedBox(height: 14),
              _buildStatsRow(),
              const SizedBox(height: 14),
              _buildLocationCard(),
              const SizedBox(height: 14),
              _buildEmergencyContactsCard(context),
              const SizedBox(height: 14),
              _buildIncidentCard(),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ],
    );
  }

  // ── HEADER ───────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SADAR SYSTEM',
                  style: inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueLight,
                    letterSpacing: 2,
                  )),
              const SizedBox(height: 3),
              Text('Dashboard',
                  style: inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.1,
                  )),
              const SizedBox(height: 2),
              Text('Monday, March 02 · Good morning',
                  style: inter(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        // Avatar with online indicator
        GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  },
  child: Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bluePrimary, AppColors.blueLight],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.bluePrimary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'AK',
          style: inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      Positioned(
        top: -2,
        right: -2,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blueDark, width: 2),
          ),
        ),
      ),
    ],
  ),
        ),
      ],
    );
  }

  // ── HERO STATUS CARD ─────────────────────────────────

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2347), Color(0xFF162E55), Color(0xFF0D1F3C)],
          stops: [0.0, 0.5, 1.0],
        ),
        border: Border.all(color: AppColors.blueLight.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Top-right glow
          Positioned(
            top: -40,
            right: -40,
            child: _glowCircle(160, AppColors.bluePrimary.withValues(alpha: 0.2)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SYSTEM STATUS',
                  style: inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5),
                      children: [
                        const TextSpan(text: 'System '),
                        TextSpan(
                          text: 'Active',
                          style: TextStyle(color: AppColors.green),
                        ),
                      ],
                    ),
                  ),
                  _buildLivePill(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSensorTile(
                      icon: '📷',
                      iconColor: AppColors.bluePrimary,
                      name: 'CAMERA',
                      value: 'Running',
                      badge: '● OK',
                      badgeColor: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSensorTile(
                      icon: '🛰',
                      iconColor: AppColors.green,
                      name: 'GPS SIGNAL',
                      value: 'Fixed',
                      badge: '4 SAT',
                      badgeColor: AppColors.blueLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLivePill() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.2),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.green
                    .withValues(alpha: 0.5 + 0.5 * _pulseCtrl.value),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text('LIVE',
                style: inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorTile({
    required String icon,
    required Color iconColor,
    required String name,
    required String value,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 7),
            Text(name,
                style: inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value,
                  style: inter(fontSize: 13, fontWeight: FontWeight.w600)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge,
                    style: inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                        letterSpacing: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── MONITOR BUTTON ───────────────────────────────────

  Widget _buildMonitorButton() {
    return GestureDetector(
      onTap: () {},
      child: AnimatedBuilder(
        animation: _shimmerCtrl,
        builder: (_, _) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bluePrimary, Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bluePrimary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Shimmer sweep
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ShaderMask(
                      blendMode: BlendMode.srcOver,
                      shaderCallback: (bounds) {
                        final pos = _shimmerCtrl.value * 3 - 1;
                        return LinearGradient(
                          begin: Alignment(pos - 0.5, 0),
                          end: Alignment(pos + 0.5, 0),
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.09),
                            Colors.transparent,
                          ],
                        ).createShader(bounds);
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
                Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🛡️',
                        style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Monitoring',
                          style: inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2)),
                      Text('All sensors ready · Tap to activate',
                          style: inter(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.6))),
                    ],
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── STATS ROW ────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statBox('0',   'INCIDENTS', AppColors.green)),
        const SizedBox(width: 10),
        Expanded(child: _statBox('98%', 'ACCURACY',  AppColors.blueLight)),
        const SizedBox(width: 10),
        Expanded(child: _statBox('24h', 'UPTIME',    AppColors.amber)),
      ],
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Text(value,
            style: inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.5,
                height: 1)),
        const SizedBox(height: 4),
        Text(label,
            style: inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.7)),
      ]),
    );
  }

  // ── LIVE LOCATION CARD ───────────────────────────────

  Widget _buildLocationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            context: context,
            icon: '📍',
            iconBg: AppColors.bluePrimary.withValues(alpha: 0.15),
            title: 'Live Location',
            action: 'Open Map',
            onPressed: () {
            },
          ),
          const SizedBox(height: 14),
          // Map placeholder
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D1F3C), Color(0xFF162E55)],
              ),
              border: Border.all(
                  color: AppColors.blueLight.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Grid pattern
                  CustomPaint(
                    painter: _MapGridPainter(),
                    child: const SizedBox.expand(),
                  ),
                  // Expanding rings
                  AnimatedBuilder(
                    animation: _ringCtrl,
                    builder: (_, _) => Stack(
                      alignment: Alignment.center,
                      children: [
                        _ringWidget(95, _ringCtrl.value),
                        _ringWidget(65, (_ringCtrl.value + 0.32) % 1.0),
                      ],
                    ),
                  ),
                  // Location pin
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.bluePrimary,
                          AppColors.blueLight
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(17),
                        topRight: Radius.circular(17),
                        bottomRight: Radius.circular(17),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.bluePrimary.withValues(alpha: 0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('📍',
                        style: TextStyle(fontSize: 15)),
                  ),
                  // GPS Locked badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.15),
                        border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('GPS LOCKED',
                          style: inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                              letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Coordinates
          Row(children: [
            Expanded(child: _coordBox('Latitude', '37.7749° N')),
            const SizedBox(width: 8),
            Expanded(child: _coordBox('Longitude', '122.4194° W')),
          ]),
          const SizedBox(height: 8),
          // GPS status row
          Row(children: [
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, _) => Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.green
                      .withValues(alpha: 0.4 + 0.6 * _pulseCtrl.value),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 5),
            RichText(
              text: TextSpan(
                style: inter(
                    fontSize: 10, color: AppColors.textSecondary),
                children: [
                  const TextSpan(text: 'Tracking active · Accuracy: '),
                  TextSpan(
                    text: '±2.4m',
                    style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' · Updated just now'),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _ringWidget(double size, double t) {
    final opacity = (1.0 - t).clamp(0.0, 1.0);
    return Transform.scale(
      scale: 0.7 + 0.5 * t,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.bluePrimary.withValues(alpha: 0.35 * opacity),
            width: size > 80 ? 1.5 : 2.0,
          ),
        ),
      ),
    );
  }

  Widget _coordBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(value, style: inter(fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── EMERGENCY CONTACTS CARD ──────────────────────────

  Widget _buildEmergencyContactsCard(BuildContext context) {
    return _card(
      child: Column(children: [
        _cardHeader(
          context: context,
          icon: '🚨',
          iconBg: AppColors.red.withValues(alpha: 0.12),
          title: 'Emergency Contacts',
          action: 'Manage',
          onPressed: () {
    Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => const EmergencyContactsScreen(),
  ),
);
  },
        ),
        const SizedBox(height: 4),
        _contactTile(
          emoji: '👩',
          gradient: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
          name: 'Sarah Ahmed',
          sub: 'Spouse · +1 (555) 020-1110',
          priority: 'P1',
          priorityColor: AppColors.red,
          divider: true,
        ),
        _contactTile(
          emoji: '👨',
          gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          name: 'Dr. James R.',
          sub: 'Family Doctor · +1 (555) 030-2220',
          priority: 'P2',
          priorityColor: AppColors.amber,
          divider: true,
        ),
        _contactTile(
          emoji: '🚑',
          gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          name: 'Emergency Services',
          sub: 'Auto-dispatched on detection · 911',
          actionIcon: '⚙️',
          divider: false,
        ),
      ]),
    );
  }

  Widget _contactTile({
    required String emoji,
    required List<Color> gradient,
    required String name,
    required String sub,
    String? priority,
    Color? priorityColor,
    String actionIcon = '📞',
    required bool divider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: divider
          ? BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05))))
          : null,
      child: Row(children: [
        // Avatar
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(name,
                    style: inter(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                if (priority != null && priorityColor != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(priority,
                        style: inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: priorityColor,
                            letterSpacing: 0.5)),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text(sub,
                  style: inter(
                      fontSize: 10,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
        // Action button
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.bluePrimary.withValues(alpha: 0.15),
            border: Border.all(
                color: AppColors.blueLight.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(actionIcon,
              style: const TextStyle(fontSize: 15)),
        ),
      ]),
    );
  }

  // ── LAST INCIDENT CARD ───────────────────────────────

  Widget _buildIncidentCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            context: context,
            icon: '🔍',
            iconBg: AppColors.green.withValues(alpha: 0.12),
            title: 'Last Incident',
            action: 'History',
            onPressed: () {},
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.green.withValues(alpha: 0.08),
                  AppColors.green.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(
                  color: AppColors.green.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text('✅',
                    style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No Incident Detected',
                        style: inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    RichText(
                      text: TextSpan(
                        style: inter(
                            fontSize: 11,
                            color: AppColors.textSecondary),
                        children: [
                          const TextSpan(text: 'Status: '),
                          TextSpan(
                            text: 'All Clear',
                            style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: ' · Monitoring 24h'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('09:41 AM',
                      style: inter(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                  Text('LAST CHECK',
                      style: inter(
                          fontSize: 9,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5)),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ── SHARED CARD HELPERS ──────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _cardHeader({
  required BuildContext context,
  required String icon,
  required Color iconBg,
  required String title,
  required String action,
  required VoidCallback? onPressed,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: inter(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
      GestureDetector(
        onTap: onPressed, // ✅ FIXED
        child: Text(action,
            style: inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.blueLight)),
      ),
    ],
  );
}

  // ── BOTTOM NAVIGATION ────────────────────────────────

  Widget _buildBottomNav() {
    final items = [
      {'icon': '🏠', 'label': 'Home'},
      {'icon': '📋', 'label': 'History'},
      {'icon': '👤', 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
              color: AppColors.blueLight.withValues(alpha: 0.12)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top accent line
            Center(
              child: Container(
                width: 36,
                height: 2,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    AppColors.blueLight,
                    Colors.transparent,
                  ]),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  final active = _navIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _navIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.bluePrimary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: active ? 1.0 : 0.35,
                            child: Text(items[i]['icon']!,
                                style:
                                    const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(height: 4),
                          Text(items[i]['label']!,
                              style: inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? AppColors.blueLight
                                    : AppColors.textMuted,
                                letterSpacing: 0.3,
                              )),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ══════════════════════════════════════════════════════

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.06)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => false;
}
