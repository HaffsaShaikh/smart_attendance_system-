import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_system/controller/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  final AuthController _authController = Get.find();

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      // Upload to Firebase Storage
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Reference ref =
          FirebaseStorage.instance.ref().child("profilePictures/$uid.jpg");

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update in Firestore
      await _authController.updateProfilePicture(downloadUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: pickAndUploadImage,
              icon: const Icon(Icons.upload),
              label: const Text("Upload Profile Picture"),
            ),
          ],
        ),
      ),
    );
  }
}
