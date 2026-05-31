// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/auth_provider.dart';
import 'providers/field_provider.dart';
import 'providers/booking_provider.dart';
import 'services/notification_service.dart';
import 'services/socket_service.dart';
import 'services/fcm_service.dart';
import 'theme/app_theme.dart';
import 'views/login_screen.dart';
import 'views/customer/customer_dashboard.dart';
import 'views/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase Core (required before any Firebase service)
  await Firebase.initializeApp();
  
  // 2. Register FCM background message handler (must be top-level function)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // 3. Initialize local notifications singleton service
  await NotificationService().init();
  
  // 4. Initialize Firebase Cloud Messaging (Modul 16)
  await FcmService().init();
  
  // 5. Initialize real-time websocket connection
  SocketService().connect();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FieldProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          Widget defaultHome = const LoginScreen();
          
          if (auth.isAuthenticated) {
            defaultHome = auth.currentUser!.isAdmin 
                ? const AdminDashboard() 
                : const CustomerDashboard();
          }

          return MaterialApp(
            title: 'Futsal Reserve Tuparev',
            navigatorKey: FcmService.navigatorKey, // Handle global deep-link on notification tap
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: defaultHome,
          );
        },
      ),
    );
  }
}
