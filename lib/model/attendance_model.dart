import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  String id;
  String uid;
  DateTime date;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  String status;

  AttendanceModel({
    this.id = "",
    required this.uid,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.status = "Absent",
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "date": Timestamp.fromDate(date),
      "checkInTime":
          checkInTime != null ? Timestamp.fromDate(checkInTime!) : null,
      "checkOutTime":
          checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      "status": status,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String docId) {
    return AttendanceModel(
      id: docId,
      uid: map['uid'],
      date: (map['date'] as Timestamp).toDate(),
      checkInTime: map['checkInTime'] != null
          ? (map['checkInTime'] as Timestamp).toDate()
          : null,
      checkOutTime: map['checkOutTime'] != null
          ? (map['checkOutTime'] as Timestamp).toDate()
          : null,
      status: map['status'] ?? "Absent",
    );
  }
}
