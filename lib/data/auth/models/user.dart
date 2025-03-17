import 'package:jwt_decoder/jwt_decoder.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String gender;
  final String enrolledProgram;
  final DateTime birthdate;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.gender,
    required this.birthdate,
    required this.enrolledProgram,
  });

  factory UserModel.fromToken(String token) {
    final decoded = JwtDecoder.decode(token);
    final id = decoded['Id']?.toString();
    final fullName = decoded['FullName']?.toString();
    final email = decoded['Email']?.toString();
    final gender = decoded['Gender']?.toString();
    final enrolledProgram = decoded['EnrolledProgram']?.toString();
    final birthdate = decoded['Birthdate']?.toString();

    if (id == null || fullName == null || email == null) {
      throw Exception('Invalid token: Missing required claims (id, fullName, email)');
    }

    // Robust date parsing with fallback
    DateTime parsedBirthdate;
    try {
      final birthdateStr = birthdate?.trim();
      if (birthdateStr == null || birthdateStr.isEmpty) {
        // Use a default date or throw an exception based on your requirements
        parsedBirthdate = DateTime(1970, 1, 1); // Default fallback
      } else {
        parsedBirthdate = DateTime.parse(birthdateStr);
      }
    } on FormatException catch (e) {
      print('Failed to parse birthdate "$birthdate": $e');
      parsedBirthdate = DateTime(1970, 1, 1); // Fallback date
    }

    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      gender: gender ?? '',
      enrolledProgram: enrolledProgram ?? '',
      birthdate: parsedBirthdate,
    );
  }
}