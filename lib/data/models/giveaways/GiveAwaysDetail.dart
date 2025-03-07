import 'dart:convert';

class GiveOrder {
  final String id;
  final String type;
  final String orderId;
  final GiveInfo giveInfo;
  final Sale sale;
  final Store store;
  final Shipping shipping;
  final String note;
  final String latitude;
  final String longitude;
  final String status;
  final List<Product> listProduct;
  final double totalVat;
  final double totalExVat;
  final double total;
  final List<ListImage> listImage;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    return GiveOrder(
      id: json['_id'],
      type: json['type'],
      orderId: json['orderId'],
      giveInfo: GiveInfo.fromJson(json['giveInfo']),
      sale: Sale.fromJson(json['sale']),
      store: Store.fromJson(json['store']),
      shipping: Shipping.fromJson(json['shipping']),
      note: json['note'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      status: json['status'],
      listProduct: (json['listProduct'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      totalVat: (json['totalVat'] ?? 0).toDouble(),
      totalExVat: (json['totalExVat'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      listImage: (json['listImage'] as List)
          .map((item) => ListImage.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "type": type,
      "orderId": orderId,
      "giveInfo": giveInfo.toJson(),
      "sale": sale.toJson(),
      "store": store.toJson(),
      "shipping": shipping.toJson(),
      "note": note,
      "latitude": latitude,
      "longitude": longitude,
      "status": status,
      "listProduct": listProduct.map((item) => item.toJson()).toList(),
      "totalVat": totalVat,
      "totalExVat": totalExVat,
      "total": total,
      "listImage": listImage,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

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
      name: json['name'],
      type: json['type'],
      remark: json['remark'],
      dept: json['dept'],
      id: json['_id'],
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
      saleCode: json['saleCode'],
      salePayer: json['salePayer'],
      name: json['name'],
      tel: json['tel'],
      warehouse: json['warehouse'],
      id: json['_id'],
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
      storeId: json['storeId'],
      name: json['name'],
      address: json['address'],
      taxId: json['taxId'],
      tel: json['tel'],
      area: json['area'],
      zone: json['zone'],
      id: json['_id'],
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
      shippingId: json['shippingId'],
      address: json['address'],
      id: json['_id'],
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
      id: json['id'],
      name: json['name'],
      group: json['group'],
      brand: json['brand'],
      size: json['size'],
      flavour: json['flavour'],
      qty: json['qty'],
      unit: json['unit'],
      unitName: json['unitName'],
      qtyPcs: json['qtyPcs'],
      price: json['price'].toDouble(),
      total: json['total'].toDouble(),
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
