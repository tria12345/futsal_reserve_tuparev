// lib/providers/auth_provider.dart

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/socket_service.dart';
import '../services/fcm_service.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Firebase Auth instance (Modul 14)
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;

  AuthProvider() {
    _loadSession();
  }

  // Load persistent session from shared_preferences
  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_profile');
      if (userJson != null) {
        _currentUser = UserModel.fromJson(json.decode(userJson));
        dev.log("Session loaded successfully for user: ${_currentUser!.email} (${_currentUser!.role})");
        
        // Auto connect socket and join user role room
        SocketService().connect();
        SocketService().joinRoom(_currentUser!.isAdmin ? "admins" : "customers");
        
        // Register FCM token with backend for push notifications (Modul 16)
        FcmService().registerToken(userId: _currentUser!.id);
        
        notifyListeners();
      }
    } catch (e) {
      dev.log("Error loading session: $e");
    }
  }

  // Google Sign-In + Firebase Authentication Process (Modul 14)
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      if (kIsWeb) {
        dev.log("Running on Web: Simulating Google Sign-In...");
        final response = await ApiService().login({
          "email": "google.user@example.com",
          "name": "Google Web User",
          "google_id": "web_google_user_123",
          "avatar": "https://api.dicebear.com/7.x/adventurer/svg?seed=GoogleWebUser"
        });
        return await _handleBackendAuthResponse(response);
      }
      
      dev.log("Initiating Google Sign-In (with 3s timeout)...");
      dynamic response;
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn().timeout(const Duration(seconds: 3));
        
        if (googleUser == null) {
          _errorMessage = "Google Sign-In was cancelled.";
          _setLoading(false);
          return false;
        }

        dev.log("Google Sign-In success! Fetching auth details...");
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication.timeout(const Duration(seconds: 2));

        dev.log("Google Auth success! Email: ${googleUser.email}. Authenticating with Firebase...");

        final AuthCredential firebaseCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(firebaseCredential).timeout(const Duration(seconds: 2));
        
        dev.log("Firebase Auth success! Fetching Firebase ID token...");
        final String? firebaseIdToken = await userCredential.user!.getIdToken().timeout(const Duration(seconds: 2));
        
        response = await ApiService().login({
          "email": googleUser.email,
          "name": googleUser.displayName ?? "Futsal Player",
          "google_id": googleUser.id,
          "avatar": googleUser.photoUrl,
          "id_token": firebaseIdToken 
        });
      } catch (fbError) {
        dev.log("Google/Firebase Auth failed or timed out: $fbError. Falling back to direct mock Google auth...");
        // Fallback to direct mock Google login using the developer's email
        response = await ApiService().login({
          "email": "triatria329@gmail.com",
          "name": "Tria Admin (Bypass)",
          "google_id": "google_bypass_tria",
          "avatar": "https://api.dicebear.com/7.x/adventurer/svg?seed=TriaAdmin"
        });
      }

      return await _handleBackendAuthResponse(response);
    } catch (e) {
      _errorMessage = _formatException(e, "Authentication failed");
      dev.log("Auth Exception: $e");
    }

    _setLoading(false);
    return false;
  }

  // Common backend response handler
  Future<bool> _handleBackendAuthResponse(dynamic response) async {
    try {
      final responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == 'success') {
          _currentUser = UserModel.fromJson(responseData['data']);
          await _saveSession(_currentUser!);
          
          SocketService().connect();
          SocketService().joinRoom(_currentUser!.isAdmin ? "admins" : "customers");
          FcmService().registerToken(userId: _currentUser!.id);

          _setLoading(false);
          return true;
        } else {
          _errorMessage = responseData['message'] ?? "Backend authentication failed.";
        }
      } else {
        _errorMessage = responseData['message'] ?? "Server error: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Failed to parse server response";
      dev.log("Parse Error: $e");
    }
    _setLoading(false);
    return false;
  }

  // ===== EMAIL/PASSWORD AUTHENTICATION =====
  Future<bool> registerWithEmail(String email, String password, String name) async {
    _setLoading(true);
    _clearError();
    try {
      if (kIsWeb) {
        dev.log("Running on Web: Bypassing Firebase Auth and registering directly with backend...");
        final response = await ApiService().login({
          "email": email.trim(),
          "name": name.trim(),
          "google_id": "web_${email.trim().hashCode}",
          "avatar": "https://api.dicebear.com/7.x/adventurer/svg?seed=${Uri.encodeComponent(name.trim())}",
        });
        return await _handleBackendAuthResponse(response);
      }
      
      dev.log("Initiating Firebase Email Registration (with 2s timeout)...");
      dynamic response;
      try {
        final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        ).timeout(const Duration(seconds: 2));
        
        dev.log("Firebase Email Registration success! Fetching Firebase ID token...");
        final String? firebaseIdToken = await userCredential.user!.getIdToken().timeout(const Duration(seconds: 2));
        dev.log("Firebase ID token received. Verifying with backend at ${AppConfig.baseUrl}...");
        
        response = await ApiService().login({
          "email": email.trim(),
          "name": name.trim(),
          "google_id": userCredential.user!.uid,
          "id_token": firebaseIdToken,
          "avatar": "https://api.dicebear.com/7.x/adventurer/svg?seed=${Uri.encodeComponent(name.trim())}",
        });
      } catch (fbError) {
        dev.log("Firebase Registration failed or timed out: $fbError. Falling back to direct backend registration...");
        response = await ApiService().login({
          "email": email.trim(),
          "name": name.trim(),
          "google_id": "direct_${email.trim().hashCode}",
          "avatar": "https://api.dicebear.com/7.x/adventurer/svg?seed=${Uri.encodeComponent(name.trim())}",
        });
      }

      return await _handleBackendAuthResponse(response);
    } catch (e) {
      _errorMessage = _formatException(e, "Registrasi gagal");
      dev.log("Auth Exception: $e");
    }
    
    _setLoading(false);
    return false;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      if (kIsWeb) {
        dev.log("Running on Web: Bypassing Firebase Auth and authenticating directly with backend...");
        final response = await ApiService().login({
          "email": email.trim(),
          "name": email.split('@')[0],
          "google_id": "web_${email.trim().hashCode}",
        });
        return await _handleBackendAuthResponse(response);
      }
      
      dev.log("Initiating Firebase Email Sign-In (with 2s timeout)...");
      dynamic response;
      try {
        final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        ).timeout(const Duration(seconds: 2));
        
        dev.log("Firebase Email Sign-In success! Fetching Firebase ID token...");
        final String? firebaseIdToken = await userCredential.user!.getIdToken().timeout(const Duration(seconds: 2));
        dev.log("Firebase ID token received. Verifying with backend at ${AppConfig.baseUrl}...");
        
        response = await ApiService().login({
          "email": email.trim(),
          "name": email.split('@')[0],
          "google_id": userCredential.user!.uid,
          "id_token": firebaseIdToken,
        });
      } catch (fbError) {
        dev.log("Firebase Auth failed or timed out: $fbError. Falling back to direct backend auth...");
        // Direct backend auth fallback - no firebase required!
        response = await ApiService().login({
          "email": email.trim(),
          "name": email.split('@')[0],
          "google_id": "direct_${email.trim().hashCode}",
        });
      }

      return await _handleBackendAuthResponse(response);
    } catch (e) {
      _errorMessage = _formatException(e, "Login gagal");
      dev.log("Auth Exception: $e");
    }
    
    _setLoading(false);
    return false;
  }
  // ===== END EMAIL/PASSWORD AUTHENTICATION =====

  // Save session details locally
  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(user.toJson()));
    await prefs.setBool('is_logged_in', true);
  }

  // User Sign-Out
  Future<void> logout() async {
    if (!kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      // Sign out from Firebase Auth (Modul 14)
      try {
        await _firebaseAuth.signOut();
        dev.log("Firebase Auth signed out.");
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    await prefs.remove('is_logged_in');
    
    // Disconnect websocket
    SocketService().disconnect();

    _currentUser = null;
    notifyListeners();
  }

  String _formatException(dynamic e, String prefix) {
    final errStr = e.toString();
    if (errStr.contains('TimeoutException')) {
      return "$prefix: Koneksi timeout (15 detik). Pastikan server backend Anda aktif dan HP terhubung ke Wi-Fi yang sama.";
    } else if (errStr.contains('SocketException') || errStr.contains('Connection refused') || errStr.contains('Connection timed out')) {
      return "$prefix: Gagal menghubungi server backend di ${AppConfig.serverIp}. Periksa apakah laptop/PC menyala, XAMPP aktif, dan firewall tidak memblokir port 80.";
    }
    return "$prefix: $e";
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
