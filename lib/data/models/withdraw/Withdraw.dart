import 'dart:convert';

class Withdraw {
  final String area;
  final String orderId;
  final String orderType;
  final String orderTypeName;
  final String sendDate;
  final double total;
  final String status;
  final String statusTH;
  // final DateTime created;

  Withdraw({
    required this.area,
    required this.orderId,
    required this.orderType,
    required this.orderTypeName,
    required this.sendDate,
    required this.total,
    required this.status,
    required this.statusTH,
    // required this.created,
  });

  // Factory constructor to create an Order from JSON
  factory Withdraw.fromJson(Map<String, dynamic> json) {
    return Withdraw(
      area: json['area'] ?? '' as String,
      orderId: json['orderId'] as String,
      orderType: json['orderType'] as String,
      orderTypeName: json['orderTypeName'] as String,
      sendDate: json['sendDate'] as String,
      total: (json['total'] as num).toDouble(), // Ensures conversion to double
      status: json['status'] as String,
      statusTH: json['statusTH'] as String,
      // created:
      //     DateTime.parse(json['created']), // Converts ISO string to DateTime
    );
  }

  // Converts an Order object to JSON
  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'orderId': orderId,
      'orderType': orderType,
      'orderTypeName': orderTypeName,
      'sendDate': sendDate,
      'total': total,
      'status': status,
      'statusTH': statusTH,
      // 'created': created.toIso8601String(),
    };
  }
}
