class UserModel {
  
  final String uid;
  final String name;
  final String email;
  final String dob;
  final String bloodType;
  final String idnp;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.dob,
    required this.bloodType,
    required this.idnp,
    required this.role,
  });

  Map<String, dynamic> toMap() {

    return {
      "uid": uid,
      "name": name,
      "email": email,
      "dob": dob,
      "bloodType": bloodType,
      "idnp": idnp,
      "role": role,
    };

  }

}