import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModel {
  String id;
  String uid;
  String type;
  DateTime fromDate;
  DateTime toDate;
  String reason;
  String status;
  DateTime? createdAt;

  LeaveModel(
      {this.id = '',
      required this.uid,
      required this.type,
      required this.fromDate,
      required this.toDate,
      required this.reason,
      required this.status,
      this.createdAt});

  factory LeaveModel.fromMap(Map<String, dynamic> map, String id) {
    return LeaveModel(
      id: id,
      uid: map['uid'] ?? '',
      type: map['type'] ?? '',
      fromDate: (map['fromDate'] as Timestamp).toDate(),
      toDate: (map['toDate'] as Timestamp).toDate(),
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'Pending',
    );
  }
}
