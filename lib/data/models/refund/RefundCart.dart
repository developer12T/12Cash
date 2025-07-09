class RefundModel {
  final String type;
  final StoreInfoRefund store;
  final List<ListSaleProduct> listProduct;
  final List<RefundItem> listRefund;
  final String totalRefund;
  final String totalChange;
  final String totalExVat;
  final String totalVat;
  final String totalNet;
  final String updated;

  RefundModel({
    required this.type,
    required this.store,
    required this.listProduct,
    required this.listRefund,
    required this.totalRefund,
    required this.totalChange,
    required this.totalExVat,
    required this.totalVat,
    required this.totalNet,
    required this.updated,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      type: json["type"],
      store: StoreInfoRefund.fromJson(json["store"]),
      listProduct: (json["listProduct"] as List)
          .map((item) => ListSaleProduct.fromJson(item))
          .toList(),
      listRefund: (json["listRefund"] as List)
          .map((item) => RefundItem.fromJson(item))
          .toList(),
      totalRefund: json["totalRefund"] ?? "",
      totalChange: json["totalChange"] ?? "",
      totalExVat: json["totalExVat"] ?? "",
      totalVat: json["totalVat"] ?? "",
      totalNet: json["totalNet"] ?? "",
      updated: json["updated"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "store": store.toJson(),
      "listProduct": listProduct.map((e) => e.toJson()).toList(),
      "listRefund": listRefund.map((e) => e.toJson()).toList(),
      "totalRefund": totalRefund,
      "totalChange": totalChange,
      "totalExVat": totalExVat,
      "totalVat": totalVat,
      "totalNet": totalNet,
      "updated": updated,
    };
  }
}

class StoreInfoRefund {
  final String storeId;
  final String name;
  final String taxId;
  final String tel;
  final String route;
  final String storeType;
  final String typeName;
  final String address;
  final String subDistrict;
  final String district;
  final String province;
  final String zone;
  final String area;

  StoreInfoRefund({
    required this.storeId,
    required this.name,
    required this.taxId,
    required this.tel,
    required this.route,
    required this.storeType,
    required this.typeName,
    required this.address,
    required this.subDistrict,
    required this.district,
    required this.province,
    required this.zone,
    required this.area,
  });

  factory StoreInfoRefund.fromJson(Map<String, dynamic> json) {
    return StoreInfoRefund(
      storeId: json["storeId"],
      name: json["name"],
      taxId: json["taxId"],
      tel: json["tel"],
      route: json["route"],
      storeType: json["storeType"],
      typeName: json["typeName"],
      address: json["address"],
      subDistrict: json["subDistrict"],
      district: json["district"],
      province: json["province"],
      zone: json["zone"],
      area: json["area"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "storeId": storeId,
      "name": name,
      "taxId": taxId,
      "tel": tel,
      "route": route,
      "storeType": storeType,
      "typeName": typeName,
      "address": address,
      "subDistrict": subDistrict,
      "district": district,
      "province": province,
      "zone": zone,
      "area": area,
    };
  }
}

class ListSaleProduct {
  final String id;
  final String name;
  final String group;
  final String brand;
  final String size;
  final String flavour;
  int qty;
  final String unit;
  final String unitName;
  final String qtyPcs;
  final String price;
  final String subtotal;
  final String netTotal;

  ListSaleProduct({
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
    required this.subtotal,
    required this.netTotal,
  });

  factory ListSaleProduct.fromJson(Map<String, dynamic> json) {
    return ListSaleProduct(
      id: json["id"],
      name: json["name"],
      group: json["group"],
      brand: json["brand"],
      size: json["size"],
      flavour: json["flavour"],
      qty: int.parse(json["qty"]),
      unit: json["unit"],
      unitName: json["unitName"],
      qtyPcs: json["qtyPcs"],
      price: json["price"],
      subtotal: json["subtotal"],
      netTotal: json["netTotal"],
    );
  }

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
      "unitName": unitName,
      "qtyPcs": qtyPcs,
      "price": price,
      "subtotal": subtotal,
      "netTotal": netTotal,
    };
  }
}

class RefundItem {
  final String id;
  final String name;
  final String group;
  final String brand;
  final String size;
  final String flavour;
  int qty;
  final String unit;
  final String unitName;
  final String qtyPcs;
  final String price;
  final String condition;
  final String expireDate;

  RefundItem({
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
    required this.condition,
    required this.expireDate,
  });

  factory RefundItem.fromJson(Map<String, dynamic> json) {
    return RefundItem(
      id: json["id"],
      name: json["name"],
      group: json["group"],
      brand: json["brand"],
      size: json["size"],
      flavour: json["flavour"],
      qty: int.parse(json["qty"]),
      unit: json["unit"],
      unitName: json["unitName"],
      qtyPcs: json["qtyPcs"],
      price: json["price"],
      condition: json["condition"],
      expireDate: json["expireDate"],
    );
  }

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
      "unitName": unitName,
      "qtyPcs": qtyPcs,
      "price": price,
      "condition": condition,
      "expireDate": expireDate,
    };
  }
}
