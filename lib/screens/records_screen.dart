import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {

  String selectedFilter = "All";

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Medical Records"),
      ),

      body: Column(
        children: [

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _filterChip("All"),
                _filterChip("Diagnosis"),
                _filterChip("Test Result"),
                _filterChip("Medication"),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('documents')
                  .where('patientId', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No documents yet"));
                }

                final filteredDocs = docs.where((doc) {
                  if (selectedFilter == "All") return true;
                  return doc['type'] == selectedFilter;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {

                    final doc = filteredDocs[index];
                    final date = doc['createdAt']?.toDate();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: Icon(_getIcon(doc['type'])),
                        title: Text(doc['type']),
                        subtitle: Text(
                          date != null
                              ? "${date.day}.${date.month}.${date.year}"
                              : "No date",
                        ),
                        trailing: const Icon(Icons.open_in_new),

                        onTap: () async {
                          final url = doc['fileUrl'];

                          if (url != null) {
                            final uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          }
                        },
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
  }

  Widget _filterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedFilter == label,
        onSelected: (_) {
          setState(() => selectedFilter = label);
        },
      ),
    );
  }

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