import 'package:_12sale_app/data/models/order/Promotion.dart';

class ProductGroup {
  final String group;
  final String size;
  // final String proId;

  final List<ItemProductChange> product;

  ProductGroup({
    required this.group,
    required this.size,
    // required this.proId,
    required this.product,
  });

  factory ProductGroup.fromJson(Map<String, dynamic> json) {
    return ProductGroup(
      group: json['group'],
      size: json['size'],
      // proId: json['proId'],
      product: (json['product'] as List)
          .map((item) => ItemProductChange.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group': group,
      'size': size,
      // 'proId': proId,
      'product': product.map((item) => item.toJson()).toList(),
    };
  }
}

class GroupPromotion {
  final String group;
  final String size;
  GroupPromotion({
    required this.group,
    required this.size,
  });

  factory GroupPromotion.fromJson(Map<String, dynamic> json) {
    return GroupPromotion(
      group: json['group'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group': group,
      'size': size,
    };
  }
}

class TotalProductChang {
  String proId;
  int total;
  int totalShow;

  TotalProductChang({
    required this.proId,
    required this.total,
    required this.totalShow,
  });

  factory TotalProductChang.fromJson(Map<String, dynamic> json) {
    return TotalProductChang(
      proId: json['proId'],
      total: json['qty'],
      totalShow: json['qty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proId': proId,
      'total': total,
      'totalShow': totalShow,
    };
  }
}

class ItemProductChange {
  final String id;
  final String name;
  final String group;
  final String flavour;
  final String brand;
  final String size;
  int qty;
  int qtyBal;

  ItemProductChange({
    required this.id,
    required this.name,
    required this.group,
    required this.flavour,
    required this.brand,
    required this.size,
    required this.qty,
    required this.qtyBal,
  });

  factory ItemProductChange.fromJson(Map<String, dynamic> json) {
    return ItemProductChange(
      id: json['id'],
      name: json['name'],
      group: json['group'],
      flavour: json['flavour'],
      brand: json['brand'],
      size: json['size'],
      qty: json['qty'],
      qtyBal: json['qtyBal'],
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
      'qty': qty,
      'qtyBal': qtyBal,
    };
  }
}

extension ItemProductChangeX on ItemProductChange {
  PromotionListItem toPromotionListItem({
    String? proId,
    String? proName,
    String? proType,
    String? unit,
    String? unitName,
  }) {
    return PromotionListItem(
      id: id,
      name: name,
      group: group,
      flavour: flavour,
      brand: brand,
      size: size,
      unit: unit ?? '',
      unitName: unitName ?? '',
      proId: proId,
      proName: proName,
      proType: proType,
      qty: qty,
      qtyBal: qtyBal,
    );
  }
}
