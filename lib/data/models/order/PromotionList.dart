import 'package:_12sale_app/data/models/order/Promotion.dart';

class PromotionChangeList {
  final String? proId;
  final String? proName;
  final String? proCode;
  final String? proType;
  final int? proQty;
  final List<PromotionListItem> promotionListItem;

  PromotionChangeList({
    required this.proId,
    required this.proName,
    required this.proCode,
    required this.proType,
    required this.proQty,
    required this.promotionListItem,
  });

  factory PromotionChangeList.fromJson(Map<String, dynamic> json) {
    return PromotionChangeList(
      proId: json['proId'], //  field name
      proName: json['proName'], //  field name
      proCode: json['proCode'], //  field name
      proType: json['proType'], //  field name
      proQty: json['proQty'], //  field name
      promotionListItem: (json['promotionListItem'] as List<dynamic>?)
              ?.map((unit) => PromotionListItem.fromJson(unit))
              .toList() ??
          [], // ✅ Default to empty list if null✅ Default to empty list if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proId': proId,
      'proName': proName,
      'proCode': proCode,
      'proType': proType,
      'proQty': proQty,
      "promotionListItem":
          promotionListItem.map((item) => item.toJson()).toList(),
    };
  }
}
