import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:medtrack/screens/welcome_screen.dart';
import 'package:medtrack/screens/home_screen.dart';
import 'package:medtrack/screens/doctor_home_screen.dart';
import 'package:medtrack/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MedTrackApp());
}

class MedTrackApp extends StatefulWidget {
  const MedTrackApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    final _MedTrackAppState? state =
        context.findAncestorStateOfType<_MedTrackAppState>();
    state?.setLocale(locale);
  }

  @override
  State<MedTrackApp> createState() => _MedTrackAppState();
}

class _MedTrackAppState extends State<MedTrackApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  Locale _resolveLocale(Locale? deviceLocale) {
    if (_locale != null) return _locale!;

    if (deviceLocale != null) {
      for (var locale in _supportedLocales) {
        if (locale.languageCode == deviceLocale.languageCode) {
          return locale;
        }
      }
    }

    return const Locale('en');
  }

  final List<Locale> _supportedLocales = const [
    Locale('en'),
    Locale('ru'),
    Locale('ro'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MedTrack",
      debugShowCheckedModeBanner: false,

      locale: _locale,
      supportedLocales: _supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        return _resolveLocale(deviceLocale);
      },

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        primaryColor: const Color(0xFF0A84FF),
        scaffoldBackgroundColor: Colors.white,
      ),

      // 🔥 AUTH-BASED NAVIGATION
      home: const AuthWrapper(),
    );
  }
}

// 🔥 AUTH WRAPPER (FINAL CLEAN VERSION)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return doc.data()?['role'];
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {

        // ⏳ AUTH LOADING
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ NOT LOGGED IN
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const WelcomeScreen();
        }

        final user = authSnapshot.data!;

        // 🔥 ROLE LOADING
        return FutureBuilder<String?>(
          future: getUserRole(user.uid),
          builder: (context, roleSnapshot) {

            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;

            // ❌ ROLE MISSING → FORCE LOGOUT (prevents bugs)
            if (role == null) {
              FirebaseAuth.instance.signOut();
              return const WelcomeScreen();
            }

            // ✅ ROLE-BASED NAVIGATION
            if (role == 'doctor') {
              return const DoctorHomeScreen();
            } else {
              return const HomeScreen();
            }
          },
        );
      },
    );
  }
}