// lib/services/notification_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fcm_service.dart';
import '../views/customer/customer_dashboard.dart';
import '../views/admin/admin_dashboard.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin? _notificationsPlugin = kIsWeb ? null : FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (kIsWeb) return;
    if (_isInitialized) return;

    // Android Initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Darwin/iOS Initialization settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle local notification click action
        try {
          final prefs = await SharedPreferences.getInstance();
          final userJson = prefs.getString('user_profile');
          if (userJson != null) {
            final userData = json.decode(userJson);
            final String role = userData['role'] ?? 'customer';
            
            if (role == 'admin') {
              FcmService.navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const AdminDashboard(),
                ),
                (route) => false,
              );
            } else {
              FcmService.navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const CustomerDashboard(initialTab: 1),
                ),
                (route) => false,
              );
            }
          }
        } catch (e) {
          // Fallback to customer history
          FcmService.navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const CustomerDashboard(initialTab: 1),
            ),
            (route) => false,
          );
        }
      },
    );

    // Request permissions for Android 13+
    await _notificationsPlugin!
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _isInitialized = true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'futsal_reserve_channel',
      'Futsal Reserve Notifications',
      channelDescription: 'Notification channel for Futsal Reserve Tuparev booking updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin!.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
}
