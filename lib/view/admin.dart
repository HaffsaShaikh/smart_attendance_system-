import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_system/controller/auth_controller.dart';
import 'package:smart_attendance_system/view/attendance.dart';
import 'package:smart_attendance_system/view/holidays.dart';
import 'package:smart_attendance_system/view/leavepage.dart';
import 'package:smart_attendance_system/view/notifications.dart';
import 'package:smart_attendance_system/view/users.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final AuthController _authController = AuthController();
  final Color blueSteel = const Color(0xFF4682B4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 🔹 Solid Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              color: blueSteel,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 30),
                Text(
                  "Welcome Admin,",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Manage your system efficiently",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Dashboard Cards
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  color: blueSteel.withOpacity(0.15),
                  iconColor: blueSteel,
                  icon: Icons.people,
                  title: "Users",
                  onTap: () => Get.to(UsersPage()),
                ),
                _buildDashboardCard(
                  color: blueSteel.withOpacity(0.15),
                  iconColor: blueSteel,
                  icon: Icons.check_circle,
                  title: "Attendance",
                  onTap: () => Get.to(AttendancePage()),
                ),
                _buildDashboardCard(
                  color: blueSteel.withOpacity(0.15),
                  iconColor: blueSteel,
                  icon: Icons.event_note,
                  title: "Leaves",
                  onTap: () => Get.to(LeavesPage()),
                ),
                _buildDashboardCard(
                  color: blueSteel.withOpacity(0.15),
                  iconColor: blueSteel,
                  icon: Icons.notifications,
                  title: "Notifications",
                  onTap: () => Get.to(PushNotificationsPage()),
                ),
                _buildDashboardCard(
                  color: blueSteel.withOpacity(0.15),
                  iconColor: blueSteel,
                  icon: Icons.calendar_today,
                  title: "Holidays",
                  onTap: () => Get.to(HolidaysPage()),
                ),
                _buildDashboardCard(
                  color: blueSteel.withOpacity(0.15),
                  iconColor: Colors.redAccent,
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: () {
                    _authController.logoutUser();
                  }, // add logout logic
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required Color color,
    required Color iconColor,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 30,
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
