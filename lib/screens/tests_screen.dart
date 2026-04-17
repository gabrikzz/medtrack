import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medtrack/l10n/app_localizations.dart';

class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    // 🔥 FIX: защита если user == null
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.testResults),
          centerTitle: true,
        ),
        body: Center(child: Text(loc.notLoggedIn)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.testResults),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('documents')
            .where('patientId', isEqualTo: user.uid)
            .where('type', isEqualTo: "Test")
            .snapshots(),
        builder: (context, snapshot) {

          // 🔥 FIX: правильный loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(loc.noTests));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data = docs[index].data() as Map<String, dynamic>;

              
              final ts = data['createdAt'] as Timestamp?;
              if (ts == null) {
                return const SizedBox();
              }

              final date = ts.toDate();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.science),

                  title: Text(loc.testResult),

                  subtitle: Text(
                    "${date.day}.${date.month}.${date.year}",
                  ),

                  trailing: const Icon(Icons.open_in_new),

                  onTap: () async {
                    final url = data['fileUrl'];

                    if (url == null) return;

                    final uri = Uri.parse(url);

                   
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.error),
                          backgroundColor: Colors.red,
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
    );
  }
}