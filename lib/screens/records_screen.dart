import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medtrack/l10n/app_localizations.dart';

// 🔥 FIX: правильный фильтр (НЕ зависит от языка)
enum FilterType { all, diagnosis, medication }

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  // 🔥 FIX
  FilterType selectedFilter = FilterType.all;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.records),
        centerTitle: true,
      ),
      body: Column(
        children: [

          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                _filterChip(loc.all, FilterType.all),
                _filterChip(loc.diagnosis, FilterType.diagnosis),
                _filterChip(loc.medication, FilterType.medication),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('documents')
                  .where('patientId', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {

                // 🔥 FIX: правильная проверка loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(loc.noRecords));
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final type = data['type'] ?? '';

                  // 🔥 FIX: фильтр НЕ зависит от языка
                  if (selectedFilter == FilterType.all) return true;
                  if (selectedFilter == FilterType.diagnosis && type == "Diagnosis") return true;
                  if (selectedFilter == FilterType.medication && type == "Medication") return true;

                  return false;
                }).toList();

                if (docs.isEmpty) {
                  return Center(child: Text(loc.noRecords));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final data = docs[index].data() as Map<String, dynamic>;

                    // 🔥 FIX: безопасный timestamp
                    final ts = data['createdAt'] as Timestamp?;

                    if (ts == null) {
                      return const SizedBox(); // не крашится
                    }

                    final date = ts.toDate();

                    return Card(
                      child: ListTile(
                        title: Text(
                          data['title'] ??
                              _translateType(data['type'] ?? '', loc),
                        ),
                        subtitle: Text(
                          "${date.day}.${date.month}.${date.year}",
                        ),

                        onTap: () async {
                          final url = data['fileUrl'];

                          if (url != null) {
                            final uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(data['title'] ?? "Medication"),
                                content: Text(
                                  data['dosage'] ?? "Medication added by doctor",
                                ),
                              ),
                            );
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

  // 🔥 FIX: правильный chip
  Widget _filterChip(String label, FilterType type) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedFilter == type,
        onSelected: (_) {
          setState(() => selectedFilter = type);
        },
      ),
    );
  }

  String _translateType(String type, AppLocalizations loc) {
    switch (type) {
      case "Diagnosis":
        return loc.diagnosis;
      case "Medication":
        return loc.medication;
      default:
        return type;
    }
  }
}