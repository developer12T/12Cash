class Stock {
  final String productId;
  final String productName;
  final List<Unit> listUnit;

  Stock({
    required this.productId,
    required this.productName,
    required this.listUnit,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      listUnit: (json['listUnit'] as List)
          .map((unitJson) => Unit.fromJson(unitJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'listUnit': listUnit.map((u) => u.toJson()).toList(),
    };
  }
}

class Unit {
  final String unit;
  final int stock;
  final int stockIn;
  final int stockOut;
  final int balance;

  Unit({
    required this.unit,
    required this.stock,
    required this.stockIn,
    required this.stockOut,
    required this.balance,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      unit: json['unit'] ?? '',
      stock: json['stock'] ?? 0,
      stockIn: json['stockIn'] ?? 0,
      stockOut: json['stockOut'] ?? 0,
      balance: json['balance'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit': unit,
      'stock': stock,
      'stockIn': stockIn,
      'stockOut': stockOut,
      'balance': balance,
    };
  }
}
