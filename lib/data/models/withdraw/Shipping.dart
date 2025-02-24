class ShippingData {
  final String type;
  final String typeNameTH;
  final String typeNameEN;
  final String shippingId;
  final String route;
  final String name;
  final String address;
  final String district;
  final String subDistrict;
  final String province;
  final String postcode;
  final String tel;
  final Warehouse warehouse;
  final String id;

  ShippingData({
    required this.type,
    required this.typeNameTH,
    required this.typeNameEN,
    required this.shippingId,
    required this.route,
    required this.name,
    required this.address,
    required this.district,
    required this.subDistrict,
    required this.province,
    required this.postcode,
    required this.tel,
    required this.warehouse,
    required this.id,
  });

  factory ShippingData.fromJson(Map<String, dynamic> json) {
    return ShippingData(
      type: json['type'],
      typeNameTH: json['typeNameTH'],
      typeNameEN: json['typeNameEN'],
      shippingId: json['shippingId'],
      route: json['route'],
      name: json['name'],
      address: json['address'],
      district: json['district'],
      subDistrict: json['subDistrict'],
      province: json['province'],
      postcode: json['postcode'],
      tel: json['tel'],
      warehouse: Warehouse.fromJson(json['warehouse']),
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "typeNameTH": typeNameTH,
      "typeNameEN": typeNameEN,
      "shippingId": shippingId,
      "route": route,
      "name": name,
      "address": address,
      "district": district,
      "subDistrict": subDistrict,
      "province": province,
      "postcode": postcode,
      "tel": tel,
      "warehouse": warehouse.toJson(),
      "_id": id,
    };
  }
}

class Warehouse {
  final String normal;
  final String clearance;
  final String id;

  Warehouse({
    required this.normal,
    required this.clearance,
    required this.id,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      normal: json['normal'],
      clearance: json['clearance'],
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "normal": normal,
      "clearance": clearance,
      "_id": id,
    };
  }
}
