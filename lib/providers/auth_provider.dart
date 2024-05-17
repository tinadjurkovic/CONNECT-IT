import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_it/models/user.dart' as model;

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      try {
        DocumentSnapshot snapshot =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        return model.User(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          photoUrl: snapshot['photoUrl'] ?? '',
          username: snapshot['username'] ?? '',
          bio: snapshot['bio'] ?? '',
          followers: snapshot['followers'] ?? [],
          following: snapshot['following'] ?? [],
        );
      } catch (e) {
        // ignore: avoid_print
        print("Error fetching user details: $e");
        return null;
      }
    } else {
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
