import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medtrack/l10n/app_localizations.dart';
import 'doctor_profile_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int selectedIndex = 0;

  final idnpController = TextEditingController();

  Map<String, dynamic>? patient;
  String? patientId;
  bool loading = false;
  bool patientSelected = false;

  List<Map<String, dynamic>> todayPatients = [];
  List<Map<String, dynamic>> yesterdayPatients = [];

  String doctorName = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDoctorData();
      loadRecentPatients();
    });
  }

  // 👨‍⚕️ LOAD DOCTOR
  Future<void> loadDoctorData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      doctorName = doc.data()?['fullName'] ?? "Doctor";
    });
  }

  Widget _getScreen(AppLocalizations loc) {
    return selectedIndex == 1
        ? const DoctorProfileScreen()
        : _buildHome(loc);
  }

  // 🔍 SEARCH PATIENT
  Future<void> searchPatient() async {
    final loc = AppLocalizations.of(context)!;
    final idnp = idnpController.text.trim();

    if (idnp.length != 13) {
      showError(loc.idnpLength);
      return;
    }

    setState(() => loading = true);

    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('idnp', isEqualTo: idnp)
          .where('role', isEqualTo: 'user')
          .get();

      if (result.docs.isEmpty) {
        showError(loc.patientNotFound);
        setState(() => loading = false);
        return;
      }

      final doc = result.docs.first;

      setState(() {
        patient = doc.data();
        patientId = doc.id;
        patientSelected = false;
      });

    } catch (e) {
      showError("Search failed");
    }

    setState(() => loading = false);
  }

  // 🔙 EXIT PATIENT MODE
  void exitPatientMode() {
    setState(() {
      patient = null;
      patientId = null;
      patientSelected = false;
      idnpController.clear();
    });
  }

  // 📌 SAVE RECENT
  Future<void> saveToRecentPatients() async {
    final doctorId = FirebaseAuth.instance.currentUser?.uid;
    if (doctorId == null || patientId == null || patient == null) return;

    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .collection('recent_patients')
        .doc(patientId)
        .set({
      'name': patient!['fullName'],
      'idnp': patient!['idnp'],
      'lastVisit': FieldValue.serverTimestamp(),
    });

    loadRecentPatients();
  }

  // 📊 LOAD RECENT
  Future<void> loadRecentPatients() async {
    final doctorId = FirebaseAuth.instance.currentUser?.uid;
    if (doctorId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .collection('recent_patients')
        .orderBy('lastVisit', descending: true)
        .get();

    final now = DateTime.now();
    final yesterdayDate = now.subtract(const Duration(days: 1));

    List<Map<String, dynamic>> today = [];
    List<Map<String, dynamic>> yesterday = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final ts = data['lastVisit'] as Timestamp?;
      if (ts == null) continue;

      final date = ts.toDate();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        today.add({...data, 'id': doc.id});
      } else if (date.year == yesterdayDate.year &&
          date.month == yesterdayDate.month &&
          date.day == yesterdayDate.day) {
        yesterday.add({...data, 'id': doc.id});
      }
    }

    setState(() {
      todayPatients = today;
      yesterdayPatients = yesterday;
    });
  }

  // 📄 ATTACH DOCUMENT
  Future<void> attachDocument(String type) async {
    final loc = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result == null) return;

      final file = result.files.first;

      final ref = FirebaseStorage.instance
          .ref()
          .child("documents/${patientId}_${DateTime.now().millisecondsSinceEpoch}");

      await ref.putData(file.bytes!);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('documents').add({
        'patientId': patientId,
        'type': type,
        'fileUrl': url,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await saveToRecentPatients();
      showSuccess(loc.success);

    } catch (e) {
      showError("Upload failed");
    }
  }

  // 💊 MEDICATION OPTIONS
  void showAddMedicationDialog() {
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.addMedication,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: Text(loc.writeManually),
              onTap: () {
                Navigator.pop(context);
                _showManualMedicationSheet();
              },
            ),

            ListTile(
              leading: const Icon(Icons.attach_file, color: Colors.green),
              title: Text(loc.attachDocument),
              onTap: () {
                Navigator.pop(context);
                _attachMedicationFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✍️ MANUAL MEDICATION
  void _showManualMedicationSheet() {
    final loc = AppLocalizations.of(context)!;

    final name = TextEditingController();
    final dosage = TextEditingController();

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: name,
                  decoration: InputDecoration(labelText: loc.medicationName),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: dosage,
                  decoration: InputDecoration(labelText: loc.dosage),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {

                          if (name.text.trim().isEmpty) {
                            showError("Enter medication name");
                            return;
                          }

                          setModalState(() => isSaving = true);

                          try {
                            await FirebaseFirestore.instance.collection('documents').add({
                              'patientId': patientId,
                              'type': 'Medication',
                              'title': name.text.trim(),
                              'dosage': dosage.text.trim(),
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            await saveToRecentPatients();

                            Navigator.pop(context);
                            showSuccess(loc.success);

                          } catch (e) {
                            showError("Save failed");
                          }

                          setModalState(() => isSaving = false);
                        },
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(loc.save),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 📎 FILE MEDICATION
  Future<void> _attachMedicationFile() async {
    final loc = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result == null) return;

      final file = result.files.first;

      final ref = FirebaseStorage.instance
          .ref()
          .child("medications/${patientId}_${DateTime.now().millisecondsSinceEpoch}");

      await ref.putData(file.bytes!);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('documents').add({
        'patientId': patientId,
        'type': 'Medication',
        'fileUrl': url,
        'fileName': file.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await saveToRecentPatients();
      showSuccess(loc.success);

    } catch (e) {
      showError("Upload failed");
    }
  }

  // UI (НЕ ТРОГАЛ)
  Widget _buildHome(AppLocalizations loc) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(loc.doctorPortal, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),

            Text(doctorName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            Row(
              children: [

                if (patient != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: exitPatientMode,
                  ),

                Expanded(
                  child: TextField(
                    controller: idnpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: loc.enterIdnp,
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
                  onPressed: loading ? null : searchPatient,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(loc.search),
                )
              ],
            ),

            const SizedBox(height: 20),

            if (patient != null) ...[
              GestureDetector(
                onTap: () => setState(() => patientSelected = true),
                child: _patientCard(),
              ),

              if (patientSelected) ...[
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () => attachDocument("Diagnosis"),
                  child: Text(loc.diagnosis),
                ),

                ElevatedButton(
                  onPressed: () => attachDocument("Test"),
                  child: Text(loc.testResult),
                ),

                ElevatedButton(
                  onPressed: showAddMedicationDialog,
                  child: Text(loc.medication),
                ),
              ]
            ],

            if (patient == null) ...[
              Text(loc.today, style: const TextStyle(fontWeight: FontWeight.bold)),
              ...todayPatients.map((p) => _recentTile(p)),

              const SizedBox(height: 10),

              Text(loc.yesterday, style: const TextStyle(fontWeight: FontWeight.bold)),
              ...yesterdayPatients.map((p) => _recentTile(p)),
            ]
          ],
        ),
      ),
    );
  }

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
              Text(patient!['fullName']),
              Text("IDNP: ${patient!['idnp']}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentTile(Map<String, dynamic> p) {
    return ListTile(
      title: Text(p['name']),
      subtitle: Text("IDNP: ${p['idnp']}"),
      onTap: () {
        setState(() {
          patient = p;
          patientId = p['id'];
          patientSelected = true;
        });
      },
    );
  }

  void showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(msg)),
      );

  void showSuccess(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text(msg)),
      );

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _getScreen(loc),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        selectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: loc.home),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: loc.profile),
        ],
      ),
    );
  }
}