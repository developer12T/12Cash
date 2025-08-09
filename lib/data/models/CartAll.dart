class CartAll {
  final String id;
  final String mongoId;
  final String type;
  final String area;
  final String storeId;
  final double total;
  final List<ProductModel> listProduct;
  final List<RefundModel> listRefund;
  final String cartHashProduct;
  final String cartHashPromotion;
  final List<PromotionModel> listPromotion;
  final List<dynamic> listQuota;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  CartAll({
    required this.id,
    required this.mongoId,
    required this.type,
    required this.area,
    required this.storeId,
    required this.total,
    required this.listProduct,
    required this.listRefund,
    required this.cartHashProduct,
    required this.cartHashPromotion,
    required this.listPromotion,
    required this.listQuota,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory CartAll.fromJson(Map<String, dynamic> json) {
    return CartAll(
      id: json['id'] ?? '',
      mongoId: json['_id'] ?? '',
      type: json['type'] ?? '',
      area: json['area'] ?? '',
      storeId: json['storeId'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      listProduct: (json['listProduct'] ?? [])
          .map<ProductModel>((e) => ProductModel.fromJson(e))
          .toList(),
      listRefund: (json['listRefund'] ?? [])
          .map<RefundModel>((e) => RefundModel.fromJson(e))
          .toList(),
      cartHashProduct: json['cartHashProduct'] ?? '',
      cartHashPromotion: json['cartHashPromotion'] ?? '',
      listPromotion: (json['listPromotion'] ?? [])
          .map<PromotionModel>((e) => PromotionModel.fromJson(e))
          .toList(),
      listQuota: json['listQuota'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': mongoId,
      'type': type,
      'area': area,
      'storeId': storeId,
      'total': total,
      'listProduct': listProduct.map((e) => e.toJson()).toList(),
      'listRefund': listRefund.map((e) => e.toJson()).toList(),
      'cartHashProduct': cartHashProduct,
      'cartHashPromotion': cartHashPromotion,
      'listPromotion': listPromotion.map((e) => e.toJson()).toList(),
      'listQuota': listQuota,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class ProductModel {
  final String id;
  final String name;
  final int qty;
  final String unit;
  final double price;
  final String mongoId;

  ProductModel({
    required this.id,
    required this.name,
    required this.qty,
    required this.unit,
    required this.price,
    required this.mongoId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      qty: json['qty'] ?? 0,
      unit: json['unit'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      mongoId: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'qty': qty,
      'unit': unit,
      'price': price,
      '_id': mongoId,
    };
  }
}

class RefundModel {
  final String id;
  final String lot;
  final String name;
  final int qty;
  final String unit;
  final double price;
  final String condition;
  final String expireDate;
  final String mongoId;

  RefundModel({
    required this.id,
    required this.lot,
    required this.name,
    required this.qty,
    required this.unit,
    required this.price,
    required this.condition,
    required this.expireDate,
    required this.mongoId,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      id: json['id'] ?? '',
      lot: json['lot'] ?? '',
      name: json['name'] ?? '',
      qty: json['qty'] ?? 0,
      unit: json['unit'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      condition: json['condition'] ?? '',
      expireDate: json['expireDate'] ?? '',
      mongoId: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lot': lot,
      'name': name,
      'qty': qty,
      'unit': unit,
      'price': price,
      'condition': condition,
      'expireDate': expireDate,
      '_id': mongoId,
    };
  }
}

class PromotionModel {
  final String proId;
  final String proCode;
  final String proName;
  final String proType;
  final int proQty;
  final double discount;
  final List<PromotionProductModel> listProduct;
  final String mongoId;

  PromotionModel({
    required this.proId,
    required this.proCode,
    required this.proName,
    required this.proType,
    required this.proQty,
    required this.discount,
    required this.listProduct,
    required this.mongoId,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      proId: json['proId'] ?? '',
      proCode: json['proCode'] ?? '',
      proName: json['proName'] ?? '',
      proType: json['proType'] ?? '',
      proQty: json['proQty'] ?? 0,
      discount: (json['discount'] ?? 0).toDouble(),
      listProduct: (json['listProduct'] ?? [])
          .map<PromotionProductModel>((e) => PromotionProductModel.fromJson(e))
          .toList(),
      mongoId: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proId': proId,
      'proCode': proCode,
      'proName': proName,
      'proType': proType,
      'proQty': proQty,
      'discount': discount,
      'listProduct': listProduct.map((e) => e.toJson()).toList(),
      '_id': mongoId,
    };
  }
}

class PromotionProductModel {
  final String id;
  final String lot;
  final String name;
  final String group;
  final String flavour;
  final String brand;
  final String size;
  final int qty;
  final String unit;
  final String unitName;
  final int qtyPcs;
  final String mongoId;

  PromotionProductModel({
    required this.id,
    required this.lot,
    required this.name,
    required this.group,
    required this.flavour,
    required this.brand,
    required this.size,
    required this.qty,
    required this.unit,
    required this.unitName,
    required this.qtyPcs,
    required this.mongoId,
  });

  factory PromotionProductModel.fromJson(Map<String, dynamic> json) {
    return PromotionProductModel(
      id: json['id'] ?? '',
      lot: json['lot'] ?? '',
      name: json['name'] ?? '',
      group: json['group'] ?? '',
      flavour: json['flavour'] ?? '',
      brand: json['brand'] ?? '',
      size: json['size'] ?? '',
      qty: json['qty'] ?? 0,
      unit: json['unit'] ?? '',
      unitName: json['unitName'] ?? '',
      qtyPcs: json['qtyPcs'] ?? 0,
      mongoId: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lot': lot,
      'name': name,
      'group': group,
      'flavour': flavour,
      'brand': brand,
      'size': size,
      'qty': qty,
      'unit': unit,
      'unitName': unitName,
      'qtyPcs': qtyPcs,
      '_id': mongoId,
    };
  }
}
