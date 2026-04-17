class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String birthDate;
  final String bloodType;
  final String idnp;
  final String role;
  final String sex;
  final String location;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.birthDate,
    required this.bloodType,
    required this.idnp,
    required this.role,
    required this.sex,
    required this.location,
  });

  /// 🔥 FROM FIREBASE
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      birthDate: map['birthDate'] ?? map['dob'] ?? '',
      bloodType: map['bloodType'] ?? '',
      idnp: map['idnp'] ?? '',
      role: map['role'] ?? 'user',
      sex: map['sex'] ?? '',
      location: map['location'] ?? '',
    );
  }

  /// 🔥 TO FIREBASE
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullName": fullName,
      "email": email,
      "birthDate": birthDate,
      "bloodType": bloodType,
      "idnp": idnp,
      "role": role,
      "sex": sex,
      "location": location,
    };
  }

  /// 🔥 UPDATE HELPER (очень удобно потом)
  UserModel copyWith({
    String? fullName,
    String? email,
    String? birthDate,
    String? bloodType,
    String? idnp,
    String? role,
    String? sex,
    String? location,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      bloodType: bloodType ?? this.bloodType,
      idnp: idnp ?? this.idnp,
      role: role ?? this.role,
      sex: sex ?? this.sex,
      location: location ?? this.location,
    );
  }
}