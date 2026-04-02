import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 ИМПОРТ ЭКРАНОВ
import 'records_screen.dart';
import 'tests_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    final screens = [
      const HomeContent(),
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
        onTap: (index) {
          setState(() => selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined), label: "Records"),
          BottomNavigationBarItem(
              icon: Icon(Icons.science_outlined), label: "Tests"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////
/// 🟦 HOME CONTENT
////////////////////////////////////////////////////////

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return SafeArea(
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  "Good morning",
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 4),

                Text(
                  data['name'] ?? "User",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // 🟦 USER CARD
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

                      const Text(
                        "PATIENT",
                        style: TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        data['name'] ?? "Unknown",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _info("AGE", data['age']?.toString() ?? "N/A"),
                          _info("BLOOD", data['bloodType'] ?? "-"),
                          _info("IDNP", data['idnp'] ?? "-"),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ⚡ QUICK ACTIONS
                const Text(
                  "Quick Actions",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    _actionCard(
                      icon: Icons.description_outlined,
                      title: "Records",
                      onTap: () => _open(context, const RecordsScreen()),
                    ),

                    _actionCard(
                      icon: Icons.science_outlined,
                      title: "Tests",
                      onTap: () => _open(context, const TestsScreen()),
                    ),

                    _actionCard(
                      icon: Icons.person_outline,
                      title: "Profile",
                      onTap: () => _open(context, const ProfileScreen()),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 📋 RECENT ACTIVITY
                const Text(
                  "Recent Activity",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

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

                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return const Text("No activity yet");
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {

                          final doc = docs[index];
                          final date = doc['createdAt']?.toDate();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: Icon(_getIcon(doc['type'])),
                              title: Text(doc['type'] ?? "Unknown"),
                              subtitle: Text(
                                date != null
                                    ? "${date.day}.${date.month}.${date.year}"
                                    : "No date",
                              ),
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

  // 🔹 OPEN SCREEN
  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // 🔹 INFO WIDGET
  Widget _info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  // 🔹 ACTION CARD
  Widget _actionCard({
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
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 ICON LOGIC
  IconData _getIcon(String type) {
    switch (type) {
      case "Diagnosis":
        return Icons.description;
      case "Test Result":
        return Icons.science;
      case "Medication":
        return Icons.medication;
      default:
        return Icons.insert_drive_file;
    }
  }
}