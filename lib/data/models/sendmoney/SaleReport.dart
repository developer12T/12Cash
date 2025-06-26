class SaleReport {
  final String type;
  final String orderId;
  final String saleCode;
  final String saleName;
  final String storeId;
  final String storeName;
  final String storeTaxId;
  final double total;
  final String paymentMethod;

  SaleReport({
    required this.type,
    required this.orderId,
    required this.saleCode,
    required this.saleName,
    required this.storeId,
    required this.storeName,
    required this.storeTaxId,
    required this.total,
    required this.paymentMethod,
  });

  // Factory method for mapping from JSON
  factory SaleReport.fromJson(Map<String, dynamic> json) {
    return SaleReport(
      type: json['type'] ?? '',
      orderId: json['orderId'] ?? '',
      saleCode: json['saleCode'] ?? '',
      saleName: json['saleName'] ?? '',
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'] ?? '',
      storeTaxId: json['storeTaxId'] ?? '',
      total: (json['total'] is int)
          ? (json['total'] as int).toDouble()
          : (json['total'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
    );
  }

  // Method to convert model to JSON (if needed)
  Map<String, dynamic> toJson() => {
        'type': type,
        'orderId': orderId,
        'saleCode': saleCode,
        'saleName': saleName,
        'storeId': storeId,
        'storeName': storeName,
        'storeTaxId': storeTaxId,
        'total': total,
        'paymentMethod': paymentMethod,
      };
}
