class UserModel {
  final String userID;
  final String email;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String designation;
  final String profileImage;

  UserModel({
    required this.userID,
    required this.email,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.designation,
    required this.profileImage,
  });
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'] ?? '',
      email: map['email'] ?? '',
      fullName: map['profile.fullName'] ?? '',
      dateOfBirth: map['profile.date-of-birth'] ?? '',
      gender: map['profile.gender'] ?? '',
      designation: map['profile.designation'] ?? '',
      profileImage: map['image'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'email': email,
      'role': "user",
      'profile.fullName': fullName,
      'profile.date-of-birth': dateOfBirth,
      'profile.gender': gender,
      'profile.designation': designation,
      'image': profileImage,
    };
  }
}
