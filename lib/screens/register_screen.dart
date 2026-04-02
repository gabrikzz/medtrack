import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../screens/success_screen.dart';

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

  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();

  bool loading = false;
  bool isPasswordHidden = true;

  Future<void> registerUser() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {

      final user = await authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (user != null) {

        final confirm = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Confirm Data"),
            content: Text(
              "Name: ${nameController.text}\n"
              "Email: ${emailController.text}\n"
              "IDNP: ${idnpController.text}\n"
              "DOB: ${dobController.text}\n"
              "Blood Type: ${bloodTypeController.text.isEmpty ? "Not specified" : bloodTypeController.text}\n\nIs this correct?"
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Edit"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes"),
              ),
            ],
          ),
        );

        if (confirm != true) {
          setState(() => loading = false);
          return;
        }

        final newUser = UserModel(
          uid: user.uid,
          name: nameController.text,
          email: emailController.text,
          dob: dobController.text,
          idnp: idnpController.text,
          bloodType: bloodTypeController.text.isEmpty
              ? "Unknown"
              : bloodTypeController.text,

          role: "user", 
        );

        await firestoreService.createUser(newUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
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
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [

                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Sign up to get started",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: nameController,
                  decoration: fieldStyle("Full Name"),
                  validator: (v) => v!.isEmpty ? "Enter name" : null,
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
                  controller: idnpController,
                  keyboardType: TextInputType.number,
                  decoration: fieldStyle("IDNP"),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter IDNP";
                    if (v.length != 13) return "IDNP must be 13 digits";
                    if (!RegExp(r'^[0-9]+$').hasMatch(v)) return "Only numbers allowed";
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: isPasswordHidden,
                  decoration: fieldStyle("Password").copyWith(
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
                      v!.length < 6 ? "Min 6 chars" : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  onTap: pickDate,
                  decoration: fieldStyle("Date of Birth").copyWith(
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: bloodTypeController,
                  decoration: fieldStyle("Blood Type (optional)"),
                ),

                const SizedBox(height: 30),

                loading
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                        onTap: registerUser,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2D9CDB),
                                Color(0xFF2F80ED),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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