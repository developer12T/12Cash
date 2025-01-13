import 'package:flutter/material.dart';

class Store with ChangeNotifier {
  final String storeId;
  late final String name;
  final String taxId;
  final String tel;
  final String route;
  final String type;
  final String typeName;
  final String address;
  final String district;
  final String subDistrict;
  final String province;
  final String provinceCode;
  final String postCode;
  final String zone;
  final String area;
  final String latitude;
  final String longitude;
  final String lineId;
  final String note;
  final String status;
  final Approve approve;
  final PolicyConsent policyConsent;
  final List<ImageItem> imageList;
  final List<ShippingAddress> shippingAddress;
  final String createdDate;
  final String updatedDate;

  Store({
    required this.storeId,
    required this.name,
    required this.taxId,
    required this.tel,
    required this.route,
    required this.type,
    required this.typeName,
    required this.address,
    required this.district,
    required this.subDistrict,
    required this.province,
    required this.provinceCode,
    required this.postCode,
    required this.zone,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.lineId,
    required this.note,
    required this.status,
    required this.approve,
    required this.policyConsent,
    required this.imageList,
    required this.shippingAddress,
    required this.createdDate,
    required this.updatedDate,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? '',
      taxId: json['taxId'] ?? '',
      tel: json['tel'] ?? '',
      route: json['route'] ?? '',
      type: json['type'] ?? '',
      typeName: json['typeName'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
      subDistrict: json['subDistrict'] ?? '',
      province: json['province'] ?? '',
      provinceCode: json['provinceCode'] ?? '',
      postCode: json['postCode'] ?? '',
      zone: json['zone'] ?? '',
      area: json['area'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longtitude'] ?? '',
      lineId: json['lineId'] ?? '',
      note: json['note'] ?? '',
      status: json['status'] ?? '',
      approve: json['approve'] is Map<String, dynamic>
          ? Approve.fromJson(json['approve'] ?? {})
          : Approve(dateSend: '', dateAction: '', appPerson: ''),
      policyConsent: json['policyConsent'] is Map<String, dynamic>
          ? PolicyConsent.fromJson(json['policyConsent'] ?? {})
          : PolicyConsent(status: '', date: ''),
      imageList: json['imageList'] is List
          ? (json['imageList'] as List)
              .map((e) => ImageItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      shippingAddress: json['shippingAddress'] is List
          ? (json['shippingAddress'] as List)
              .map((e) => ShippingAddress.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      createdDate: json['createdDate'] ?? '',
      updatedDate: json['updatedDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'name': name,
      'taxId': taxId,
      'tel': tel,
      'route': route,
      'type': type,
      'typeName': typeName,
      'address': address,
      'district': district,
      'subDistrict': subDistrict,
      'province': province,
      'provinceCode': provinceCode,
      'postCode': postCode,
      'zone': zone,
      'area': area,
      'latitude': latitude,
      'longtitude': longitude,
      'lineId': lineId,
      'note': note,
      'status': status,
      'approve': approve.toJson(),
      'policyConsent': policyConsent.toJson(),
      'imageList': imageList.map((e) => e.toJson()).toList(),
      'shippingAddress': shippingAddress.map((e) => e.toJson()).toList(),
      'createdDate': createdDate,
      'updatedDate': updatedDate,
    };
  }

  static List<Store> fromJsonList(List list) {
    return list.map((item) => Store.fromJson(item)).toList();
  }

  Store copyWith({
    String? storeId,
    String? name,
    String? taxId,
    String? tel,
    String? route,
    String? type,
    String? typeName,
    String? address,
    String? district,
    String? subDistrict,
    String? province,
    String? provinceCode,
    String? postCode,
    String? zone,
    String? area,
    String? latitude,
    String? longitude,
    String? lineId,
    String? note,
    String? status,
    Approve? approve,
    PolicyConsent? policyConsent,
    List<ImageItem>? imageList,
    List<ShippingAddress>? shippingAddress,
    String? createdDate,
    String? updatedDate,
  }) {
    return Store(
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      taxId: taxId ?? this.taxId,
      tel: tel ?? this.tel,
      route: route ?? this.route,
      type: type ?? this.type,
      typeName: typeName ?? this.typeName,
      address: address ?? this.address,
      district: district ?? this.district,
      subDistrict: subDistrict ?? this.subDistrict,
      province: province ?? this.province,
      provinceCode: provinceCode ?? this.provinceCode,
      postCode: postCode ?? this.postCode,
      zone: zone ?? this.zone,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lineId: lineId ?? this.lineId,
      note: note ?? this.note,
      status: status ?? this.status,
      approve: approve ?? this.approve,
      policyConsent: policyConsent ?? this.policyConsent,
      imageList: imageList ?? this.imageList,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  Store copyWithDynamicField(String field, String value,
      [List<ImageItem>? imageList]) {
    switch (field) {
      case 'storeId':
        return copyWith(storeId: value);
      case 'name':
        return copyWith(name: value);
      case 'taxId':
        return copyWith(taxId: value);
      case 'tel':
        return copyWith(tel: value);
      case 'route':
        return copyWith(route: value);
      case 'type':
        return copyWith(type: value);
      case 'typeName':
        return copyWith(typeName: value);
      case 'address':
        return copyWith(address: value);
      case 'district':
        return copyWith(district: value);
      case 'subDistrict':
        return copyWith(subDistrict: value);
      case 'province':
        return copyWith(province: value);
      case 'provinceCode':
        return copyWith(provinceCode: value);
      case 'postCode':
        return copyWith(postCode: value);
      case 'zone':
        return copyWith(zone: value);
      case 'area':
        return copyWith(area: value);
      case 'latitude':
        return copyWith(latitude: value);
      case 'longitude':
        return copyWith(longitude: value);
      case 'lineId':
        return copyWith(lineId: value);
      case 'note':
        return copyWith(note: value);
      case 'status':
        return copyWith(status: value);
      case 'imageList':
        return copyWith(imageList: imageList);
      case 'createdDate':
        return copyWith(createdDate: value);
      case 'updatedDate':
        return copyWith(updatedDate: value);
      // Add cases for other fields as needed
      default:
        return this; // If the field does not match, return the current instance unchanged
    }
  }

  //  Set Strig to Show in Search Dropdown
  @override
  String toString() =>
      '$name $route $address $district $subDistrict $province $postCode';

  ///this method will prevent the override of toString
  ///when the object is passed as a parameter to a function Filtter
  bool userFilterByCreationDate(String filter) {
    return this.name.toString().contains(filter) ||
        this.route.toString().contains(filter) ||
        this.address.toString().contains(filter) ||
        this.district.toString().contains(filter) ||
        this.subDistrict.toString().contains(filter) ||
        this.province.toString().contains(filter) ||
        this.province.toString().contains(filter);
  }
}

class Approve {
  final String dateSend;
  final String dateAction;
  final String appPerson;

  Approve({
    required this.dateSend,
    required this.dateAction,
    required this.appPerson,
  });

  factory Approve.fromJson(Map<String, dynamic> json) {
    return Approve(
      dateSend: json['dateSend'] ?? '',
      dateAction: json['dateAction'] ?? '',
      appPerson: json['appPerson'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateSend': dateSend,
      'dateAction': dateAction,
      'appPerson': appPerson,
    };
  }
}

class PolicyConsent {
  final String status;
  final String date;

  PolicyConsent({
    required this.status,
    required this.date,
  });

  factory PolicyConsent.fromJson(Map<String, dynamic> json) {
    return PolicyConsent(
      status: json['status'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'date': date,
    };
  }
}

class ImageItem {
  final String name;
  late final String path;
  final String type;

  ImageItem({
    required this.name,
    required this.path,
    required this.type,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      type: json['type'] ?? '',
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

class ShippingAddress {
  final String address;
  final String district;
  final String subDistrict;
  final String province;
  final String provinceCode;
  final String postCode;
  final String isDefault;
  final String id;

  ShippingAddress({
    required this.address,
    required this.district,
    required this.subDistrict,
    required this.province,
    required this.provinceCode,
    required this.postCode,
    required this.isDefault,
    required this.id,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      address: json['address'] ?? '',
      district: json['district'] ?? '',
      subDistrict: json['subDistrict'] ?? '',
      province: json['province'] ?? '',
      provinceCode: json['provinceCode'] ?? '',
      postCode: json['postCode'] ?? '',
      isDefault: json['default'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'district': district,
      'subDistrict': subDistrict,
      'province': province,
      'provinceCode': provinceCode,
      'postCode': postCode,
      'default': isDefault,
      '_id': id,
    };
  }
}
