import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static Future<void> createUserIfNotExists(User user) async {
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        'fullName': user.displayName ?? "No Name",
        'email': user.email ?? "",
        'birthDate': "",
        'sex': "",
        'location': "",
        'bloodType': "",
        'notifications': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}