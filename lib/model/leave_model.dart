import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModel {
  final String leaveId;
  final String uid;
  final String type;
  final String reason;
  final DateTime fromDate;
  final DateTime toDate;
  final int days;
  final String status;
  final String adminRemarks;
  final DateTime? appliedAt;
  final String approvedBy;
  final DateTime? actionedAt;
  final bool notifyAdminSent;
  final bool notifyUserSent;

  LeaveModel({
    required this.leaveId,
    required this.uid,
    required this.type,
    required this.reason,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.status,
    required this.adminRemarks,
    this.appliedAt,
    required this.approvedBy,
    this.actionedAt,
    this.notifyAdminSent = false,
    this.notifyUserSent = false,
  });

  factory LeaveModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    int parseDays(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return LeaveModel(
      leaveId: data['leaveId'] ?? doc.id,
      uid: data['uid'] ?? '',
      type: data['type'] ?? '',
      reason: data['reason'] ?? '',
      fromDate: parseDate(data['fromDate']) ?? DateTime.now(),
      toDate: parseDate(data['toDate']) ?? DateTime.now(),
      days: parseDays(data['days']),
      status: (data['status'] ?? 'pending').toString(),
      adminRemarks: data['adminRemarks'] ?? '',
      appliedAt: parseDate(data['appliedAt']),
      approvedBy: data['approvedBy'] ?? '',
      actionedAt: parseDate(data['actionedAt']),
      notifyAdminSent: data['notifyAdminSent'] == true,
      notifyUserSent: data['notifyUserSent'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'leaveId': leaveId,
      'uid': uid,
      'type': type,
      'reason': reason,
      'fromDate': Timestamp.fromDate(fromDate),
      'toDate': Timestamp.fromDate(toDate),
      'days': days,
      'status': status,
      'adminRemarks': adminRemarks,
      'appliedAt': appliedAt != null
          ? Timestamp.fromDate(appliedAt!)
          : FieldValue.serverTimestamp(),
      'approvedBy': approvedBy,
      'actionedAt': actionedAt != null ? Timestamp.fromDate(actionedAt!) : null,
      'notifyAdminSent': notifyAdminSent,
      'notifyUserSent': notifyUserSent,
    };
  }
}
