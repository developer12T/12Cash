class RefundOrder {
  final String orderId;
  final String storeId;
  final String storeName;
  final String storeAddress;
  final double totalChange;
  final double totalRefund;
  final double total;
  final String status;
  final String statusTH;
  final DateTime createdAt;
  final DateTime updatedAt;

  RefundOrder({
    required this.orderId,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.totalChange,
    required this.totalRefund,
    required this.total,
    required this.status,
    required this.statusTH,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create an Order object from a JSON map
  factory RefundOrder.fromJson(Map<String, dynamic> json) {
    return RefundOrder(
      orderId: json['orderId'],
      storeId: json['storeId'],
      storeName: json['storeName'],
      storeAddress: json['storeAddress'],
      totalChange: double.tryParse(json['totalChange'].toString()) ?? 0.0,
      totalRefund: double.tryParse(json['totalRefund'].toString()) ?? 0.0,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      status: json['status'],
      statusTH: json['statusTH'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Convert an Order object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'storeId': storeId,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'totalChange': totalChange.toStringAsFixed(2),
      'totalRefund': totalRefund.toStringAsFixed(2),
      'total': total.toStringAsFixed(2),
      'status': status,
      'statusTH': statusTH,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
