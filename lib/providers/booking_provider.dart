// lib/providers/booking_provider.dart

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/booking_model.dart';
import '../services/socket_service.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  List<int> _unavailableSlots = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> get bookings => _bookings;
  List<int> get unavailableSlots => _unavailableSlots;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BookingProvider() {
    SocketService().onBookingUpdate = () {
      dev.log("Socket update callback triggered in BookingProvider! Refreshing bookings...");
      fetchBookings();
    };
  }

  // Fetch occupied slots on a specific date for a court
  Future<void> fetchUnavailableSlots(int fieldId, String date) async {
    _isLoading = true;
    _unavailableSlots = [];
    _errorMessage = null;

    try {
      final url = Uri.parse("${AppConfig.baseUrl}/bookings.php?field_id=$fieldId&book_date=$date");
      dev.log("Fetching booked slots from: $url");
      
      final response = await http.get(url);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final List<dynamic> slots = responseData['data'] ?? [];
        _unavailableSlots = slots.map<int>((item) => item['start_hour'] as int).toList();
        dev.log("Booked slots for court $fieldId on $date: $_unavailableSlots");
      } else {
        _errorMessage = responseData['message'] ?? "Failed to fetch bookings.";
      }
    } catch (e) {
      _errorMessage = "Network error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch bookings list for a customer or all bookings for admin
  Future<void> fetchBookings({int? userId}) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      final urlString = "${AppConfig.baseUrl}/bookings.php${userId != null ? "?user_id=$userId" : ""}";
      final response = await http.get(Uri.parse(urlString));
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final List<dynamic> list = responseData['data'] ?? [];
        _bookings = list.map((item) => BookingModel.fromJson(item)).toList();
        dev.log("Fetched ${_bookings.length} reservations.");
      } else {
        _errorMessage = responseData['message'] ?? "Failed to fetch booking history.";
      }
    } catch (e) {
      _errorMessage = "Network error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Submit dynamic checkout order with receipt image upload
  Future<bool> createBooking({
    required int userId,
    required int fieldId,
    required String date,
    required int startHour,
    required int endHour,
    required String teamName,
    required String phoneNumber,
    required double totalPrice,
    required List<int> receiptBytes, // Send receipt file as raw bytes for universal support
    required String filename,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse("${AppConfig.baseUrl}/bookings.php");
      dev.log("Creating reservation order via multipart POST to: $url");
      
      final request = http.MultipartRequest("POST", url);
      
      // Text Form fields
      request.fields['user_id'] = userId.toString();
      request.fields['field_id'] = fieldId.toString();
      request.fields['book_date'] = date;
      request.fields['start_hour'] = startHour.toString();
      request.fields['end_hour'] = endHour.toString();
      request.fields['team_name'] = teamName;
      request.fields['phone_number'] = phoneNumber;
      request.fields['total_price'] = totalPrice.toString();

      // Attach dynamic payment receipt file from memory/bytes
      final multipartFile = http.MultipartFile.fromBytes(
        'payment_receipt',
        receiptBytes,
        filename: filename,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['status'] == 'success') {
        final BookingModel newBooking = BookingModel.fromJson(responseData['data']);
        _bookings.insert(0, newBooking);
        
        // Emit Socket.IO event to notify Admin immediately (excluding sender in Socket server)
        SocketService().emitBookingSubmitted(teamName);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['message'] ?? "Failed to register reservation.";
        dev.log("Booking submission failed: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = "Network error: $e";
      dev.log("Booking error exception: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Verify Payment Receipt (Admin) - Approve or Reject
  Future<bool> verifyBooking(int bookingId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse("${AppConfig.baseUrl}/verify.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "booking_id": bookingId,
          "status": status
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // Update local cache list
        final index = _bookings.indexWhere((booking) => booking.id == bookingId);
        String teamName = '';
        if (index != -1) {
          final old = _bookings[index];
          teamName = old.teamName;
          _bookings[index] = BookingModel(
            id: old.id,
            userId: old.userId,
            fieldId: old.fieldId,
            bookDate: old.bookDate,
            startHour: old.startHour,
            endHour: old.endHour,
            teamName: old.teamName,
            phoneNumber: old.phoneNumber,
            totalPrice: old.totalPrice,
            paymentStatus: status,
            paymentReceipt: old.paymentReceipt,
            checkedIn: old.checkedIn,
            createdAt: old.createdAt,
            fieldName: old.fieldName,
            fieldImage: old.fieldImage,
            userName: old.userName,
            userEmail: old.userEmail,
          );
        }

        // Emit Socket.IO event to notify Customer in real-time (Admin → Customer)
        SocketService().emitBookingVerified(
          bookingId: bookingId,
          teamName: teamName,
          status: status,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['message'] ?? "Failed to verify transaction.";
      }
    } catch (e) {
      _errorMessage = "Network error: $e";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Check-In incoming Futsal Team (Admin)
  Future<bool> checkInBooking(int bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse("${AppConfig.baseUrl}/checkin.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "booking_id": bookingId
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // Update local cache state
        final index = _bookings.indexWhere((booking) => booking.id == bookingId);
        String teamName = '';
        if (index != -1) {
          final old = _bookings[index];
          teamName = old.teamName;
          _bookings[index] = BookingModel(
            id: old.id,
            userId: old.userId,
            fieldId: old.fieldId,
            bookDate: old.bookDate,
            startHour: old.startHour,
            endHour: old.endHour,
            teamName: old.teamName,
            phoneNumber: old.phoneNumber,
            totalPrice: old.totalPrice,
            paymentStatus: old.paymentStatus,
            paymentReceipt: old.paymentReceipt,
            checkedIn: true,
            createdAt: old.createdAt,
            fieldName: old.fieldName,
            fieldImage: old.fieldImage,
            userName: old.userName,
            userEmail: old.userEmail,
          );
        }

        // Emit Socket.IO event to notify Customer about check-in (Admin → Customer)
        SocketService().emitBookingCheckIn(
          bookingId: bookingId,
          teamName: teamName,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['message'] ?? "Failed to perform check-in.";
      }
    } catch (e) {
      _errorMessage = "Network error: $e";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
