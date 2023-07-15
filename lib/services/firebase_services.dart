import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map? currentUser;

  final String USER_COLLECTION = 'users';

  FirebaseService();
  // String generateEmailFromUsername(String username) {
  //   return '$username@yourappdomain.com';
  // }

  Future<String?> registerUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      // // Step 1: Create the user account using email and password
      // String generatedEmail = generateEmailFromUsername(username);
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Save additional user details in Firestore
      String userId = userCredential.user!.uid;
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'mobileNumber': mobileNumber,
      });

      // Step 3: Perform any other necessary actions (e.g., sending verification email)

      return null; // Registration success, no error message
    } catch (e) {
      return e.toString(); // Return error message if registration fails
    }
  }

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential _userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (_userCredential.user != null) {
        currentUser = await getUserData(uid: _userCredential.user!.uid);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Map> getUserData({required String uid}) async {
    DocumentSnapshot _doc =
        await _firestore.collection(USER_COLLECTION).doc(uid).get();
    return _doc.data() as Map;
  }
}
