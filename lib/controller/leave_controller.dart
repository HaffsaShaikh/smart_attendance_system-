import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../model/leave_model.dart';

class LeaveController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var leaves = <LeaveModel>[].obs;
  var leaveBalance = 20.obs;
  var approvedCount = 0.obs;
  var pendingCount = 0.obs;
  var rejectedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaves();
  }

  void fetchLeaves() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _db
        .collection('leaves')
        .where('uid', isEqualTo: uid)
        .orderBy('fromDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      final temp = snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaveModel.fromMap(data, doc.id);
      }).toList();

      print("📌 Leaves updated: ${temp.length}");
      leaves.assignAll(temp); // 👈 ensures proper UI update
      _updateCounts();
    });
  }

  void _updateCounts() {
    final currentYear = DateTime.now().year;
    final currentYearLeaves =
        leaves.where((l) => l.fromDate.year == currentYear).toList();

    approvedCount.value =
        currentYearLeaves.where((l) => l.status == 'Approved').length;
    pendingCount.value =
        currentYearLeaves.where((l) => l.status == 'Pending').length;
    rejectedCount.value =
        currentYearLeaves.where((l) => l.status == 'Rejected').length;

    leaveBalance.value = 20 - approvedCount.value;
  }

  Future<void> applyLeave(LeaveModel leave) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('leaves').add({
      'uid': uid,
      'type': leave.type,
      'fromDate': Timestamp.fromDate(leave.fromDate),
      'toDate': Timestamp.fromDate(leave.toDate),
      'reason': leave.reason,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
