import 'package:flutter/material.dart';
import 'package:medtrack/l10n/app_localizations.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../screens/success_screen.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  State<DoctorRegisterScreen> createState() =>
      _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final specController = TextEditingController();
  final licenseController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final locationController = TextEditingController();

  String selectedSex = "Male";

  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();

  bool loading = false;
  bool isPasswordHidden = true;

  Future<void> registerDoctor() async {
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

      final confirm = await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(loc.confirmData),
          content: Text(
            "${loc.fullName}: ${nameController.text}\n"
            "${loc.specialization}: ${specController.text}\n"
            "${loc.license}: ${licenseController.text}\n"
            "${loc.email}: ${emailController.text}\n"
            "${loc.sex}: $selectedSex\n"
            "${loc.location}: ${locationController.text}\n\n"
            "${loc.isCorrect}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(loc.edit),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(loc.yes),
            ),
          ],
        ),
      );

      if (confirm != true) {
        if (mounted) setState(() => loading = false);
        return;
      }

      final newUser = UserModel(
        uid: user.uid,
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        birthDate: "",
        idnp: licenseController.text.trim(),
        bloodType: "N/A",
        role: "doctor",
        sex: selectedSex,
        location: locationController.text.trim(),
      );

      await firestoreService.createUser(newUser);

      if (!mounted) return;

      showSuccess(loc.doctorCreated);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessScreen()),
      );

    } catch (e) {
      showError(loc.registerFailed);
    }

    if (mounted) setState(() => loading = false);
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
      fillColor: Colors.grey[100],
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    specController.dispose();
    licenseController.dispose();
    emailController.dispose();
    passwordController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.doctorRegistration,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              const SizedBox(height: 20),

              const Icon(
                Icons.medical_services,
                size: 60,
                color: Color(0xFF2B7CFF),
              ),

              const SizedBox(height: 20),

              Text(
                loc.professionalAccount,
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: nameController,
                decoration: fieldStyle(loc.doctorName),
                validator: (v) =>
                    v == null || v.isEmpty ? loc.enterName : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: specController,
                decoration: fieldStyle(loc.specialization),
                validator: (v) =>
                    v == null || v.isEmpty ? loc.enterSpecialization : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: licenseController,
                decoration: fieldStyle(loc.license),
                validator: (v) =>
                    v == null || v.isEmpty ? loc.enterLicense : null,
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

              DropdownButtonFormField<String>(
                value: selectedSex,
                decoration: fieldStyle(loc.sex),
                items: ["Male", "Female"]
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
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

              const SizedBox(height: 30),

              loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(18),
                        backgroundColor: const Color(0xFF62B97C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: registerDoctor,
                      child: Text(
                        loc.createDoctorAccount,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}