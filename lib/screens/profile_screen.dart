import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:medtrack/l10n/app_localizations.dart';
import 'package:medtrack/main.dart';
import '../screens/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = false;

  Future<DocumentSnapshot?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      notificationsEnabled = data?['notifications'] ?? false;
    }

    return doc;
  }

  Future<void> updateNotifications(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => notificationsEnabled = value);

    final messaging = FirebaseMessaging.instance;

    if (value) {
      await messaging.requestPermission();
      String? token = await messaging.getToken();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'notifications': true,
        'fcmToken': token,
      });

      await messaging.subscribeToTopic("general");
    } else {
      await messaging.unsubscribeFromTopic("general");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'notifications': false,
      });
    }
  }

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

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(loc.profile, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<DocumentSnapshot?>(
        future: getUserData(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No user data"));
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("User not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          String getValue(String key) => data[key]?.toString() ?? "-";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue,
                  child: Text(
                    getValue('fullName').isNotEmpty
                        ? getValue('fullName')[0]
                        : "?",
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  getValue('fullName'),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),

                Text(
                  getValue('email'),
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                _buildCard(
                  title: loc.personalInfo,
                  child: Column(
                    children: [
                      _row(loc.fullName, getValue('fullName')),
                      _row(loc.birthDate, getValue('birthDate')),
                      _row(loc.sex, getValue('sex')),
                      _row(loc.location, getValue('location')),
                      _row(loc.bloodType, getValue('bloodType')),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _buildCard(
                  title: loc.settings,
                  child: Column(
                    children: [
                      _settingTile(
                        icon: Icons.language,
                        title: loc.language,
                        onTap: () => _showLanguageDialog(context),
                      ),

                      SwitchListTile(
                        value: notificationsEnabled,
                        onChanged: updateNotifications,
                        title: Text(loc.notifications),
                        secondary: const Icon(Icons.notifications, color: Colors.blue),
                      ),

                      _settingTile(
                        icon: Icons.lock,
                        title: loc.changePassword,
                        onTap: showChangePasswordDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🚪 LOGOUT (FIXED)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    loc.signOut,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: logout,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }

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