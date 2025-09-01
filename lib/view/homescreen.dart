import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_system/controller/attendance_controller.dart';
import 'package:smart_attendance_system/controller/auth_controller.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:smart_attendance_system/view/records.dart';
import 'package:intl/intl.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final AuthController _authController = Get.put(AuthController());
  final AttendanceController _attendanceController =
      Get.put(AttendanceController());

  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    String? name = await _authController.getUserName();
    setState(() {
      userName = name;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
          child: Row(
            children: [
              const SizedBox(width: 12),
              isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      userName ?? "User",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await _authController.logoutUser();
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Check In / Check Out Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        icon: Icons.login,
                        title: "Check In",
                        time: _attendanceController
                                    .todayAttendance.value?.checkInTime !=
                                null
                            ? DateFormat.jm().format(_attendanceController
                                .todayAttendance.value!.checkInTime!)
                            : "--:--",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCard(
                        icon: Icons.logout,
                        title: "Check Out",
                        time: _attendanceController
                                    .todayAttendance.value?.checkOutTime !=
                                null
                            ? DateFormat.jm().format(_attendanceController
                                .todayAttendance.value!.checkOutTime!)
                            : "--:--",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ✅ Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        value: "${_attendanceController.workDays.value}",
                        title: "Work Days",
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        value: "${_attendanceController.presentDays.value}",
                        title: "Present",
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        value: "${_attendanceController.absentDays.value}",
                        title: "Absent",
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ✅ Activity Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Your Activity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendancePage(
                              uid: FirebaseAuth.instance.currentUser!.uid,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ Activity List (last 7 days)
                ..._attendanceController.activityList.map((a) {
                  String status = a.checkInTime != null ? "Present" : "Absent";
                  Color color = status == "Present" ? Colors.green : Colors.red;
                  String date = DateFormat('EEE, d MMM').format(a.date);

                  return _buildActivityTile(date, status, color);
                }).toList(),

                const SizedBox(height: 24),

                // ✅ Swipe Button
                SlideAction(
                  text: _attendanceController.isCheckedInToday &&
                          !_attendanceController.isCheckedOutToday
                      ? "Swipe left to Check Out"
                      : "Swipe right to Check In",
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  outerColor: _attendanceController.isCheckedInToday &&
                          !_attendanceController.isCheckedOutToday
                      ? Colors.red
                      : Colors.blue,
                  innerColor: Colors.white,
                  sliderButtonIcon: Icon(
                    _attendanceController.isCheckedInToday &&
                            !_attendanceController.isCheckedOutToday
                        ? Icons.logout
                        : Icons.login,
                    color: _attendanceController.isCheckedInToday &&
                            !_attendanceController.isCheckedOutToday
                        ? Colors.red
                        : Colors.blue,
                  ),
                  sliderRotate: false,
                  onSubmit: () async {
                    if (_attendanceController.isCheckedInToday &&
                        !_attendanceController.isCheckedOutToday) {
                      await _attendanceController.checkOut();
                    } else {
                      await _attendanceController.checkIn();
                    }
                  },
                ),
              ],
            ),
          )),
    );
  }

  // ✅ Check In/Out Card
  Widget _buildCard({IconData? icon, String? title, String? time}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      child: Column(
        children: [
          if (icon != null) Icon(icon, color: Colors.blue, size: 28),
          if (icon != null) const SizedBox(height: 10),
          if (title != null)
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black),
            ),
          if (time != null) ...[
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ Summary Card
  Widget _buildSummaryCard(
      {required String value, required String title, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // ✅ Activity Tile
  Widget _buildActivityTile(String date, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.5), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            status == "Present" ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 26,
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                    fontSize: 13, color: color, fontWeight: FontWeight.w600),
              ),
            ],
          )
        ],
      ),
    );
  }
}
