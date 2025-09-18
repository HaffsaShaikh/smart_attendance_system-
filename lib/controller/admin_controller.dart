import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========================== USERS ==========================
  var usersMap = <String, String>{}; // userId -> fullName
  var registeredUsers = <Map<String, dynamic>>[].obs;
  var pendingUsers = <Map<String, dynamic>>[].obs;

  // ========================== LEAVES ==========================
  var monthLeaves = <Map<String, dynamic>>[].obs;
  var selectedMonth = DateTime.now().obs;
  var isLoadingLeaves = false.obs;

  // ========================== ATTENDANCE =====================
  var selectedDate = DateTime.now().obs;
  var allAttendance = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    listenAttendance();
    fetchLeaves();
  }

  // ========================== USERS ==========================
  void fetchUsers() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('users').get();

      usersMap.clear();
      registeredUsers.clear();
      pendingUsers.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = doc.id;

        // map userId → fullName
        usersMap[userId] = data['fullName'] ?? 'Unknown';

        if (data['isApproved'] == true) {
          registeredUsers.add({"id": userId, ...data});
        } else {
          pendingUsers.add({"id": userId, ...data});
        }
      }

      fetchLeaves(); // refresh leaves after users loaded
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveUser(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'isApproved': true});
      int index = pendingUsers.indexWhere((u) => u['id'] == userId);
      if (index != -1) {
        var user = pendingUsers.removeAt(index);
        user['isApproved'] = true;
        registeredUsers.add(user);
      }
      Get.snackbar('Success', 'User approved');
    } catch (e) {
      print("Error approving user: $e");
      Get.snackbar('Error', 'Failed to approve user');
    }
  }

  Future<void> rejectUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      pendingUsers.removeWhere((u) => u['id'] == userId);
      Get.snackbar('Success', 'User rejected');
    } catch (e) {
      print("Error rejecting user: $e");
      Get.snackbar('Error', 'Failed to reject user');
    }
  }

  // ========================== ATTENDANCE =====================
  void listenAttendance() {
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    isLoading.value = true;

    _firestore
        .collection('attendance')
        .snapshots()
        .listen((usersSnapshot) async {
      List<Map<String, dynamic>> tempAttendance = [];

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;

        final recordsSnapshot = await _firestore
            .collection('attendance')
            .doc(userId)
            .collection('records')
            .where('dateKey', isEqualTo: dateKey)
            .get();

        for (var rec in recordsSnapshot.docs) {
          final data = rec.data();
          if (data['date'] != null && data['date'] is Timestamp) {
            data['date'] = (data['date'] as Timestamp).toDate().toLocal();
          }

          tempAttendance.add({
            "id": rec.id,
            "userId": userId,
            "user": usersMap[userId] ?? "Unknown",
            ...data,
          });
        }
      }

      allAttendance.value = tempAttendance;
      isLoading.value = false;
    });
  }

  // ========================== LEAVES ==========================
  void changeMonth(DateTime newMonth) {
    selectedMonth.value = newMonth;
    fetchLeaves();
  }

  void fetchLeaves() async {
    isLoadingLeaves.value = true;
    try {
      final start =
          DateTime(selectedMonth.value.year, selectedMonth.value.month, 1);
      final end =
          DateTime(selectedMonth.value.year, selectedMonth.value.month + 1, 0);

      final snapshot = await _firestore
          .collection('leaves')
          .where('fromDate', isLessThanOrEqualTo: end)
          .where('toDate', isGreaterThanOrEqualTo: start)
          .get();

      monthLeaves.value = snapshot.docs
          .map((doc) {
            final data = doc.data();

            // Timestamp → DateTime
            if (data['fromDate'] is Timestamp)
              data['fromDate'] = (data['fromDate'] as Timestamp).toDate();
            if (data['toDate'] is Timestamp)
              data['toDate'] = (data['toDate'] as Timestamp).toDate();

            // Map userId to fullName
            data['user'] = usersMap[data['userId']] ?? 'Unknown';

            // Normalize status
            data['status'] = (data['status'] ?? 'pending').toLowerCase();

            return {"id": doc.id, ...data};
          })
          .where((leave) => leave['status'] != 'cancelled')
          .toList();
    } catch (e) {
      print("Error fetching leaves: $e");
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  // Update leave status (approve/reject)
  Future<void> updateLeaveStatus(
      String leaveId, String newStatus, String remarks) async {
    try {
      await _firestore.collection('leaves').doc(leaveId).update({
        'status': newStatus.toLowerCase(),
        'adminRemarks': remarks,
        'actionedAt': FieldValue.serverTimestamp(),
      });

      int index = monthLeaves.indexWhere((l) => l['id'] == leaveId);
      if (index != -1) {
        monthLeaves[index]['status'] = newStatus.toLowerCase();
        monthLeaves[index]['adminRemarks'] = remarks;
      }

      Get.snackbar('Success', 'Leave $newStatus');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update leave: $e');
    }
  }
}
