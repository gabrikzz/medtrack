import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medtrack/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart'; // 👈 NEW

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {

  String userCity = "";
  String searchQuery = "";
  bool loadingCity = true;

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

    if (!mounted) return;

    setState(() {
      userCity = (doc.data()?['location'] ?? "")
          .toString()
          .toLowerCase()
          .trim();
      loadingCity = false;
    });
  }

  
  Future<void> callClinic(String phone) async {
    final Uri phoneUri = Uri.parse("tel:$phone");

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot open phone app")),
      );
    }
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

            Text(
              loc.appointmentsTitle,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              userCity,
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 20),

            
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
                    searchQuery = value.toLowerCase().trim();
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: loadingCity
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('clinics')
                          .snapshots(),
                      builder: (context, snapshot) {

                        if (!snapshot.hasData) {
                          return Center(child: Text(loc.noClinics));
                        }

                        final clinics = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final name = (data['name'] ?? "")
                              .toString()
                              .toLowerCase()
                              .trim();

                          final city = (data['city'] ?? "")
                              .toString()
                              .toLowerCase()
                              .trim();

                          final matchesSearch =
                              searchQuery.isEmpty || name.contains(searchQuery);

                          final matchesCity =
                              userCity.isEmpty || city.contains(userCity);

                          return matchesSearch && matchesCity;
                        }).toList();

                        if (clinics.isEmpty) {
                          return Center(child: Text(loc.noClinics));
                        }

                        return ListView.builder(
                          itemCount: clinics.length,
                          itemBuilder: (context, index) {
                            final data =
                                clinics[index].data() as Map<String, dynamic>;

                            return _clinicCard(
                              name: data['name'] ?? "",
                              address: data['address'] ?? data['adress'] ?? "",
                              phone: data['phone'] ?? "",
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

  Widget _clinicCard({
    required String name,
    required String address,
    required String phone,
  }) {
    return GestureDetector(
      onTap: () => callClinic(phone),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_hospital, color: Colors.teal),
            ),

            const SizedBox(width: 14),

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

            const Icon(Icons.phone, color: Colors.teal),
          ],
        ),
      ),
    );
  }
}