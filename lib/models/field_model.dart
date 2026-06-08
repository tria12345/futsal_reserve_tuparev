// lib/models/field_model.dart

import 'package:flutter/material.dart';
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

  /// Checks if the court is one of the default fields (Lapangan 1 to 6) to load from local assets
  bool get isDefaultImage {
    final lowerName = name.toLowerCase();
    return lowerName.contains('1') ||
           lowerName.contains('2') ||
           lowerName.contains('3') ||
           lowerName.contains('4') ||
           lowerName.contains('5') ||
           lowerName.contains('6');
  }

  /// Maps the court name to its corresponding local asset path based on floor type description
  String get localAssetPath {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('1')) {
      return 'assets/images/lapangan_1.png'; // Vinyl
    }
    if (lowerName.contains('2')) {
      return 'assets/images/lapangan_2.png'; // Vinyl
    }
    if (lowerName.contains('3')) {
      return 'assets/images/lapangan_3.png'; // Rumput Sintetis (Soft Turf)
    }
    if (lowerName.contains('4')) {
      return 'assets/images/lapangan_4.png'; // Rumput Sintetis (Soft Turf)
    }
    if (lowerName.contains('5')) {
      return 'assets/images/lapangan_5.png'; // Interlock Polymer Sport
    }
    if (lowerName.contains('6')) {
      return 'assets/images/lapangan_6.png'; // Interlock Polymer Sport
    }
    return 'assets/images/lapangan_1.png';
  }

  /// Returns the appropriate ImageProvider (AssetImage for defaults, NetworkImage for others)
  ImageProvider get imageProvider {
    if (isDefaultImage) {
      return AssetImage(localAssetPath);
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }
    // Fallback based on court name if imageUrl is null or empty
    final lowerName = name.toLowerCase();
    if (lowerName.contains('1')) {
      return const AssetImage('assets/images/lapangan_1.png');
    }
    if (lowerName.contains('2')) {
      return const AssetImage('assets/images/lapangan_2.png');
    }
    if (lowerName.contains('3')) {
      return const AssetImage('assets/images/lapangan_3.png');
    }
    if (lowerName.contains('4')) {
      return const AssetImage('assets/images/lapangan_4.png');
    }
    if (lowerName.contains('5')) {
      return const AssetImage('assets/images/lapangan_5.png');
    }
    if (lowerName.contains('6')) {
      return const AssetImage('assets/images/lapangan_6.png');
    }
    return const AssetImage('assets/images/lapangan_1.png');
  }

  /// Builds a responsive Image widget for the court with automated local asset fallbacks
  Widget buildImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    if (isDefaultImage) {
      return Image.asset(
        localAssetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ?? (context, error, stackTrace) {
          // Fallback to asset based on name if the specific asset fails to load
          final lowerName = name.toLowerCase();
          String asset = 'assets/images/lapangan_1.png';
          if (lowerName.contains('2')) {
            asset = 'assets/images/lapangan_2.png';
          } else if (lowerName.contains('3')) {
            asset = 'assets/images/lapangan_3.png';
          } else if (lowerName.contains('4')) {
            asset = 'assets/images/lapangan_4.png';
          } else if (lowerName.contains('5')) {
            asset = 'assets/images/lapangan_5.png';
          } else if (lowerName.contains('6')) {
            asset = 'assets/images/lapangan_6.png';
          }
          return Image.asset(asset, width: width, height: height, fit: fit);
        },
      );
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ?? (context, error, stackTrace) {
          // Fallback to asset based on name when network image fails
          final lowerName = name.toLowerCase();
          String asset = 'assets/images/lapangan_1.png';
          if (lowerName.contains('2')) {
            asset = 'assets/images/lapangan_2.png';
          } else if (lowerName.contains('3')) {
            asset = 'assets/images/lapangan_3.png';
          } else if (lowerName.contains('4')) {
            asset = 'assets/images/lapangan_4.png';
          } else if (lowerName.contains('5')) {
            asset = 'assets/images/lapangan_5.png';
          } else if (lowerName.contains('6')) {
            asset = 'assets/images/lapangan_6.png';
          }
          return Image.asset(asset, width: width, height: height, fit: fit);
        },
      );
    }
    // Fallback if imageUrl is null or empty
    final lowerName = name.toLowerCase();
    String asset = 'assets/images/lapangan_1.png';
    if (lowerName.contains('2')) {
      asset = 'assets/images/lapangan_2.png';
    } else if (lowerName.contains('3')) {
      asset = 'assets/images/lapangan_3.png';
    } else if (lowerName.contains('4')) {
      asset = 'assets/images/lapangan_4.png';
    } else if (lowerName.contains('5')) {
      asset = 'assets/images/lapangan_5.png';
    } else if (lowerName.contains('6')) {
      asset = 'assets/images/lapangan_6.png';
    }
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
