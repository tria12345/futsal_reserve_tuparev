// lib/models/booking_model.dart

class BookingModel {
  final int id;
  final int userId;
  final int fieldId;
  final String bookDate;
  final int startHour;
  final int endHour;
  final String teamName;
  final String phoneNumber;
  final double totalPrice;
  final String paymentStatus; // 'pending', 'approved', 'rejected'
  final String? paymentReceipt;
  final bool checkedIn;
  final String createdAt;
  
  // Extra fields joined from relations
  final String? fieldName;
  final String? fieldImage;
  final String? userName;
  final String? userEmail;

  BookingModel({
    required this.id,
    required this.userId,
    required this.fieldId,
    required this.bookDate,
    required this.startHour,
    required this.endHour,
    required this.teamName,
    required this.phoneNumber,
    required this.totalPrice,
    required this.paymentStatus,
    this.paymentReceipt,
    required this.checkedIn,
    required this.createdAt,
    this.fieldName,
    this.fieldImage,
    this.userName,
    this.userEmail,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      fieldId: json['field_id'] is int ? json['field_id'] : int.parse(json['field_id'].toString()),
      bookDate: json['book_date'] ?? '',
      startHour: json['start_hour'] is int ? json['start_hour'] : int.parse(json['start_hour'].toString()),
      endHour: json['end_hour'] is int ? json['end_hour'] : int.parse(json['end_hour'].toString()),
      teamName: json['team_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      totalPrice: json['total_price'] is double
          ? json['total_price']
          : double.parse(json['total_price'].toString()),
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentReceipt: json['payment_receipt'],
      checkedIn: json['checked_in'] == 1 || json['checked_in'] == true,
      createdAt: json['created_at'] ?? '',
      fieldName: json['field_name'],
      fieldImage: json['field_image'],
      userName: json['user_name'],
      userEmail: json['user_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'field_id': fieldId,
      'book_date': bookDate,
      'start_hour': startHour,
      'end_hour': endHour,
      'team_name': teamName,
      'phone_number': phoneNumber,
      'total_price': totalPrice,
      'payment_status': paymentStatus,
      'payment_receipt': paymentReceipt,
      'checked_in': checkedIn ? 1 : 0,
      'created_at': createdAt,
      'field_name': fieldName,
      'field_image': fieldImage,
      'user_name': userName,
      'user_email': userEmail,
    };
  }

  String get timeSlotString {
    final startString = "${startHour.toString().padLeft(2, '0')}:00";
    final endString = "${endHour.toString().padLeft(2, '0')}:00";
    return "$startString - $endString";
  }
}
