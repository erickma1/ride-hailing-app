import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> sendOTP(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('OTP sent');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto retrieval timeout');
        },
      );
    } catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }

  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      print('User profile created: ${user.uid}');
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
