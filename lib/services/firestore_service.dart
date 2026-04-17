import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/test_model.dart';

class FirestoreService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {

    await _db
        .collection("users")
        .doc(user.uid)
        .set(user.toMap());

  }
  
  Future<List<TestModel>> getTests(String userId) async {
  final snapshot = await _db
      .collection('users')
      .doc(userId)
      .collection('tests')
      .get();

  return snapshot.docs
      .map((doc) => TestModel.fromFirestore(doc.data(), doc.id))
      .toList();
}

}