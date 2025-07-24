class GiveOrder {
  final String id;
  final String type;
  final String orderId;
  final GiveInfo? giveInfo;
  final Sale? sale;
  final Store? store;
  final Shipping? shipping;
  final String note;
  final String latitude;
  final String longitude;
  final String status;
  final List<Product> listProduct;
  final double totalVat;
  final double totalExVat;
  final double total;
  final List<ListImage> listImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GiveOrder({
    required this.id,
    required this.type,
    required this.orderId,
    required this.giveInfo,
    required this.sale,
    required this.store,
    required this.shipping,
    required this.note,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.listProduct,
    required this.totalVat,
    required this.totalExVat,
    required this.total,
    required this.listImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GiveOrder.fromJson(Map<String, dynamic> json) {
    List<Product> safeProductList = [];
    if (json['listProduct'] is List) {
      safeProductList = (json['listProduct'] as List)
          .where((item) => item != null)
          .map((item) => Product.fromJson(item))
          .toList();
    }

    List<ListImage> safeImageList = [];
    if (json['listImage'] is List) {
      safeImageList = (json['listImage'] as List)
          .where((item) => item != null)
          .map((item) => ListImage.fromJson(item))
          .toList();
    }

    DateTime? safeCreatedAt;
    if (json['createdAt'] != null) {
      try {
        safeCreatedAt = DateTime.parse(json['createdAt']);
      } catch (_) {
        safeCreatedAt = null;
      }
    }

    DateTime? safeUpdatedAt;
    if (json['updatedAt'] != null) {
      try {
        safeUpdatedAt = DateTime.parse(json['updatedAt']);
      } catch (_) {
        safeUpdatedAt = null;
      }
    }

    return GiveOrder(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      giveInfo:
          json['giveInfo'] != null ? GiveInfo.fromJson(json['giveInfo']) : null,
      sale: json['sale'] != null ? Sale.fromJson(json['sale']) : null,
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      shipping:
          json['shipping'] != null ? Shipping.fromJson(json['shipping']) : null,
      note: json['note']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      listProduct: safeProductList,
      totalVat: _safeDouble(json['totalVat']),
      totalExVat: _safeDouble(json['totalExVat']),
      total: _safeDouble(json['total']),
      listImage: safeImageList,
      createdAt: safeCreatedAt,
      updatedAt: safeUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "type": type,
      "orderId": orderId,
      "giveInfo": giveInfo?.toJson(),
      "sale": sale?.toJson(),
      "store": store?.toJson(),
      "shipping": shipping?.toJson(),
      "note": note,
      "latitude": latitude,
      "longitude": longitude,
      "status": status,
      "listProduct": listProduct.map((item) => item.toJson()).toList(),
      "totalVat": totalVat,
      "totalExVat": totalExVat,
      "total": total,
      "listImage": listImage.map((item) => item.toJson()).toList(),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}

// Safe double parsing utility
double _safeDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

// -----------------
// Child models (แก้ null safety เช่นเดียวกัน)
// -----------------

class GiveInfo {
  final String name;
  final String type;
  final String remark;
  final String dept;
  final String id;

  GiveInfo({
    required this.name,
    required this.type,
    required this.remark,
    required this.dept,
    required this.id,
  });

  factory GiveInfo.fromJson(Map<String, dynamic> json) {
    return GiveInfo(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      dept: json['dept']?.toString() ?? '',
      id: json['_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
        "remark": remark,
        "dept": dept,
        "_id": id,
      };
}

class Sale {
  final String saleCode;
  final String salePayer;
  final String name;
  final String tel;
  final String warehouse;
  final String id;

  Sale({
    required this.saleCode,
    required this.salePayer,
    required this.name,
    required this.tel,
    required this.warehouse,
    required this.id,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      saleCode: json['saleCode']?.toString() ?? '',
      salePayer: json['salePayer']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tel: json['tel']?.toString() ?? '',
      warehouse: json['warehouse']?.toString() ?? '',
      id: json['_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "saleCode": saleCode,
        "salePayer": salePayer,
        "name": name,
        "tel": tel,
        "warehouse": warehouse,
        "_id": id,
      };
}

class Store {
  final String storeId;
  final String name;
  final String address;
  final String taxId;
  final String tel;
  final String area;
  final String zone;
  final String id;

  Store({
    required this.storeId,
    required this.name,
    required this.address,
    required this.taxId,
    required this.tel,
    required this.area,
    required this.zone,
    required this.id,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['storeId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      taxId: json['taxId']?.toString() ?? '',
      tel: json['tel']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      zone: json['zone']?.toString() ?? '',
      id: json['_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "storeId": storeId,
        "name": name,
        "address": address,
        "taxId": taxId,
        "tel": tel,
        "area": area,
        "zone": zone,
        "_id": id,
      };
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
      shippingId: json['shippingId']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      id: json['_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "shippingId": shippingId,
        "address": address,
        "_id": id,
      };
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
  final int qtyPcs;
  final double price;
  final double total;

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
    required this.qtyPcs,
    required this.price,
    required this.total,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      flavour: json['flavour']?.toString() ?? '',
      qty: _safeInt(json['qty']),
      unit: json['unit']?.toString() ?? '',
      unitName: json['unitName']?.toString() ?? '',
      qtyPcs: _safeInt(json['qtyPcs']),
      price: _safeDouble(json['price']),
      total: _safeDouble(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "group": group,
        "brand": brand,
        "size": size,
        "flavour": flavour,
        "qty": qty,
        "unit": unit,
        "unitName": unitName,
        "qtyPcs": qtyPcs,
        "price": price,
        "total": total,
      };
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

  factory ListImage.fromJson(Map<String, dynamic> json) {
    return ListImage(
      name: json['name']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'type': type,
    };
  }
}

// Helper function for safe int parsing
int _safeInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
