import 'package:flutter/foundation.dart';

class AppConfig {
  // Automatically choose localhost for Web/Desktop and local network IP for physical device
  static const String serverIp = kIsWeb ? "localhost" : "192.168.1.15";

  // Base endpoints
  static const String baseUrl = "https://futsaltuparev.cleverapps.io/api";
  static const String uploadsUrl = "https://futsaltuparev.cleverapps.io/";
  static const String webSocketUrl = "http://$serverIp:3000";
  static const String fcmRegisterUrl =
      "http://$serverIp:3000/api/register-fcm-token";

  // Prevent instantiation
  AppConfig._();
}
