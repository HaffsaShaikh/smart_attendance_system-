import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/attendance_model.dart';

class AttendanceRecords extends StatefulWidget {
  const AttendanceRecords({super.key});

  @override
  State<AttendanceRecords> createState() => _AttendanceRecordsState();
}

class _AttendanceRecordsState extends State<AttendanceRecords> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<AttendanceModel>> _recordsFuture;

  final Color blueSteel = const Color(0xFF4682B4);

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _recordsFuture = loadAllRecords();
    } else {
      _recordsFuture = Future.value([]);
    }
  }

  Future<List<AttendanceModel>> loadAllRecords() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return [];

      DateTime weekAgo = DateTime.now().subtract(const Duration(days: 7));
      Timestamp weekAgoTimestamp = Timestamp.fromDate(weekAgo);

      final snap = await _firestore
          .collection("attendance")
          .doc(uid)
          .collection("records")
          .where("date", isGreaterThanOrEqualTo: weekAgoTimestamp)
          .orderBy("date", descending: true)
          .get();

      return snap.docs
          .map((d) => AttendanceModel.fromMap(d.data(), d.id))
          .toList();
    } catch (e) {
      print("Error fetching records: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: blueSteel,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Attendance Records",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: false, // title on the same line as arrow
      ),
      body: SafeArea(
        child: FutureBuilder<List<AttendanceModel>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                  child: Text(
                      "Error loading records: ${snapshot.error.toString()}"));
            }

            final records = snapshot.data;
            if (records == null || records.isEmpty) {
              return const Center(child: Text("No attendance records found"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final a = records[index];
                String date = DateFormat('EEE, d MMM yyyy').format(a.date);
                String checkIn = a.checkInTime != null
                    ? DateFormat.jm().format(a.checkInTime!)
                    : "--:--";
                String checkOut = a.checkOutTime != null
                    ? DateFormat.jm().format(a.checkOutTime!)
                    : "--:--";

                Color color;
                if (a.status == "Present") {
                  color = Colors.green;
                } else if (a.status == "Absent") {
                  color = Colors.red;
                } else {
                  color = Colors.grey;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    leading: Icon(
                      a.status == "Present" ? Icons.check_circle : Icons.cancel,
                      color: color,
                      size: 32,
                    ),
                    title: Text(
                      date,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      "In: $checkIn | Out: $checkOut",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        a.status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
