import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_attendance_system/model/attendance_model.dart';

class AttendancePage extends StatelessWidget {
  final String uid;
  const AttendancePage({super.key, required this.uid});

  // ✅ Firestore stream
  Stream<List<AttendanceModel>> getAttendanceRecords() {
    return FirebaseFirestore.instance
        .collection("attendance")
        .doc(uid)
        .collection("records")
        .orderBy("date", descending: true)
        .limit(7) // sirf last 7 din
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromMap(doc.data()))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Attendance Records",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: StreamBuilder<List<AttendanceModel>>(
        stream: getAttendanceRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No records yet"));
          }

          final records = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final status = record.checkInTime != null ? "Present" : "Absent";
              final color =
                  record.checkInTime != null ? Colors.green : Colors.red;

              return _buildActivityTile(
                record.date.toLocal().toString().split(" ")[0], // yyyy-mm-dd
                status,
                color,
              );
            },
          );
        },
      ),
    );
  }

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
          Icon(status == "Present" ? Icons.check_circle : Icons.cancel,
              color: color, size: 26),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87)),
              const SizedBox(height: 4),
              Text(status,
                  style: TextStyle(
                      fontSize: 13, color: color, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }
}
