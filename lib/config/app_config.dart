// lib/config/app_config.dart

class AppConfig {
  // CRITICAL: Change this IP address to match your local machine's IP (e.g., 192.168.1.X) when testing on a physical device.
  // "10.0.2.2" is the special loopback address to access the host machine's localhost from the Android Emulator.
  // "127.0.0.1" is standard for iOS Simulator or Web.
  static const String serverIp = "10.0.2.2";
  //ubah menjadi 192.168.1.15 jika run di HP fisik (OPPO)
  //ubah menjadi 10.0.2.2 jika run di Android Emulator
  //ubah menjadi localhost jika run di computer (web/desktop)

  // Base endpoints
  static const String baseUrl = "http://$serverIp/backend/api";
  static const String uploadsUrl = "http://$serverIp/backend/";
  static const String webSocketUrl = "http://$serverIp:3000";
  static const String fcmRegisterUrl = "http://$serverIp:3000/api/register-fcm-token";

  // Prevent instantiation
  AppConfig._();
}
