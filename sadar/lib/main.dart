import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sadar/pages/login_page.dart';
import 'package:sadar/screens/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Firebase ────────────────────
  try {
    await Firebase.initializeApp();
    developer.log('Firebase init completed', name: 'AppInit');

    // ── Temporary connection test ─────────────
    testFirebaseConnection();
  } catch (e, st) {
    developer.log(
      'Firebase init FAILED: $e',
      name: 'AppInit',
      error: e,
      stackTrace: st,
    );
    runApp(_ErrorApp(message: 'Firebase init failed:\n$e'));
    return;
  }

  runApp(const MyApp());
}

/// Temporary function to verify Firebase connection.
/// Remove this after confirming Firebase works correctly.
void testFirebaseConnection() {
  try {
    final user = FirebaseAuth.instance.currentUser;
    debugPrint('✅ Firebase connected successfully.');
    debugPrint('Current user: $user');
  } catch (e) {
    debugPrint('❌ Firebase connection failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is already authenticated
    final currentUser = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'SADAR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: currentUser != null ? const DashboardScreen() : LoginScreen(),
    );
  }
}

/// Minimal error screen shown when initialization fails.
class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF060E1D),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
