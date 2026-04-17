import 'package:flutter/material.dart';
import 'package:medtrack/l10n/app_localizations.dart';
import 'package:medtrack/main.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'doctor_register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [

              // 🔥 LANGUAGE BUTTON (TOP RIGHT)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () => _showLanguageDialog(context),
                ),
              ),

              const Spacer(),

              Image.asset(
                "assets/images/logo.png",
                width: 120,
              ),

              const SizedBox(height: 20),

              Text(
                loc.appName,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                loc.appSlogan,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 80),

              // 🔹 SIGN IN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: const Color(0xFF2B7CFF),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    loc.signIn,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 CREATE ACCOUNT
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Color(0xFF2B7CFF)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text(
                    loc.createAccount,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(loc.or),

              const SizedBox(height: 20),

              // 🔹 DOCTOR REGISTER
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Colors.green),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorRegisterScreen(),
                      ),
                    );
                  },
                  child: Text(
                    loc.registerDoctor,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 LANGUAGE DIALOG (GLOBAL CHANGE)
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choose language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("English"),
              onTap: () {
                MedTrackApp.setLocale(context, const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Русский"),
              onTap: () {
                MedTrackApp.setLocale(context, const Locale('ru'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Română"),
              onTap: () {
                MedTrackApp.setLocale(context, const Locale('ro'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}