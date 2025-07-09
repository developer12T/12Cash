class OrderDetail {
  final String type;
  final String orderId;
  final Sale sale;
  final Store store;
  final String note;
  final String latitude;
  final String longitude;
  final String status;
  final List<Product> listProduct;
  final List<Promotion> listPromotions;
  final double subtotal;
  final double discount;
  final double discountProduct;
  final double vat;
  final double totalExVat;
  final double total;
  final Shipping shipping;
  final String paymentMethod;
  final String paymentStatus;
  final List<ListImage> listImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderDetail({
    required this.type,
    required this.orderId,
    required this.sale,
    required this.store,
    required this.note,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.listProduct,
    required this.listPromotions,
    required this.subtotal,
    required this.discount,
    required this.discountProduct,
    required this.vat,
    required this.totalExVat,
    required this.total,
    required this.shipping,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.listImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      type: json['type'] ?? '',
      orderId: json['orderId'] ?? '',
      sale: Sale.fromJson(json['sale']),
      store: Store.fromJson(json['store']),
      note: json['note'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      status: json['status'] ?? '',
      listProduct: json['listProduct'] is List
          ? (json['listProduct'] as List)
              .map((item) => Product.fromJson(item))
              .toList()
          : [],
      listPromotions: (json['listPromotions'] as List)
          .map((item) => Promotion.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble() ?? '',
      discount: json['discount'].toDouble() ?? '',
      discountProduct: json['discountProduct'].toDouble() ?? '',
      vat: json['vat'].toDouble(),
      totalExVat: json['totalExVat'].toDouble(),
      total: json['total'].toDouble(),
      shipping: Shipping.fromJson(json['shipping']),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      listImage: (json['listImage'] as List)
          .map((item) => ListImage.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Sale {
  final String salePayer;
  final String name;
  final String tel;
  final String warehouse;

  Sale({
    required this.salePayer,
    required this.name,
    required this.tel,
    required this.warehouse,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      salePayer: json['salePayer'],
      name: json['name'],
      tel: json['tel'],
      warehouse: json['warehouse'],
    );
  }
}

class Store {
  final String storeId;
  final String name;
  final String address;
  final String taxId;
  final String tel;
  final String area;
  final String zone;

  Store({
    required this.storeId,
    required this.name,
    required this.address,
    required this.taxId,
    required this.tel,
    required this.area,
    required this.zone,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['storeId'],
      name: json['name'],
      address: json['address'],
      taxId: json['taxId'],
      tel: json['tel'],
      area: json['area'],
      zone: json['zone'],
    );
  }
}

class Product {
  final String id;
  final String name;
  final String group;
  final String brand;
  final String size;
  final String flavour;
  final int qty;
  final String unit;
  final String unitName;
  final double price;
  final double subtotal;
  final double discount;
  final double netTotal;

  Product({
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
    required this.subtotal,
    required this.discount,
    required this.netTotal,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      group: json['group'],
      brand: json['brand'],
      size: json['size'],
      flavour: json['flavour'],
      qty: json['qty'],
      unit: json['unit'],
      unitName: json['unitName'] ?? '',
      price: json['price'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
      discount: json['discount'].toDouble(),
      netTotal: json['netTotal'].toDouble(),
    );
  }
}

class Promotion {
  final String proName;
  final String proType;
  final int proQty;
  final double discount;
  final List<PromotionListItem> listPromotion;

  Promotion({
    required this.proName,
    required this.proType,
    required this.proQty,
    required this.discount,
    required this.listPromotion,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      proName: json['proName'],
      proType: json['proType'],
      proQty: json['proQty'],
      discount: json['discount'].toDouble(),
      listPromotion: (json['listProduct'] as List)
          .map((item) => PromotionListItem.fromJson(item))
          .toList(),
    );
  }
}

class Shipping {
  final String shippingId;
  final String address;
  final String id;

  Shipping({
    required this.shippingId,
    required this.address,
    required this.id,
  });

  factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      shippingId: json['shippingId'],
      address: json['address'],
      id: json['_id'],
    );
  }
}

class ListImage {
  final String name;
  final String path;
  final String type;

  ListImage({
    required this.name,
    required this.path,
    required this.type,
  });

  // ✅ Convert JSON to Dart Object
  factory ListImage.fromJson(Map<String, dynamic> json) {
    return ListImage(
      name: json['name'] ?? '', //  field name
      path: json['path'] ?? '', //  field name
      type: json['type'] ?? '', //  field name
    );
  }

  // ✅ Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'type': type,
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
  final int qty;
  PromotionListItem({
    required this.id,
    required this.name,
    required this.group,
    required this.flavour,
    required this.brand,
    required this.size,
    required this.unit,
    required this.unitName,
    required this.qty,
  });

  // ✅ Convert JSON to Dart Object
  factory PromotionListItem.fromJson(Map<String, dynamic> json) {
    return PromotionListItem(
      id: json['id'] ?? '', //  field name
      name: json['name'] ?? '', //  field name
      group: json['group'] ?? '', //  field name
      flavour: json['flavour'] ?? '', //  field name
      brand: json['brand'] ?? '', //  field name
      size: json['size'] ?? '', //  field name
      unit: json['unit'] ?? '', //  field name
      unitName: json['unitName'] ?? '', //  field name
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
      'qty': qty,
    };
  }
}
