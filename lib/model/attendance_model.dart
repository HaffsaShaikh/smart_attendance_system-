import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String uid;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final bool faceVerified;
  final String? imageURL;
  final String status; // ✅ NEW: Present / Absent / Leave etc.

  AttendanceModel({
    required this.uid,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.faceVerified = false,
    this.imageURL,
    this.status = "Absent", // default as Absent until check-in
  });

  /// ✅ Convert Firestore Map → AttendanceModel
  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      uid: map['uid'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      checkInTime: map['checkInTime'] != null
          ? (map['checkInTime'] as Timestamp).toDate()
          : null,
      checkOutTime: map['checkOutTime'] != null
          ? (map['checkOutTime'] as Timestamp).toDate()
          : null,
      faceVerified: map['faceVerified'] ?? false,
      imageURL: map['imageURL'],
      status: map['status'] ?? "Absent",
    );
  }

  /// ✅ Convert AttendanceModel → Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'date': Timestamp.fromDate(date),
      'checkInTime':
          checkInTime != null ? Timestamp.fromDate(checkInTime!) : null,
      'checkOutTime':
          checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      'faceVerified': faceVerified,
      'imageURL': imageURL,
      'status': status,
    };
  }
}
