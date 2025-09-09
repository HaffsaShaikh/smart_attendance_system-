class UserModel {
  final String userID;
  final String email;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String designation;
  final String profileImage;
  final String profilePicture;

  UserModel({
    required this.userID,
    required this.email,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.designation,
    required this.profileImage,
    required this.profilePicture,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final profile = map['profile'] ?? {};
    return UserModel(
      userID: map['userID'] ?? '',
      email: map['email'] ?? '',
      fullName: profile['fullName'] ?? '',
      dateOfBirth: profile['dateOfBirth'] ?? '',
      gender: profile['gender'] ?? '',
      designation: profile['designation'] ?? '',
      profileImage: map['image'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'email': email,
      'role': "user",
      'profile': {
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'designation': designation,
      },
      'image': profileImage,
      'profilePicture': profilePicture,
    };
  }
}
