import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/leave_model.dart';

class LeaveController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  RxList<LeaveModel> myLeaves = <LeaveModel>[].obs;

  final int monthlyQuota = 4; // 🔹 Fixed monthly leaves

  @override
  void onInit() {
    super.onInit();
    _startListener();
  }

  /// 🔹 Real-time listener for current user's leaves (no index required)
  void _startListener() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _db
        .collection('leaves')
        .where('uid', isEqualTo: uid) // 🔹 sirf filter, no orderBy
        .snapshots()
        .listen((snapshot) {
      final leaves =
          snapshot.docs.map((doc) => LeaveModel.fromDoc(doc)).toList();

      // 🔹 App side sorting (latest first)
      leaves.sort((a, b) => b.fromDate.compareTo(a.fromDate));

      myLeaves.value = leaves;
    }, onError: (e) {
      Get.snackbar('Error', 'Failed to listen to leaves: $e');
    });
  }

  /// 🔹 Apply Leave
  Future<void> applyLeave({
    required String type,
    required String reason,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not logged in';

      final docRef = _db.collection('leaves').doc();
      final days = toDate.difference(fromDate).inDays + 1;

      final data = {
        'leaveId': docRef.id,
        'uid': uid,
        'type': type,
        'reason': reason,
        'fromDate': Timestamp.fromDate(fromDate),
        'toDate': Timestamp.fromDate(toDate),
        'days': days,
        'status': 'pending',
        'adminRemarks': '',
        'appliedAt': FieldValue.serverTimestamp(),
        'approvedBy': '',
        'actionedAt': null,
        'notifyAdminSent': false,
        'notifyUserSent': false,
      };

      await docRef.set(data);
      Get.snackbar('Success', 'Leave applied successfully ✅');
    } catch (e) {
      Get.snackbar('Error', 'Failed to apply leave: $e');
    }
  }

  /// 🔹 Cancel only pending leave
  Future<void> cancelLeave(String leaveId) async {
    try {
      final doc = await _db.collection('leaves').doc(leaveId).get();
      if (!doc.exists) return;

      final status = (doc.data()?['status'] ?? '') as String;
      if (status == 'pending') {
        await _db.collection('leaves').doc(leaveId).update({
          'status': 'cancelled',
          'actionedAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar('Success', 'Leave cancelled');
      } else {
        Get.snackbar('Info', 'Only pending leaves can be cancelled');
      }
    } catch (e) {
      Get.snackbar('Error', 'Cancel failed: $e');
    }
  }

  /// 🔹 Get only current month leaves
  List<LeaveModel> get currentMonthLeaves {
    final now = DateTime.now();
    return myLeaves.where((leave) {
      return leave.fromDate.year == now.year &&
          leave.fromDate.month == now.month;
    }).toList();
  }

  /// 🔹 Stats for current month (Quota Based)
  Map<String, int> get currentMonthStats {
    final approved =
        currentMonthLeaves.where((l) => l.status == 'approved').length;
    final pending =
        currentMonthLeaves.where((l) => l.status == 'pending').length;
    final rejected =
        currentMonthLeaves.where((l) => l.status == 'rejected').length;

    return {
      'totalQuota': monthlyQuota,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
      'remaining': monthlyQuota - approved,
    };
  }

  /// 🔹 Current Month Label
  String get currentMonthLabel {
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }
}
