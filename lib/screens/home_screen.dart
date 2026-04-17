import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medtrack/l10n/app_localizations.dart';

import 'records_screen.dart';
import 'tests_screen.dart';
import 'profile_screen.dart';
import 'appointments_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final screens = [
      const HomeContent(),
      const AppointmentsScreen(),
      const RecordsScreen(),
      const TestsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(selectedIndex),
          child: screens[selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: loc.home),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: loc.appointments),
          BottomNavigationBarItem(icon: const Icon(Icons.description_outlined), label: loc.records),
          BottomNavigationBarItem(icon: const Icon(Icons.science_outlined), label: loc.tests),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: loc.profile),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  DateTime? parseBirthDate(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return null;

    try {
      final parts = birthDate.split("/"); // [day, month, year]

      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text(loc.notLoggedIn));
    }

    final uid = user.uid;

    return SafeArea(
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text(loc.userNotFound));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          String name = data['fullName'] ?? loc.user;

          String ageText = "-";

          final birthDateString = data['birthDate'];

          if (birthDateString != null) {
            final birthDate = parseBirthDate(birthDateString);

            if (birthDate != null) {
              final age = calculateAge(birthDate);
              ageText = age.toString();
            }
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(loc.healthGlance, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 4),

                Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3BA5A4), Color(0xFF2F80ED)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(loc.patient, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),

                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _info(loc.age, ageText),
                          _info(loc.blood, data['bloodType'] ?? "-"),
                          _info(loc.idnp, data['idnp'] ?? "-"),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Text(loc.quickActions, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionCard(
                      icon: Icons.description_outlined,
                      title: loc.records,
                      onTap: () => _open(context, const RecordsScreen()),
                    ),
                    _actionCard(
                      icon: Icons.science_outlined,
                      title: loc.tests,
                      onTap: () => _open(context, const TestsScreen()),
                    ),
                    _actionCard(
                      icon: Icons.person_outline,
                      title: loc.profile,
                      onTap: () => _open(context, const ProfileScreen()),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Text(loc.recentActivity, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('documents')
                        .where('patientId', isEqualTo: uid)
                        .orderBy('createdAt', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text(loc.noActivity);
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {

                          final data = docs[index].data() as Map<String, dynamic>;

                          final ts = data['createdAt'] as Timestamp?;
                          if (ts == null) return const SizedBox();

                          final date = ts.toDate();
                          final type = data['type'] ?? "";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: Icon(_getIcon(type)),
                              title: Text(_getTitle(type, loc)),
                              subtitle: Text("${date.day}.${date.month}.${date.year}"),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  static String _getTitle(String type, AppLocalizations loc) {
    switch (type) {
      case "Diagnosis":
        return loc.activityDiagnosis;
      case "Test":
        return loc.activityTest;
      case "Medication":
        return loc.activityMedication;
      default:
        return loc.activityFile;
    }
  }

  static IconData _getIcon(String type) {
    switch (type) {
      case "Diagnosis":
        return Icons.description;
      case "Test":
        return Icons.science;
      case "Medication":
        return Icons.medication;
      default:
        return Icons.insert_drive_file;
    }
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static Widget _info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  static Widget _actionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.teal),
            const SizedBox(height: 6),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}