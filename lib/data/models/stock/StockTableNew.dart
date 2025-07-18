class StockTableNew {
  final String productId;
  final String productName;
  final List<UnitTableNew> listUnit;

  StockTableNew({
    required this.productId,
    required this.productName,
    required this.listUnit,
  });

  factory StockTableNew.fromJson(Map<String, dynamic> json) {
    return StockTableNew(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      listUnit: (json['listUnit'] as List)
          .map((unitJson) => UnitTableNew.fromJson(unitJson))
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

class UnitTableNew {
  final String unit;
  final String unitName;
  final int stock;
  final int withdraw;
  final int good;
  final int damaged;
  final int sale;
  final int change;
  final int adjust;
  final int give;
  final int balance;

  UnitTableNew({
    required this.unit,
    required this.unitName,
    required this.stock,
    required this.withdraw,
    required this.good,
    required this.damaged,
    required this.sale,
    required this.change,
    required this.adjust,
    required this.give,
    required this.balance,
  });

  factory UnitTableNew.fromJson(Map<String, dynamic> json) {
    return UnitTableNew(
      unit: json['unit'] ?? '',
      unitName: json['unitName'] ?? '',
      stock: json['stock'] ?? 0,
      withdraw: json['withdraw'] ?? 0,
      good: json['good'] ?? 0,
      sale: json['sale'] ?? 0,
      damaged: json['damaged'] ?? 0,
      change: json['change'] ?? 0,
      adjust: json['adjust'] ?? 0,
      give: json['give'] ?? 0,
      balance: json['balance'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit': unit,
      'unitName': unitName,
      'stock': stock,
      'withdraw': withdraw,
      'good': good,
      'sale': sale,
      'damaged': damaged,
      'change': change,
      'adjust': adjust,
      'give': give,
      'balance': balance,
    };
  }
}
