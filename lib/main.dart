import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medtrack/screens/welcome_screen.dart';
// ignore: unused_import
import 'package:medtrack/models/user_model.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();

  runApp(const MedTrackApp());
}

class MedTrackApp extends StatelessWidget {
  const MedTrackApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MedTrack",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0A84FF),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const WelcomeScreen(),
    );
  }
}