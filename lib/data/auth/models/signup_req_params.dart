import 'package:mobile_device_identifier/mobile_device_identifier.dart';

class SignUpReqParams {
  final String fullName;
  final String emailAddress;
  final String gender;
  final String password;
  final String enrolledProgram;
  final String birthdate;
  String? deviceId;

  SignUpReqParams({
    required this.fullName,
    required this.emailAddress,
    required this.gender,
    required this.password,
    required this.birthdate,
    required this.enrolledProgram,
    this.deviceId,
  });

  // Regular synchronous toMap method
  Map<String, dynamic> toMap() {
    return {
      'FullName': fullName,
      'Email': emailAddress,
      'Gender': gender,
      'Password': password,
      'EnrolledProgram': enrolledProgram,
      'Birthdate': birthdate,  // Make sure this is in yyyy-MM-dd format
      'DeviceIdentifier': deviceId ?? 'unknown'
    };
  }

  // Method to set device ID
  Future<void> setDeviceId() async {
    deviceId = await MobileDeviceIdentifier().getDeviceId();
  }
}