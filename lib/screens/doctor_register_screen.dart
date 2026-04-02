import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../screens/success_screen.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {

  final nameController = TextEditingController();
  final specController = TextEditingController();
  final licenseController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();

  bool loading = false;

  Future<void> registerDoctor() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {

      final user = await authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (user != null) {

        final newUser = UserModel(
          uid: user.uid,
          name: nameController.text,
          email: emailController.text,
          dob: "", // врачу не обязательно
          idnp: licenseController.text, // можно использовать как ID
          bloodType: "N/A",
          role: "doctor", // 🔥 ВАЖНО
        );

        await firestoreService.createUser(newUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Doctor account created")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SuccessScreen()),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => loading = false);
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
  void dispose() {
    nameController.dispose();
    specController.dispose();
    licenseController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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

              const Text(
                "Doctor Registration",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                "Create your professional account",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: nameController,
                decoration: fieldStyle("Dr. Full Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: specController,
                decoration: fieldStyle("Specialization"),
                validator: (v) => v!.isEmpty ? "Enter specialization" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: licenseController,
                decoration: fieldStyle("License number"),
                validator: (v) => v!.isEmpty ? "Enter license" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                decoration: fieldStyle("Email"),
                validator: (v) =>
                    v!.contains("@") ? null : "Invalid email",
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: fieldStyle("Password"),
                validator: (v) =>
                    v!.length < 6 ? "Min 6 characters" : null,
              ),

              const SizedBox(height: 30),

              loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(18),
                          backgroundColor: const Color(0xFF62B97C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: registerDoctor,
                        child: const Text(
                          "Create Doctor Account",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}