// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/field_provider.dart';
import 'providers/booking_provider.dart';
import 'services/notification_service.dart';
import 'services/socket_service.dart';
import 'services/fcm_service.dart';
import 'theme/app_theme.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Guard Firebase and Notification services from running on Web to prevent crash
  if (!kIsWeb) {
    try {
      // 1. Initialize Firebase Core (required before any Firebase service)
      await Firebase.initializeApp();
      
      // 2. Register FCM background message handler (must be top-level function)
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      
      // 3. Initialize local notifications singleton service
      await NotificationService().init();
      
      // 4. Initialize Firebase Cloud Messaging (Modul 16)
      await FcmService().init();
    } catch (e) {
      debugPrint("Firebase/Notification initialization failed: $e");
    }
  } else {
    debugPrint("Running on Web: Firebase & Notifications are bypassed.");
  }
  
  // 5. Initialize real-time websocket connection (Websockets are supported on Web)
  try {
    SocketService().connect();
  } catch (e) {
    debugPrint("WebSocket Connection failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FieldProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) {
          return MaterialApp(
            title: 'Futsal Reserve Tuparev',
            navigatorKey: FcmService.navigatorKey, // Handle global deep-link on notification tap
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProv.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
