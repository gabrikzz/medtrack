import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medtrack/l10n/app_localizations.dart';

import '../screens/home_screen.dart';
import '../screens/doctor_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication auth = LocalAuthentication();

  bool isPasswordHidden = true;
  bool loading = false;

  // 🔥 NEW
  bool emailSent = false;

  @override
  void initState() {
    super.initState();
    checkUserLoggedIn();
  }

  Future<void> checkUserLoggedIn() async {
    final loc = AppLocalizations.of(context)!;
    final user = _auth.currentUser;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!doc.exists) return;

        final role = doc.data()?['role'] ?? "user";

        if (!mounted) return;

        if (role == "doctor") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }

      } catch (e) {
        showError(loc.errorLoadUser);
      }
    }
  }

  Future<void> login() async {
    final loc = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;

      if (user == null) {
        showError(loc.loginFailed);
        return;
      }

      await _handleUserAfterLogin(user);

    } on FirebaseAuthException catch (e) {
      showError(getMessageFromError(e.code, loc));
    } catch (e) {
      showError(loc.somethingWentWrong);
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> signInWithGoogle() async {
    final loc = AppLocalizations.of(context)!;

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) return;

      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final doc = await userDoc.get();

      if (!doc.exists) {
        await userDoc.set({
          'fullName': user.displayName ?? "User",
          'email': user.email,
          'role': 'user',
        });
      }

      await _handleUserAfterLogin(user);

    } catch (e) {
      showError(loc.somethingWentWrong);
    }
  }

  Future<void> _handleUserAfterLogin(User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final role = doc.data()?['role'] ?? "user";

    if (!mounted) return;

    if (role == "doctor") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // 🔥 UPDATED RESET PASSWORD
  Future<void> resetPassword() async {
    final loc = AppLocalizations.of(context)!;

    if (emailController.text.isEmpty) {
      showError(loc.enterEmailFirst);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      setState(() {
        emailSent = true;
      });

      showSuccess(loc.resetEmailSent);

    } catch (e) {
      showError(loc.resetEmailFailed);
    }
  }

  // 🔥 RESEND EMAIL
  Future<void> resendEmail() async {
    final loc = AppLocalizations.of(context)!;

    try {
      await _auth.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      showSuccess(loc.resetEmailSent);

    } catch (e) {
      showError(loc.resetEmailFailed);
    }
  }

  Future<void> biometricLogin() async {
  final loc = AppLocalizations.of(context)!;

  try {
    // 🔥 Проверка устройства
    final canCheck = await auth.canCheckBiometrics;
    final isSupported = await auth.isDeviceSupported();

    if (!canCheck || !isSupported) {
      showError(loc.biometricNotAvailable);
      return;
    }

    // 🔥 Проверка есть ли методы (FaceID / Fingerprint)
    final availableBiometrics = await auth.getAvailableBiometrics();

    if (availableBiometrics.isEmpty) {
      showError(loc.biometricNotAvailable);
      return;
    }

    // 🔥 Проверка есть ли пользователь
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showError(loc.loginFirst);
      return;
    }

    // 🔥 Запрос биометрии
    final authenticated = await auth.authenticate(
      localizedReason: loc.biometricReason,
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (authenticated) {
      await checkUserLoggedIn();
    }

  } catch (e) {
    showError(loc.biometricError);
  }
}

  void showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(message)),
    );
  }

  void showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text(message)),
    );
  }

  String getMessageFromError(String code, AppLocalizations loc) {
    switch (code) {
      case 'user-not-found':
        return loc.userNotFound;
      case 'wrong-password':
        return loc.wrongPassword;
      case 'invalid-email':
        return loc.invalidEmail;
      default:
        return loc.loginFailed;
    }
  }

  InputDecoration fieldStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              Text(
                loc.welcomeBack,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                loc.signInSubtitle,
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: emailController,
                decoration: fieldStyle(loc.email),
                validator: (v) {
                  if (v == null || v.isEmpty) return loc.emailRequired;
                  if (!v.contains("@")) return loc.invalidEmail;
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: isPasswordHidden,
                decoration: fieldStyle(loc.password).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return loc.passwordRequired;
                  if (v.length < 6) return loc.passwordMin;
                  return null;
                },
              ),

              const SizedBox(height: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: resetPassword,
                      child: Text(loc.forgotPassword),
                    ),
                  ),

                  if (emailSent)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          loc.checkEmailSpam,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.right,
                        ),

                        TextButton(
                          onPressed: resendEmail,
                          child: Text(loc.resendEmail),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 20),

              loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(18),
                          backgroundColor: const Color(0xFF2B7CFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: login,
                        child: Text(
                          loc.signIn,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

              const SizedBox(height: 30),

              Center(child: Text(loc.or)),

              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [

                    SizedBox(
                      width: 250,
                      child: OutlinedButton.icon(
                        onPressed: biometricLogin,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(loc.biometricLogin),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: 250,
                      child: OutlinedButton.icon(
                        onPressed: signInWithGoogle,
                        icon: const Icon(Icons.login),
                        label: const Text("Sign in with Google"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}