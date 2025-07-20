class Shipping {
  final String shippingId;
  final String address;
  final String district;
  final String subDistrict;
  final String province;
  final String postCode;
  final String latitude;
  final String longtitude;
  final String id;
  final String isDefault;

  Shipping({
    required this.shippingId,
    required this.address,
    required this.district,
    required this.subDistrict,
    required this.province,
    required this.postCode,
    required this.latitude,
    required this.longtitude,
    required this.id,
    required this.isDefault,
  });

  factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      shippingId: json['shippingId'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
      subDistrict: json['subDistrict'] ?? '',
      province: json['province'] ?? '',
      postCode: json['postCode'] ?? '',
      latitude: json['latitude'] ?? '',
      longtitude: json['longtitude'] ?? '',
      id: json['_id'] ?? '',
      isDefault: json['default'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shippingId': shippingId,
      'address': address,
      'district': district,
      'subDistrict': subDistrict,
      'province': province,
      'postCode': postCode,
      'latitude': latitude,
      'longtitude': longtitude,
      '_id': id,
      'default': isDefault,
    };
  }
}
