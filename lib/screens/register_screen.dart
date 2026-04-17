import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medtrack/l10n/app_localizations.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final dobController = TextEditingController();
  final idnpController = TextEditingController();
  final bloodTypeController = TextEditingController();
  final locationController = TextEditingController();

  String selectedSex = "Male";

  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();

  bool loading = false;
  bool isPasswordHidden = true;

  

  Future<void> registerUser() async {
    final loc = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = await authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (user == null) {
        showError(loc.registerFailed);
        return;
      }

     
      await user.sendEmailVerification();

      final newUser = UserModel(
        uid: user.uid,
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        birthDate: dobController.text.trim(),
        idnp: idnpController.text.trim(),
        bloodType: bloodTypeController.text.isEmpty
            ? "Unknown"
            : bloodTypeController.text.trim(),
        role: "user",
        sex: selectedSex,
        location: locationController.text.trim(),
      );

      await firestoreService.createUser(newUser);

      
      _showVerifyDialog(user);

    } catch (e) {
      showError(e.toString());
    }

    if (mounted) setState(() => loading = false);
  }



  void _showVerifyDialog(User user) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(loc.verifyEmailTitle),

     
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.verifyEmailMessage),
            const SizedBox(height: 10),
            Text(emailController.text.trim()),
            const SizedBox(height: 10),
            Text(
              loc.checkEmailSpam,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),

        actions: [

         
          TextButton(
            onPressed: () async {
              try {
                await user.sendEmailVerification();
                showSuccess(loc.verificationSentAgain);
              } catch (e) {
                showError(loc.error);
              }
            },
            child: Text(loc.resend),
          ),

         
          ElevatedButton(
            onPressed: () async {
              try {
                await user.reload();

                if (user.emailVerified) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                } else {
                  showError(loc.emailNotVerified);
                }
              } catch (e) {
                showError(e.toString());
              }
            },
            child: Text(loc.iVerified),
          ),
        ],
      ),
    );
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

  InputDecoration fieldStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> pickDate() async {
    final loc = AppLocalizations.of(context)!;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: loc.selectDate,
    );

    if (pickedDate != null) {
      dobController.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      setState(() {});
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    dobController.dispose();
    idnpController.dispose();
    bloodTypeController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Form(
            key: _formKey,

            child: ListView(
              children: [

                const SizedBox(height: 20),

                Text(
                  loc.createAccount,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  loc.signUpSubtitle,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: nameController,
                  decoration: fieldStyle(loc.fullName),
                  validator: (v) =>
                      v == null || v.isEmpty ? loc.enterName : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: emailController,
                  decoration: fieldStyle(loc.email),
                  validator: (v) =>
                      v != null && v.contains("@") ? null : loc.invalidEmail,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: idnpController,
                  keyboardType: TextInputType.number,
                  decoration: fieldStyle(loc.idnp),
                  validator: (v) {
                    if (v == null || v.isEmpty) return loc.enterIdnp;
                    if (v.length != 13) return loc.idnpLength;
                    if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                      return loc.onlyNumbers;
                    }
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
                  validator: (v) =>
                      v != null && v.length >= 6 ? null : loc.passwordMin,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  onTap: pickDate,
                  decoration: fieldStyle(loc.birthDate).copyWith(
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedSex,
                  decoration: fieldStyle(loc.sex),
                  items: ["Male", "Female"]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSex = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: locationController,
                  decoration: fieldStyle(loc.location),
                  validator: (v) =>
                      v == null || v.isEmpty ? loc.enterLocation : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: bloodTypeController,
                  decoration: fieldStyle(loc.bloodTypeOptional),
                ),

                const SizedBox(height: 30),

                loading
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                        onTap: registerUser,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2D9CDB),
                                Color(0xFF2F80ED),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              loc.signUp,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}