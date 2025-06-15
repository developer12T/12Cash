import 'dart:convert';

class Orders {
  final String orderId;
  final String storeId;
  final String storeName;
  final String storeAddress;
  final double total;
  final String status;
  final String statusTH;
  final DateTime createAt;
  Orders({
    required this.orderId,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.total,
    required this.status,
    required this.statusTH,
    required this.createAt,
  });

  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
      orderId: json['orderId'] ?? '',
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'] ?? '',
      storeAddress: json['storeAddress'] ?? '',
      total: (json['total'] is int)
          ? (json['total'] as int).toDouble()
          : (json['total'] is double)
              ? json['total']
              : double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? '',
      statusTH: json['statusTH'] ?? '',
      createAt: json['createAt'] != null
          ? DateTime.tryParse(json['createAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
