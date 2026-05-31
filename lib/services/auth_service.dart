import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get current user
  User? get currentUser => _auth.currentUser;

  // sign in with email and password
  Future<void> signUp ({
    required String email,
    required String password,
    required String name,
    required String branch,
    required String year,

  })async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // save user data to Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'branch': branch,
      'year': year,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}