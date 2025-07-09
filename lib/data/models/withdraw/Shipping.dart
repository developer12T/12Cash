class ShippingData {
  final String? type;
  final String? typeNameTH;
  final String? typeNameEN;
  final String? shippingId;
  final String? route;
  final String? name;
  final String? address;
  final String? district;
  final String? subDistrict;
  final String? province;
  final String? postcode;
  final String? tel;
  final Warehouse? warehouse;
  final String? id;

  ShippingData({
    this.type,
    this.typeNameTH,
    this.typeNameEN,
    this.shippingId,
    this.route,
    this.name,
    this.address,
    this.district,
    this.subDistrict,
    this.province,
    this.postcode,
    this.tel,
    this.warehouse,
    this.id,
  });

  factory ShippingData.fromJson(Map<String, dynamic> json) {
    return ShippingData(
      type: json['type'] as String?,
      typeNameTH: json['typeNameTH'] as String?,
      typeNameEN: json['typeNameEN'] as String?,
      shippingId: json['shippingId'] as String?,
      route: json['route'] as String?,
      name: json['name'] as String?,
      address: json['address'] as String?,
      district: json['district'] as String?,
      subDistrict: json['subDistrict'] as String?,
      province: json['province'] as String?,
      postcode: json['postcode'] as String?,
      tel: json['tel'] as String?,
      warehouse: json['warehouse'] != null
          ? Warehouse.fromJson(json['warehouse'])
          : null,
      id: json['_id'] as String?,
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
      "warehouse": warehouse?.toJson(),
      "_id": id,
    };
  }
}

class Warehouse {
  final String? normal;
  final String? clearance;
  final String? id;

  Warehouse({
    this.normal,
    this.clearance,
    this.id,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      normal: json['normal'] as String?,
      clearance: json['clearance'] as String?,
      id: json['_id'] as String?,
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
