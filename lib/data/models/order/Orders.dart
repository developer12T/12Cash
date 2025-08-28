class Orders {
  final String orderId;
  final String storeId;
  final String storeName;
  final String storeAddress;
  final double total;
  final String status;
  final String statusTH;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  Orders({
    required this.orderId,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.total,
    required this.status,
    required this.statusTH,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
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
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
