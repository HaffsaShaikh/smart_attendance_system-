import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance_system/view/userdetail.dart';
import 'package:get/get.dart';

class AttendanceCard extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color blueSteel = const Color(0xFF4682B4);

  AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card title with "See All"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Attendance",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               // TextButton(
               //   onPressed: () => Get.to(() => const UserDetailsPage()),
                  child: const Text("See All"),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Real-time attendance list
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collectionGroup('records')
                  .where('date', isGreaterThanOrEqualTo: startOfDay)
                  .where('date', isLessThan: endOfDay)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text("No attendance marked today",
                      style: TextStyle(color: Colors.grey));
                }

                return Column(
                  children: docs.take(3).map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String userId = data['uid'] ?? "";
                    String status = data['status'] ?? "-";
                    String checkIn = data['checkInTime'] != null
                        ? DateFormat('hh:mm a').format(
                            (data['checkInTime'] as Timestamp).toDate())
                        : "-";
                    String checkOut = data['checkOutTime'] != null
                        ? DateFormat('hh:mm a').format(
                            (data['checkOutTime'] as Timestamp).toDate())
                        : "-";

                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text("User: $userId"),
                      subtitle: Text("Check-in: $checkIn | Check-out: $checkOut\nStatus: $status"),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
