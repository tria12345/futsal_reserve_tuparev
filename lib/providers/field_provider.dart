// lib/providers/field_provider.dart

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../services/api_service.dart';

class FieldProvider extends ChangeNotifier {
  List<FieldModel> _fields = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FieldModel> get fields => _fields;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch futsal courts
  Future<void> fetchFields({required bool isCustomer}) async {
    _isLoading = true;
    _errorMessage = null;
    // We notify listeners later to avoid building errors or trigger loading screens
    
    try {
      final response = await ApiService().getFields(isCustomer: isCustomer);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final List<dynamic> list = responseData['data'] ?? [];
        _fields = list.map((item) => FieldModel.fromJson(item)).toList();
        _fields.sort((a, b) => a.name.compareTo(b.name)); // Sort ascending by name for perfect numerical order
        dev.log("Fetched ${_fields.length} courts successfully.");
      } else {
        _errorMessage = responseData['message'] ?? "Failed to fetch courts.";
      }
    } catch (e) {
      _errorMessage = "Network error: $e";
      dev.log("Field Fetch Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create a new court (Admin only)
  Future<bool> addField(String name, double price, String description, String imageUrl) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().addField({
        "name": name,
        "price_per_hour": price,
        "description": description,
        "image_url": imageUrl
      });

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['status'] == 'success') {
        final FieldModel newField = FieldModel.fromJson(responseData['data']);
        _fields.add(newField); // Add to local cache list
        _fields.sort((a, b) => a.name.compareTo(b.name)); // Sort ascending by name for perfect numerical order
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['message'] ?? "Failed to create court.";
      }
    } catch (e) {
      _errorMessage = "Network error: $e";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Toggle court maintenance status (Admin only)
  Future<bool> toggleMaintenance(int id, bool isMaintenance) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().toggleMaintenance(id, isMaintenance);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // Update local court instance
        final int index = _fields.indexWhere((field) => field.id == id);
        if (index != -1) {
          final old = _fields[index];
          _fields[index] = FieldModel(
            id: old.id,
            name: old.name,
            description: old.description,
            pricePerHour: old.pricePerHour,
            imageUrl: old.imageUrl,
            isMaintenance: isMaintenance,
          );
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['message'] ?? "Failed to update maintenance status.";
      }
    } catch (e) {
      _errorMessage = "Network error: $e";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Delete a court (Admin only) — Completing CRUD (Modul 5)
  Future<bool> deleteField(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().deleteField(id);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // Remove from local cache list
        _fields.removeWhere((field) => field.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['message'] ?? "Failed to delete court.";
      }
    } catch (e) {
      _errorMessage = "Network error: $e";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
