class PromotionList {
  final String? proId;
  final String? proName;
  final String? proCode;
  final String? proType;
  final int? proQty;
  final double discount;
  final List<PromotionListItem> listProduct;

  PromotionList({
    required this.proId,
    required this.proName,
    required this.proCode,
    required this.proType,
    required this.proQty,
    required this.discount,
    required this.listProduct,
  });

  // ✅ Convert JSON to Dart Object
  factory PromotionList.fromJson(Map<String, dynamic> json) {
    return PromotionList(
      proId: json['proId'], //  field name
      proName: json['proName'], //  field name
      proCode: json['proCode'], //  field name
      listProduct: (json['listProduct'] as List<dynamic>?)
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
      'proCode': proCode,
      'proType': proType,
      'proQty': proQty,
      'discount': discount,
      'listProduct': listProduct.map((item) => item.toJson()).toList(),
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
  String? proCode;
  String? proType;
  int qty;
  int qtyBal;

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
    this.proCode,
    this.proType,
    required this.qty,
    required this.qtyBal,
  });

  factory PromotionListItem.fromJson(Map<String, dynamic> json) {
    return PromotionListItem(
      id: json['id'],
      name: json['name'],
      group: json['group'],
      flavour: json['flavour'],
      brand: json['brand'],
      size: json['size'],
      unit: json['unit'],
      unitName: json['unitName'],
      proId: json['proId'],
      proName: json['proName'],
      proCode: json['proCode'],
      proType: json['proType'],
      qty: json['qty'] as int? ?? 0,
      qtyBal: json['qtyBal'] as int? ?? 0,
    );
  }

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
      'proCode': proCode,
      'proType': proType,
      'qty': qty,
      'qtyBal': qtyBal,
    };
  }
}

// ✅ ต้องอยู่ “นอก class” เท่านั้น
extension PromotionListItemCopy on PromotionListItem {
  PromotionListItem copyWith({
    String? id,
    String? name,
    String? group,
    String? flavour,
    String? brand,
    String? size,
    String? unit,
    String? unitName,
    String? proId,
    String? proName,
    String? proCode,
    String? proType,
    int? qty,
    int? qtyBal,
  }) {
    return PromotionListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      group: group ?? this.group,
      flavour: flavour ?? this.flavour,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      unit: unit ?? this.unit,
      unitName: unitName ?? this.unitName,
      proId: proId ?? this.proId,
      proName: proName ?? this.proName,
      proCode: proCode ?? this.proCode,
      proType: proType ?? this.proType,
      qty: qty ?? this.qty,
      qtyBal: qtyBal ?? this.qtyBal,
    );
  }
}
