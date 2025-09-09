import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dummy data
  String userName = "John Doe";
  String userEmail = "john.doe@email.com";
  String profileImage = ""; // Replace with Firebase image URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Title + Profile Picture + Name
            Column(
              children: [
                const Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profileImage),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text(userEmail, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                SizedBox(
                  width: 140,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to Edit Profile Page
                    },
                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                    label: const Text(
                      "Edit Profile",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Options + Logout in the same column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOptionTile("My Information", Icons.person_outline, () {
                  // TODO: Navigate to My Information
                }),
                const SizedBox(height: 24),
                _buildOptionTile("Change Password", Icons.lock_outline, () {
                  // TODO: Navigate to Change Password
                }),
                const SizedBox(height: 24),
                _buildLogoutTile(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0), // add left spacing
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24), // slightly bigger icon
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18), // bigger font
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return GestureDetector(
      onTap: () {
        // TODO: Add logout logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logged out successfully")),
        );
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 8.0), // left spacing same as options
        child: Row(
          children: const [
            Icon(Icons.logout, color: Colors.red, size: 24),
            SizedBox(width: 12),
            Text(
              "Logout",
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
