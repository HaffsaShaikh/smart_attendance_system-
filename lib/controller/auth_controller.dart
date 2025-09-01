import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_system/view/admin.dart';
import 'package:smart_attendance_system/view/emailverify.dart';
import 'package:smart_attendance_system/view/homescreen.dart';
import 'package:smart_attendance_system/view/login.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  /// -------------------- LOGIN --------------------
  Future<void> loginUser(String email, String pass) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: pass);
      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          Get.snackbar(
              'Verification Required', 'Please verify your email address.');
          Get.offAll(() => EmailVerification());
          return;
        }

        final userDoc = await _database.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc['role'] == 'admin') {
          Get.offAll(() => const Admin());
        } else {
          Get.offAll(() => const Homescreen());
        }
      }

      Get.snackbar('Login Success', 'Welcome back!');
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? e.toString());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// -------------------- LOGOUT --------------------
  Future<void> logoutUser() async {
    await _auth.signOut();
    Get.offAll(() => Login());
  }

  /// -------------------- REGISTER --------------------
  Future<void> registerUser({
    required String email,
    required String pass,
    required String fullName,
    required String dob,
    required String gender,
    required String designation,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: pass);
      User? user = userCredential.user;

      if (user != null) {
        await _database.collection('users').doc(user.uid).set({
          'userID': user.uid,
          'email': user.email,
          'role': 'user',
          'profile': {
            'fullName': fullName,
            'dateOfBirth': dob,
            'gender': gender,
            'designation': designation,
          },
          'image': '', // will be updated after upload
          'createdAt': DateTime.now(),
        });

        await user.sendEmailVerification();
        Get.snackbar(
            'Verification Required', 'Please verify your email address.');
        Get.offAll(() => EmailVerification());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Registration Failed", e.message ?? e.toString());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// -------------------- PASSWORD RESET --------------------
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Email Sent', 'Check your email for reset link.');
      Get.offAll(() => Login());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? e.toString());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// -------------------- RESEND EMAIL --------------------
  Future<void> resendEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        startCoolDown();
        Get.snackbar("Email Sent", "Verification email has been sent.");
      } else {
        Get.offAll(() => Login());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? e.toString());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// -------------------- COOLDOWN TIMER --------------------
  RxInt coolDown = 0.obs;
  void startCoolDown() {
    coolDown.value = 30;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (coolDown.value > 0) {
        coolDown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  /// -------------------- EMAIL VERIFICATION CHECK --------------------
  void checkEmailVerification() {
    const duration = Duration(seconds: 3);

    Timer.periodic(duration, (timer) async {
      User? user = _auth.currentUser;
      await user?.reload();
      if (user != null && user.emailVerified) {
        timer.cancel();
        Get.snackbar(
            "Email Verified", "Your email has been verified successfully.");
        Get.offAll(() => const Login());
      }
    });
  }

  Future<String?> getUserName() async {
    try {
      String uid = _auth.currentUser!.uid;

      DocumentSnapshot doc = await _database.collection("users").doc(uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data["profile"]["fullName"];
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
    return null;
  }
}
