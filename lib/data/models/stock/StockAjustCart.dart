class StockAjustCart {
  final String id;
  final String name;
  final String group;
  final String brand;
  final String size;
  final String flavour;
  int qty;
  final String unit;
  final String unitName;
  final double price;
  final double total;
  final String action;
  final int qtyPcs;

  StockAjustCart({
    required this.id,
    required this.name,
    required this.group,
    required this.brand,
    required this.size,
    required this.flavour,
    required this.qty,
    required this.unit,
    required this.unitName,
    required this.price,
    required this.total,
    required this.action,
    required this.qtyPcs,
  });

  factory StockAjustCart.fromJson(Map<String, dynamic> json) {
    return StockAjustCart(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      group: json['group'] ?? '',
      brand: json['brand'] ?? '',
      size: json['size'] ?? '',
      flavour: json['flavour'] ?? '',
      qty: json['qty'] ?? 0,
      unit: json['unit'] ?? '',
      unitName: json['unitName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      action: json['action'] ?? '',
      qtyPcs: json['qtyPcs'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group': group,
        'brand': brand,
        'size': size,
        'flavour': flavour,
        'qty': qty,
        'unit': unit,
        'unitName': unitName,
        'price': price,
        'total': total,
        'action': action,
        'qtyPcs': qtyPcs,
      };
}
