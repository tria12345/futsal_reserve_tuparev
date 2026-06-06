import 'package:flutter/foundation.dart';

class AppConfig {
  // Automatically choose localhost for Web/Desktop and 10.0.2.2 for Android Emulator
  static const String serverIp = kIsWeb ? "localhost" : "10.0.2.2";

  // Base endpoints
  static const String baseUrl = "http://$serverIp/backend/api";
  static const String uploadsUrl = "http://$serverIp/backend/";
  static const String webSocketUrl = "http://$serverIp:3000";
  static const String fcmRegisterUrl = "http://$serverIp:3000/api/register-fcm-token";

  // Prevent instantiation
  AppConfig._();
}
