import 'dart:convert';

class Orders {
  final String orderId;
  final String storeId;
  final String storeName;
  final String storeAddress;
  final double total;
  final String status;
  // final DateTime createAt;
  Orders({
    required this.orderId,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.total,
    required this.status,
    // required this.createAt,
  });

  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
      orderId: json['orderId'],
      storeId: json['storeId'],
      storeName: json['storeName'],
      storeAddress: json['storeAddress'],
      total: json['total'].toDouble(),
      status: json['status'],
      // createAt: DateTime.parse(json['createAt']),
    );
  }
}
