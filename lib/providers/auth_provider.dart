// lib/providers/auth_provider.dart

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/socket_service.dart';
import '../services/fcm_service.dart';
import '../services/api_service.dart';

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
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
      dev.log("Initiating Google Sign-In...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _errorMessage = "Google Sign-In was cancelled.";
        _setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      dev.log("Google Sign-In success! Email: ${googleUser.email}. Authenticating with Firebase...");

      // ===== FIREBASE AUTH (Modul 14) =====
      // Create Firebase credential from Google tokens
      final AuthCredential firebaseCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(firebaseCredential);
      
      // Get Firebase ID Token (more secure than raw Google idToken)
      final String? firebaseIdToken = await userCredential.user!.getIdToken();
      dev.log("Firebase Auth success! UID: ${userCredential.user!.uid}. Verifying with backend...");
      // ===== END FIREBASE AUTH =====

      // Call PHP Auth Endpoint with Firebase ID Token via ApiService
      final response = await ApiService().login({
        "email": googleUser.email,
        "name": googleUser.displayName ?? "Futsal Player",
        "google_id": googleUser.id,
        "avatar": googleUser.photoUrl,
        "id_token": firebaseIdToken 
      });

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == 'success') {
          _currentUser = UserModel.fromJson(responseData['data']);
          await _saveSession(_currentUser!);
          
          // Connect real-time socket and join relevant room
          SocketService().connect();
          SocketService().joinRoom(_currentUser!.isAdmin ? "admins" : "customers");
          
          // Register FCM token with backend for push notifications (Modul 16)
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
      _errorMessage = "Authentication failed: $e";
      dev.log("Auth Exception: $e");
    }

    _setLoading(false);
    return false;
  }

  // Save session details locally
  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(user.toJson()));
    await prefs.setBool('is_logged_in', true);
  }

  // User Sign-Out
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    // Sign out from Firebase Auth (Modul 14)
    try {
      await _firebaseAuth.signOut();
      dev.log("Firebase Auth signed out.");
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    await prefs.remove('is_logged_in');
    
    // Disconnect websocket
    SocketService().disconnect();

    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
