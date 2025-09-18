import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_system/controller/auth_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthController _authController = Get.find<AuthController>();
  late TextEditingController _nameController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    try {
      String? name = await _authController.getUserName();
      _nameController = TextEditingController(text: name ?? '');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error loading username: $e");
      _nameController = TextEditingController();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveUserName() async {
    String newName = _nameController.text.trim();
    if (newName.isEmpty) {
      Get.snackbar("Error", "Username cannot be empty");
      return;
    }

    try {
      // Update Firestore
      String uid = _authController.currentUser!.uid;
      await _authController.database
          .collection('users')
          .doc(uid)
          .update({'profile.fullName': newName});

      Get.snackbar("Success", "Username updated successfully");
      Navigator.pop(context); // Go back to ProfilePage
    } catch (e) {
      Get.snackbar("Error", "Failed to update username: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color blueSteel = const Color(0xFF4682B4);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: blueSteel,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: saveUserName,
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Avatar with + overlay
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey.shade400,
                            child: Icon(Icons.person,
                                size: 65, color: Colors.grey.shade700),
                          ),
                          Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: blueSteel,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Username label
                    const Text(
                      "Username",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    // Name field
                    buildField("Enter username", _nameController, Icons.person,
                        blueSteel),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildField(String hint, TextEditingController controller,
      IconData icon, Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.black54),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        ),
      ),
    );
  }
}
