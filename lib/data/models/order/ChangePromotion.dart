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

  ItemProductChange({
    required this.id,
    required this.name,
  });

  factory ItemProductChange.fromJson(Map<String, dynamic> json) {
    return ItemProductChange(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// class ProductList {
//   final List<ProductGroup> listProduct;

//   ProductList({required this.listProduct});

//   factory ProductList.fromJson(Map<String, dynamic> json) {
//     return ProductList(
//       listProduct: (json['listProduct'] as List)
//           .map((item) => ProductGroup.fromJson(item))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'listProduct': listProduct.map((item) => item.toJson()).toList(),
//     };
//   }
// }
