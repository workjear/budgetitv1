import 'package:mobile_device_identifier/mobile_device_identifier.dart';

class SignInReqParams {
  final String email;
  final String password;
  String? deviceId;

  SignInReqParams({required this.email, required this.password});

  Map<String, dynamic> toMap(){
    return{
      'Email': email,
      'Password': password,
      'DeviceIdentifier': deviceId,
    };
  }

  // Method to set device ID
  Future<void> setDeviceId() async {
    deviceId = await MobileDeviceIdentifier().getDeviceId();
  }
}
