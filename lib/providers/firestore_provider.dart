import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_it/models/user.dart';

class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(uid).get();
      return User.fromSnap(snapshot);
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
      return null;
    }
  }
}
