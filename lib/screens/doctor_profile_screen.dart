import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:medtrack/l10n/app_localizations.dart';
import 'package:medtrack/main.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {

  final user = FirebaseAuth.instance.currentUser;

  bool notificationsEnabled = false;
  late Future<Map<String, dynamic>?> doctorFuture;

  @override
  void initState() {
    super.initState();
    doctorFuture = getDoctorData();
  }

  Future<Map<String, dynamic>?> getDoctorData() async {
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final data = doc.data();

    if (data != null) {
      notificationsEnabled = data['notifications'] ?? false;
    }

    return data;
  }

  Future<void> updateNotifications(bool value) async {
    final loc = AppLocalizations.of(context)!;

    if (user == null) return;

    final messaging = FirebaseMessaging.instance;

    try {
      if (value) {
        await messaging.requestPermission();
        String? token = await messaging.getToken();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
          'notifications': true,
          'fcmToken': token,
        });

        await messaging.subscribeToTopic("general");
      } else {
        await messaging.unsubscribeFromTopic("general");

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
          'notifications': false,
        });
      }

      if (mounted) {
        setState(() => notificationsEnabled = value);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.error)),
      );
    }
  }

  void _showLanguageDialog() {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.language),
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

  // 🔐 CHANGE PASSWORD
  void showChangePasswordDialog() {
    final loc = AppLocalizations.of(context)!;

    final currentController = TextEditingController();
    final newController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: InputDecoration(labelText: loc.currentPassword),
            ),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: InputDecoration(labelText: loc.newPassword),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser!;

                final cred = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentController.text,
                );

                await user.reauthenticateWithCredential(cred);
                await user.updatePassword(newController.text);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.passwordUpdated)),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.errorPassword)),
                );
              }
            },
            child: Text(loc.confirm),
          ),
        ],
      ),
    );
  }

  // 🚪 FIXED LOGOUT (IMPORTANT)
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    // 🔥 THIS LINE FIXES YOUR BUG
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MedTrackApp()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[100],
        title: Text(
          loc.profile,
          style: const TextStyle(color: Colors.black),
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: doctorFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(loc.error));
          }

          final data = snapshot.data!;
          final name = data['fullName'] ?? loc.unknown;
          final email = data['email'] ?? user?.email ?? '';

          return Column(
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.green[100],
                      child: const Icon(Icons.person,
                          size: 40, color: Colors.green),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [

                    ListTile(
                      leading: const Icon(Icons.language, color: Colors.green),
                      title: Text(loc.language),
                      onTap: _showLanguageDialog,
                    ),

                    const Divider(),

                    SwitchListTile(
                      value: notificationsEnabled,
                      onChanged: updateNotifications,
                      title: Text(loc.notifications),
                      secondary: const Icon(Icons.notifications, color: Colors.green),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.lock, color: Colors.green),
                      title: Text(loc.changePassword),
                      onTap: showChangePasswordDialog,
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        loc.signOut,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: signOut,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}