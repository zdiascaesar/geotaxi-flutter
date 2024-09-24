import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Failed to login: ${e.message}');
      return null;
    }
  }

  static Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(uid).set(userData);
  }

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(uid).set(userData, SetOptions(merge: true));
  }

  static Future<bool> isPersonalInfoComplete(String uid) async {
    Map<String, dynamic>? userData = await getUser(uid);
    if (userData == null) return false;

    return userData['name'] != null &&
           userData['familyName'] != null &&
           userData['phoneNumber'] != null &&
           userData['role'] != null;
  }

  static Future<bool> isCarInfoComplete(String uid) async {
    Map<String, dynamic>? userData = await getUser(uid);
    if (userData == null) return false;

    return userData['role'] == 1 && // 1 for driver
           userData['carBrand'] != null &&
           userData['carModel'] != null &&
           userData['carYear'] != null &&
           userData['carPlateNumber'] != null;
  }

  static Future<String?> getNextRequiredScreen(String uid) async {
    if (!await isPersonalInfoComplete(uid)) {
      return 'personal_information';
    }

    Map<String, dynamic>? userData = await getUser(uid);
    if (userData != null && userData['role'] == 1 && !await isCarInfoComplete(uid)) {
      return 'car_information';
    }

    return null; // All required information is complete
  }

  static Future<int> getUserRole(String uid) async {
    Map<String, dynamic>? userData = await getUser(uid);
    return userData?['role'] ?? 0; // Default to 0 (passenger) if role is not set
  }
}