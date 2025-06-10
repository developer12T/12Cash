class PromotionList {
  final String? proId;
  final String? proName;
  final String? proType;
  final int? proQty;
  final double discount;
  final List<PromotionListItem> listPromotion;

  PromotionList({
    required this.proId,
    required this.proName,
    required this.proType,
    required this.proQty,
    required this.discount,
    required this.listPromotion,
  });

  // ✅ Convert JSON to Dart Object
  factory PromotionList.fromJson(Map<String, dynamic> json) {
    return PromotionList(
      proId: json['proId'], //  field name
      proName: json['proName'], //  field name
      listPromotion: (json['listProduct'] as List<dynamic>?)
              ?.map((unit) => PromotionListItem.fromJson(unit))
              .toList() ??
          [], // ✅ Default to empty list if null
      proType: json['proType'], //  field name
      proQty: json['proQty'], //  field name
      discount: (json['discount'] as num).toDouble(), //  it's double
    );
  }

  // ✅ Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'proId': proId,
      'proName': proName,
      'proType': proType,
      'proQty': proQty,
      'discount': discount,
      'listProduct': listPromotion.map((item) => item.toJson()).toList(),
    };
  }
}

class PromotionListItem {
  final String id;
  final String name;
  final String group;
  final String flavour;
  final String brand;
  final String size;
  final String unit;
  final String unitName;
  String? proId;
  String? proName;
  String? proType;
  int qty;
  PromotionListItem({
    required this.id,
    required this.name,
    required this.group,
    required this.flavour,
    required this.brand,
    required this.size,
    required this.unit,
    required this.unitName,
    this.proId,
    this.proName,
    this.proType,
    required this.qty,
  });

  // ✅ Convert JSON to Dart Object
  factory PromotionListItem.fromJson(Map<String, dynamic> json) {
    return PromotionListItem(
      id: json['id'], //  field name
      name: json['name'], //  field name
      group: json['group'], //  field name
      flavour: json['flavour'], //  field name
      brand: json['brand'], //  field name
      size: json['size'], //  field name
      unit: json['unit'], //  field name
      unitName: json['unitName'], //  field name
      proId: json['proId'], //  field name
      proName: json['proName'], //  field name
      proType: json['proType'], //  field name
      qty: json['qty'] as int, //  it's int
    );
  }

  // ✅ Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'group': group,
      'flavour': flavour,
      'brand': brand,
      'size': size,
      'unit': unit,
      'unitName': unitName,
      'proId': proId,
      'proName': proName,
      'qty': qty,
    };
  }
}
