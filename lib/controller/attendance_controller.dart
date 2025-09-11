import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance_system/model/attendance_model.dart';

class AttendanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rxn<AttendanceModel> todayAttendance = Rxn<AttendanceModel>();
  RxList<AttendanceModel> weeklyRecords = <AttendanceModel>[].obs;

  // ✅ For summary
  RxInt workDays = 0.obs;
  RxInt presentDays = 0.obs;
  RxInt absentDays = 0.obs;

  // ✅ For activity list (last 7 days)
  RxList<AttendanceModel> activityList = <AttendanceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodayAttendance();
    fetchWeeklyAttendance();
  }

  /// ✅ Create consistent document ID with yyyy-MM-dd
  String _getTodayKey(DateTime now) => DateFormat('yyyy-MM-dd').format(now);

  /// ✅ Fetch today's attendance
  Future<void> fetchTodayAttendance() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final now = DateTime.now();
      final todayKey = _getTodayKey(now);

      final doc = await _firestore
          .collection("attendance")
          .doc(uid)
          .collection("records")
          .doc(todayKey)
          .get();

      if (doc.exists && doc.data() != null) {
        todayAttendance.value = AttendanceModel.fromMap(doc.data()!, todayKey);
      } else {
        todayAttendance.value = AttendanceModel(
          uid: uid,
          date: now,
          status: "Pending", // Default before 12 PM
        );

        // ⏰ Only mark absent if it's past 12:00 PM
        final twelvePM = DateTime(now.year, now.month, now.day, 12, 0, 0);
        if (now.isAfter(twelvePM)) {
          final absentModel = AttendanceModel(
            uid: uid,
            date: now,
            status: "Absent",
          );

          await _firestore
              .collection("attendance")
              .doc(uid)
              .collection("records")
              .doc(todayKey)
              .set(absentModel.toMap());

          todayAttendance.value = absentModel;
        }
      }
    } catch (e) {
      print("Error fetching today's attendance: $e");
    }
  }

  /// ✅ Fetch last 7 days attendance
  Future<void> fetchWeeklyAttendance() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final snapshot = await _firestore
          .collection("attendance")
          .doc(uid)
          .collection("records")
          .where("date",
              isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .orderBy("date", descending: true)
          .get();

      weeklyRecords.value = snapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
          .toList();

      // ✅ Calculate summary
      workDays.value = weeklyRecords.length;
      presentDays.value =
          weeklyRecords.where((a) => a.status == "Present").length;
      absentDays.value =
          weeklyRecords.where((a) => a.status == "Absent").length;

      // ✅ Update activity list
      activityList.value = weeklyRecords;
    } catch (e) {
      print("Error fetching weekly attendance: $e");
    }
  }

  /// ✅ Check-in logic (only once per day)
  Future<void> checkIn() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final now = DateTime.now();
      final todayKey = _getTodayKey(now);
      final docRef = _firestore
          .collection("attendance")
          .doc(uid)
          .collection("records")
          .doc(todayKey);

      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        final existing = AttendanceModel.fromMap(doc.data()!, doc.id);

        if (existing.checkInTime != null) {
          Get.snackbar("Error", "You have already checked in today!");
          return;
        }

        // ✅ Update check-in & status
        await docRef.update({
          "checkInTime": Timestamp.fromDate(now),
          "status": "Present",
        });

        todayAttendance.value = AttendanceModel(
          uid: uid,
          date: existing.date,
          checkInTime: now,
          status: "Present",
        );
      } else {
        // ✅ First time check-in (create document with status Present)
        final newRecord = AttendanceModel(
          uid: uid,
          date: now,
          checkInTime: now,
          status: "Present",
        );

        await docRef.set(newRecord.toMap());
        todayAttendance.value = newRecord;
      }

      fetchWeeklyAttendance();
    } catch (e) {
      print("Error during check-in: $e");
      Get.snackbar("Error", "Failed to check in!");
    }
  }

  /// ✅ Check-out logic (only once per day)
  Future<void> checkOut() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final now = DateTime.now();
      final todayKey = _getTodayKey(now);
      final docRef = _firestore
          .collection("attendance")
          .doc(uid)
          .collection("records")
          .doc(todayKey);

      final doc = await docRef.get();

      if (!doc.exists || doc.data() == null) {
        Get.snackbar("Error", "You must check in first!");
        return;
      }

      final existing = AttendanceModel.fromMap(doc.data()!, doc.id);

      if (existing.checkOutTime != null) return; // Already checked out

      await docRef.update({
        "checkOutTime": Timestamp.fromDate(now),
        "status": "Present",
      });

      todayAttendance.value = AttendanceModel(
        uid: uid,
        date: existing.date,
        checkInTime: existing.checkInTime,
        checkOutTime: now,
        status: "Present",
      );

      fetchWeeklyAttendance();
    } catch (e) {
      print("Error during check-out: $e");
      Get.snackbar("Error", "Failed to check out!");
    }
  }

  /// ✅ Helpers
  bool get isCheckedInToday => todayAttendance.value?.checkInTime != null;
  bool get isCheckedOutToday => todayAttendance.value?.checkOutTime != null;
  String get todayStatus => todayAttendance.value?.status ?? "Pending";
}
