import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {

  final idnpController = TextEditingController();

  Map<String, dynamic>? patient;
  String? patientId;
  bool loading = false;

  List<Map<String, dynamic>> recentPatients = [];

  @override
  void initState() {
    super.initState();
    loadRecentPatients();
  }

  // 🔍 ПОИСК ПАЦИЕНТА
  Future<void> searchPatient() async {

    final idnp = idnpController.text.trim();

    if (idnp.length != 13) {
      showError("IDNP must be 13 digits");
      return;
    }

    setState(() => loading = true);

    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('idnp', isEqualTo: idnp)
        .where('role', isEqualTo: 'user')
        .get();

    setState(() => loading = false);

    if (result.docs.isEmpty) {
      showError("Patient not found");
      return;
    }

    final data = result.docs.first.data();

    setState(() {
      patient = data;
      patientId = result.docs.first.id;
    });

    // 💾 СОХРАНЯЕМ В RECENT
    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .collection('recent_patients')
        .doc(patientId)
        .set({
      'name': data['name'],
      'idnp': data['idnp'],
      'lastVisit': FieldValue.serverTimestamp(),
    });

    loadRecentPatients();
  }

  // 📥 ЗАГРУЗКА RECENT
  Future<void> loadRecentPatients() async {
    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .collection('recent_patients')
        .orderBy('lastVisit', descending: true)
        .limit(5)
        .get();

    setState(() {
      recentPatients = snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }).toList();
    });
  }

  // 📎 FILE PICKER
  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return null;

    return File(result.files.single.path!);
  }

  // ☁️ UPLOAD
  Future<String?> uploadFile(File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("documents/${DateTime.now().millisecondsSinceEpoch}");

      await ref.putFile(file);

      return await ref.getDownloadURL();
    } catch (e) {
      showError("Upload failed");
      return null;
    }
  }

  // 📄 ATTACH DOC
  Future<void> attachDocument(String type) async {

    if (patientId == null) {
      showError("Search patient first");
      return;
    }

    final file = await pickFile();
    if (file == null) return;

    final url = await uploadFile(file);
    if (url == null) return;

    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('documents').add({
      'patientId': patientId,
      'doctorId': doctorId,
      'type': type,
      'fileUrl': url,
      'createdAt': FieldValue.serverTimestamp(),
    });

    showSuccess("$type uploaded successfully");
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(msg)),
    );
  }

  void showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text("Doctor Portal",
                  style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 4),

              const Text(
                "Dr. Maria Ionescu",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // 🔍 SEARCH
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: idnpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter patient IDNP...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: loading ? null : searchPatient,
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Search"),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // 👤 ЕСЛИ НАЙДЕН ПАЦИЕНТ
              if (patient != null) ...[

                _patientCard(),

                const SizedBox(height: 10),

                OutlinedButton(
                  onPressed: () {},
                  child: const Text("+ Attach New Document"),
                ),

                const SizedBox(height: 20),

                const Text("Choose Document Type"),

                const SizedBox(height: 10),

                _docTile("Diagnosis"),
                _docTile("Test Result"),
                _docTile("Medication"),
              ],

              // 📋 RECENT
              if (patient == null) ...[

                const Text("Recent Patients",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                ...recentPatients.map((p) => _recentTile(p)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 👤 CARD
  Widget _patientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient!['name'] ?? "Unknown",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("IDNP: ${patient!['idnp'] ?? "N/A"}"),
            ],
          ),
        ],
      ),
    );
  }

  // 📋 RECENT TILE
  Widget _recentTile(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(p['name'] ?? ""),
        subtitle: Text("IDNP: ${p['idnp']}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          setState(() {
            patient = p;
            patientId = p['id'];
          });
        },
      ),
    );
  }

  // 📄 DOC TILE
  Widget _docTile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => attachDocument(title),
      ),
    );
  }
}