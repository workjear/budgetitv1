// In user.dart (assuming this is where UserEntity is defined)
class UserEntity {
  final String id;
  final String fullName;
  final String gender;
  final DateTime birthdate;
  final String email;
  final String? enrolledProgram;

  UserEntity({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.birthdate,
    required this.email,
    this.enrolledProgram,
  });

  UserEntity copyWith({
    String? id,
    String? fullName,
    String? gender,
    DateTime? birthdate,
    String? email,
    String? enrolledProgram,
  }) {
    return UserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      email: email ?? this.email,
      enrolledProgram: enrolledProgram ?? this.enrolledProgram,
    );
  }
}