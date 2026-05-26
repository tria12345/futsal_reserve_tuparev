// lib/services/socket_service.dart

import 'dart:developer' as dev;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';
import 'notification_service.dart';

class SocketService {
  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  
  // Callback to notify providers/views of real-time booking changes
  void Function()? onBookingUpdate;

  io.Socket? get socket => _socket;
  bool get isConnected => _isConnected;

  void connect() {
    if (_socket != null) return;

    dev.log("Connecting to WebSocket server: ${AppConfig.webSocketUrl}");
    
    _socket = io.io(AppConfig.webSocketUrl, 
      io.OptionBuilder()
        .setTransports(['websocket']) // Use WebSocket transport
        .enableAutoConnect()
        .setReconnectionDelay(2000)
        .build()
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      dev.log("WebSocket connected successfully!");
      
      // Auto-join default lobby or channel
      joinRoom("lobby");
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      dev.log("WebSocket disconnected.");
    });

    _socket!.onConnectError((error) {
      dev.log("WebSocket Connection Error: $error");
    });

    // ============================================================
    // LISTENER 1: New booking submitted (received by Admin)
    // Triggered when a customer submits a new booking
    // ============================================================
    _socket!.on('booking_update', (data) {
      dev.log("Real-time booking update received: $data");
      
      final String type = data['type'] ?? '';
      final String message = data['message'] ?? 'New reservation update received!';
      
      String title = "Futsal Reserve Tuparev 🏟️";
      if (type == 'new_booking') {
        title = "New Booking Created! ⚽";
      } else if (type == 'booking_updated') {
        final String status = data['status'] ?? '';
        title = status == 'approved' ? "Booking Approved! 🎉" : "Booking Rejected! ❌";
      }

      // Trigger local notification for foreground display
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: message,
      );

      // Invoke real-time callback
      if (onBookingUpdate != null) {
        onBookingUpdate!();
      }
    });

    // ============================================================
    // LISTENER 2: Booking verification result (received by Customer)
    // Triggered when admin approves/rejects a booking
    // ============================================================
    _socket!.on('verification_update', (data) {
      dev.log("Real-time verification update received for ${ data['team_name'] ?? 'unknown' }: $data");

      final String status = data['status'] ?? '';
      final String message = data['message'] ?? 'Your booking has been updated.';

      String title;
      if (status == 'approved') {
        title = "Booking Approved! 🎉";
      } else if (status == 'rejected') {
        title = "Booking Rejected ❌";
      } else if (status == 'checked_in') {
        title = "Check-In Confirmed! ✅";
      } else {
        title = "Booking Update 🏟️";
      }

      // Show local notification to customer
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: message,
      );

      // Invoke real-time callback
      if (onBookingUpdate != null) {
        onBookingUpdate!();
      }
    });
  }

  void joinRoom(String roomName) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_room', roomName);
      dev.log("Joined WebSocket room: $roomName");
    }
  }

  // Customer → Admin: notify that a new booking was submitted
  void emitBookingSubmitted(String teamName) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('new_booking_submitted', {
        'team_name': teamName,
        'timestamp': DateTime.now().toIso8601String()
      });
      dev.log("Emitted new_booking_submitted event for team: $teamName");
    }
  }

  // Admin → Customer: notify that a booking was approved or rejected
  void emitBookingVerified({
    required int bookingId,
    required String teamName,
    required String status,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('booking_verified', {
        'booking_id': bookingId,
        'team_name': teamName,
        'status': status,
        'timestamp': DateTime.now().toIso8601String()
      });
      dev.log("Emitted booking_verified event: Booking #$bookingId ($teamName) → $status");
    }
  }

  // Admin → Customer: notify that a team has been checked in
  void emitBookingCheckIn({
    required int bookingId,
    required String teamName,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('booking_checked_in', {
        'booking_id': bookingId,
        'team_name': teamName,
        'timestamp': DateTime.now().toIso8601String()
      });
      dev.log("Emitted booking_checked_in event: Booking #$bookingId ($teamName)");
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      dev.log("WebSocket disconnected explicitly.");
    }
  }
}
