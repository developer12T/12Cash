class GiveAways {
  final String orderId;
  final String giveName;
  final String storeId;
  final String storeName;
  final String storeAddress;
  final double total;
  final String status;
  // final DateTime createAt;
  GiveAways({
    required this.orderId,
    required this.giveName,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.total,
    required this.status,
    // required this.createAt,
  });

  factory GiveAways.fromJson(Map<String, dynamic> json) {
    return GiveAways(
      orderId: json['orderId'],
      giveName: json['giveName'],
      storeId: json['storeId'],
      storeName: json['storeName'],
      storeAddress: json['storeAddress'],
      total: json['total'].toDouble(),
      status: json['status'],
      // createAt: DateTime.parse(json['createAt']),
    );
  }
}
