// lib/models/field_model.dart

import '../config/app_config.dart';

class FieldModel {
  final int id;
  final String name;
  final String? description;
  final double pricePerHour;
  final bool isMaintenance;
  final String? imageUrl;

  FieldModel({
    required this.id,
    required this.name,
    this.description,
    required this.pricePerHour,
    required this.isMaintenance,
    this.imageUrl,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    String? imgUrl = json['image_url'];
    if (imgUrl != null && !imgUrl.startsWith('http')) {
      imgUrl = "${AppConfig.uploadsUrl}$imgUrl";
    }
    
    return FieldModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'],
      pricePerHour: json['price_per_hour'] is double
          ? json['price_per_hour']
          : double.parse(json['price_per_hour'].toString()),
      isMaintenance: json['is_maintenance'] == 1 || json['is_maintenance'] == true,
      imageUrl: imgUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_per_hour': pricePerHour,
      'is_maintenance': isMaintenance ? 1 : 0,
      'image_url': imageUrl,
    };
  }
}
