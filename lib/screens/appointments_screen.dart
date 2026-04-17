import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medtrack/l10n/app_localizations.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {

  String userCity = "";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadUserCity();
  }

  Future<void> loadUserCity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      userCity = doc.data()?['location'] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 HEADER (как в HomeScreen)
            Text(
              loc.appointmentsTitle,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              userCity.isEmpty ? "" : userCity,
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 20),

            // 🔍 SEARCH BAR
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: loc.searchClinic,
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // 🏥 LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('clinics')
                    .where('city', isEqualTo: userCity)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return Center(child: Text(loc.noClinics));
                  }

                  final clinics = snapshot.data!.docs.where((doc) {
                    final name = doc['name']
                        .toString()
                        .toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  if (clinics.isEmpty) {
                    return Center(child: Text(loc.noClinics));
                  }

                  return ListView.builder(
                    itemCount: clinics.length,
                    itemBuilder: (context, index) {

                      final data = clinics[index];

                      return _clinicCard(
                        name: data['name'],
                        address: data['address'],
                        phone: data['phone'],
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // 🎨 КРАСИВАЯ КАРТОЧКА (как в приложении)
  Widget _clinicCard({
    required String name,
    required String address,
    required String phone,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [

          // ICON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_hospital, color: Colors.teal),
          ),

          const SizedBox(width: 14),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  address,
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 4),

                Text(
                  phone,
                  style: const TextStyle(color: Colors.teal),
                ),
              ],
            ),
          ),

          // ARROW
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}