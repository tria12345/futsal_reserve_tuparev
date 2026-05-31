import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../views/customer/customer_dashboard.dart';
import 'notification_service.dart';

/// Top-level background message handler (must be a top-level function, not a class method)
/// This is required by Firebase Messaging for background/terminated state notifications.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  dev.log("FCM Background Message received: ${message.messageId}");
  dev.log("  Title: ${message.notification?.title}");
  dev.log("  Body: ${message.notification?.body}");
  dev.log("  Data: ${message.data}");
}

class FcmService {
  // Global Navigator Key for context-less navigation on notification tap
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Singleton pattern (same as NotificationService & SocketService)
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;

  /// Initialize FCM: request permissions, get token, setup listeners
  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Request notification permission (Android 13+ / iOS)
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    dev.log("FCM Permission status: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      dev.log("FCM: User denied notification permissions.");
      return;
    }

    // 2. Get the FCM device token
    _fcmToken = await _messaging.getToken();
    dev.log("FCM Token obtained: $_fcmToken");

    // 3. Listen for token refresh (token can change over time)
    _messaging.onTokenRefresh.listen((newToken) {
      dev.log("FCM Token refreshed: $newToken");
      _fcmToken = newToken;
      // Re-register the new token with the backend
      if (_fcmToken != null) {
        registerToken(userId: 0); // Will be called again with real userId after login
      }
    });

    // 4. Handle foreground messages (app is open and visible)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      dev.log("FCM Foreground Message received: ${message.messageId}");
      dev.log("  Title: ${message.notification?.title}");
      dev.log("  Body: ${message.notification?.body}");

      // Display as local notification since FCM doesn't auto-show in foreground
      if (message.notification != null) {
        NotificationService().showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: message.notification!.title ?? "Futsal Reserve Tuparev",
          body: message.notification!.body ?? "You have a new notification.",
          payload: message.data.isNotEmpty ? json.encode(message.data) : null,
        );
      }
    });

    // 5. Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      dev.log("FCM: Notification tapped (app was in background): ${message.data}");
      _handleNotificationTap(message);
    });

    // 6. Check if app was launched from a terminated state via notification
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      dev.log("FCM: App launched from terminated state via notification: ${initialMessage.data}");
      _handleNotificationTap(initialMessage);
    }

    _isInitialized = true;
    dev.log("FCM Service initialized successfully.");
  }

  /// Register the FCM token with the backend server
  /// This allows the server to send targeted push notifications to this device
  Future<void> registerToken({required int userId}) async {
    if (_fcmToken == null) {
      dev.log("FCM: Cannot register token — token is null.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(AppConfig.fcmRegisterUrl), // ignore: undefined_getter
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": userId,
          "fcm_token": _fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        dev.log("FCM Token registered with backend successfully for user $userId.");
      } else {
        dev.log("FCM Token registration failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      dev.log("FCM Token registration error: $e");
    }
  }

  /// Handle notification tap by navigating to the customer booking history screen
  void _handleNotificationTap(RemoteMessage message) {
    dev.log("FcmService: Handling notification tap. Deep-linking to Customer Dashboard History Tab...");
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const CustomerDashboard(initialTab: 1),
      ),
      (route) => false,
    );
  }
}
