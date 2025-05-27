import 'dart:convert';

class WithdrawDetail {
  String id;
  String orderId;
  String orderType;
  String orderTypeName;
  String area;
  String fromWarehouse;
  String toWarehouse;
  String shippingId;
  String shippingRoute;
  String shippingName;
  String sendAddress;
  DateTime sendDate;
  String remark;
  List<Product> listProductWithdraw;
  List<Product> listProductReceive;
  double totalWithdraw;
  int totalQtyWithdraw;
  double totalReceive;
  int totalQtyReceive;
  double totalWeightGrossWithdraw;
  double totalWeightNetWithdraw;
  double totalWeightGrossReceive;
  double totalWeightNetReceive;
  String status;
  DateTime created;
  DateTime updated;
  int version;

  WithdrawDetail({
    required this.id,
    required this.orderId,
    required this.orderType,
    required this.orderTypeName,
    required this.area,
    required this.fromWarehouse,
    required this.toWarehouse,
    required this.shippingId,
    required this.shippingRoute,
    required this.shippingName,
    required this.sendAddress,
    required this.sendDate,
    required this.remark,
    required this.listProductWithdraw,
    required this.listProductReceive,
    required this.totalWithdraw,
    required this.totalQtyWithdraw,
    required this.totalReceive,
    required this.totalQtyReceive,
    required this.totalWeightGrossWithdraw,
    required this.totalWeightNetWithdraw,
    required this.totalWeightGrossReceive,
    required this.totalWeightNetReceive,
    required this.status,
    required this.created,
    required this.updated,
    required this.version,
  });

  // Factory constructor to parse JSON
  factory WithdrawDetail.fromJson(Map<String, dynamic> json) {
    return WithdrawDetail(
      id: json["_id"] ?? "",
      orderId: json["orderId"] ?? "",
      orderType: json["orderType"] ?? "",
      orderTypeName: json["orderTypeName"] ?? "",
      area: json["area"] ?? "",
      fromWarehouse: json["fromWarehouse"] ?? "",
      toWarehouse: json["toWarehouse"] ?? "",
      shippingId: json["shippingId"] ?? "",
      shippingRoute: json["shippingRoute"] ?? "",
      shippingName: json["shippingName"] ?? "",
      sendAddress: json["sendAddress"] ?? "",
      sendDate: DateTime.parse(json["sendDate"]),
      remark: json["remark"],
      listProductWithdraw: (json['listProductWithdraw'] as List<dynamic>?)
              ?.map((unit) => Product.fromJson(unit))
              .toList() ??
          [], // ✅ Default to empty list if null
      listProductReceive: (json['listProductReceive'] as List<dynamic>?)
              ?.map((unit) => Product.fromJson(unit))
              .toList() ??
          [], // ✅ Default to empty list if null
      totalWithdraw: json["totalWithdraw"].toDouble() ?? 00.00,
      totalQtyWithdraw: json["totalQtyWithdraw"] ?? 0,
      totalReceive: json["totalReceive"].toDouble() ?? 00.00,
      totalQtyReceive: json["totalQtyReceive"] ?? 0,
      totalWeightGrossWithdraw:
          json["totalWeightGrossWithdraw"].toDouble() ?? 00.00,
      totalWeightNetWithdraw:
          json["totalWeightNetWithdraw"].toDouble() ?? 00.00,
      totalWeightGrossReceive:
          json["totalWeightGrossReceive"].toDouble() ?? 00.00,
      totalWeightNetReceive: json["totalWeightNetReceive"].toDouble() ?? 00.00,
      status: json["status"] ?? "",
      created: DateTime.parse(json["created"]),
      updated: DateTime.parse(json["updated"]),
      version: json["__v"] ?? 0,
    );
  }

  // Convert back to JSON
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "orderId": orderId,
      "orderType": orderType,
      "orderTypeName": orderTypeName,
      "area": area,
      "fromWarehouse": fromWarehouse,
      "toWarehouse": toWarehouse,
      "shippingId": shippingId,
      "shippingRoute": shippingRoute,
      "shippingName": shippingName,
      "sendAddress": sendAddress,
      "sendDate": sendDate.toIso8601String(),
      "remark": remark,
      "listProductWithdraw":
          listProductWithdraw.map((e) => e.toJson()).toList(),
      "listProductReceive": listProductReceive.map((e) => e.toJson()).toList(),
      "totalWithdraw": totalWithdraw,
      "totalQtyWithdraw": totalQtyWithdraw,
      "totalReceive": totalReceive,
      "totalQtyReceive": totalQtyReceive,
      "totalWeightGrossWithdraw": totalWeightGrossWithdraw,
      "totalWeightNetWithdraw": totalWeightNetWithdraw,
      "totalWeightGrossReceive": totalWeightGrossReceive,
      "totalWeightNetReceive": totalWeightNetReceive,
      "status": status,
      "created": created.toIso8601String(),
      "updated": updated.toIso8601String(),
      "__v": version,
    };
  }
}

class Product {
  String id;
  String name;
  String group;
  String brand;
  String size;
  String flavour;
  int qty;
  String unit;
  int qtyPcs;
  double price;
  double netTotal;
  double weightGross;
  double weightNet;
  String productId;

  Product({
    required this.id,
    required this.name,
    required this.group,
    required this.brand,
    required this.size,
    required this.flavour,
    required this.qty,
    required this.unit,
    required this.qtyPcs,
    required this.price,
    required this.netTotal,
    required this.weightGross,
    required this.weightNet,
    required this.productId,
  });

  // Factory constructor to parse JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      group: json["group"] ?? "",
      brand: json["brand"] ?? "",
      size: json["size"] ?? "",
      flavour: json["flavour"] ?? "",
      qty: json["qty"] ?? 0,
      unit: json["unit"] ?? "",
      qtyPcs: json["qtyPcs"] ?? 0,
      price: json["price"].toDouble() ?? 00.00,
      netTotal: json["netTotal"].toDouble() ?? 00.00,
      weightGross: json["weightGross"].toDouble() ?? 0.00,
      weightNet: json["weightNet"].toDouble() ?? 00.00,
      productId: json["_id"] ?? "",
    );
  }

  // Convert back to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "group": group,
      "brand": brand,
      "size": size,
      "flavour": flavour,
      "qty": qty,
      "unit": unit,
      "qtyPcs": qtyPcs,
      "price": price,
      "netTotal": netTotal,
      "weightGross": weightGross,
      "weightNet": weightNet,
      "_id": productId,
    };
  }
}
