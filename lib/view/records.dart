import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/attendance_model.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<AttendanceModel>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = loadAllRecords();
  }

  // ✅ Load only last 7 days for current user
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Attendance Records"),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<AttendanceModel>>(
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

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No attendance records found"));
          }

          final records = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
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

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  leading: Icon(
                    a.status == "Present" ? Icons.check_circle : Icons.cancel,
                    color: color,
                    size: 30,
                  ),
                  title: Text(
                    date,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text("In: $checkIn | Out: $checkOut"),
                  trailing: Text(
                    a.status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
