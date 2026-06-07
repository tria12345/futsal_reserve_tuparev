import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<http.Response> login(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse("${AppConfig.baseUrl}/login.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    ).timeout(const Duration(seconds: 5));
  }

  Future<http.Response> getFields({bool isCustomer = false}) async {
    return await http.get(Uri.parse("${AppConfig.baseUrl}/fields.php${isCustomer ? '?customer=true' : ''}"))
        .timeout(const Duration(seconds: 5));
  }

  Future<http.Response> addField(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse("${AppConfig.baseUrl}/fields.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    ).timeout(const Duration(seconds: 5));
  }

  Future<http.Response> toggleMaintenance(int id, bool isMaintenance) async {
    return await http.put(
      Uri.parse("${AppConfig.baseUrl}/fields.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "id": id,
        "is_maintenance": isMaintenance
      }),
    ).timeout(const Duration(seconds: 5));
  }

  Future<http.Response> deleteField(int id) async {
    return await http.delete(Uri.parse("${AppConfig.baseUrl}/fields.php?id=$id"))
        .timeout(const Duration(seconds: 5));
  }

  Future<http.Response> getUnavailableSlots(int fieldId, String date) async {
    return await http.get(Uri.parse("${AppConfig.baseUrl}/get_booking.php?field_id=$fieldId&book_date=$date"))
        .timeout(const Duration(seconds: 5));
  }

  Future<http.Response> getBookings({int? userId}) async {
    final urlString = "${AppConfig.baseUrl}/get_booking.php${userId != null ? "?user_id=$userId" : ""}";
    return await http.get(Uri.parse(urlString))
        .timeout(const Duration(seconds: 5));
  }

  Future<http.Response> createBooking(http.MultipartRequest request) async {
    final streamedResponse = await request.send().timeout(const Duration(seconds: 5));
    return await http.Response.fromStream(streamedResponse).timeout(const Duration(seconds: 5));
  }

  Future<http.Response> verifyBooking(int bookingId, String status) async {
    return await http.post(
      Uri.parse("${AppConfig.baseUrl}/ubah_booking.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "booking_id": bookingId,
        "status": status
      }),
    ).timeout(const Duration(seconds: 5));
  }
  
  Future<http.Response> deleteBooking(int bookingId) async {
    return await http.post(
      Uri.parse("${AppConfig.baseUrl}/hapus_booking.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "booking_id": bookingId,
      }),
    ).timeout(const Duration(seconds: 5));
  }

  Future<http.Response> checkInBooking(int bookingId) async {
    return await http.post(
      Uri.parse("${AppConfig.baseUrl}/checkin.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "booking_id": bookingId
      }),
    ).timeout(const Duration(seconds: 5));
  }
  
  Future<http.Response> registerFcmToken(int userId, String token) async {
    return await http.post(
      Uri.parse("${AppConfig.baseUrl}/register_token.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": userId,
        "fcm_token": token
      }),
    ).timeout(const Duration(seconds: 5));
  }
}
