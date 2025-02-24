import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String group;
  final String brand;
  final String size;
  final String flavour;
  final String type;
  final String weightGross;
  final String weightNet;
  final String statusSale;
  final String statusWithdraw;
  final String statusRefund;
  final String image;
  final List<Unit> listUnit;
  final DateTime createdDate;
  final DateTime updatedDate;

  Product({
    required this.id,
    required this.name,
    required this.group,
    required this.brand,
    required this.size,
    required this.flavour,
    required this.type,
    required this.weightGross,
    required this.weightNet,
    required this.statusSale,
    required this.statusWithdraw,
    required this.statusRefund,
    required this.image,
    required this.listUnit,
    required this.createdDate,
    required this.updatedDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '', // ✅ Default to empty string if null
      name: json['name'] ?? '',
      group: json['group'] ?? '',
      brand: json['brand'] ?? '',
      size: json['size'] ?? '',
      flavour: json['flavour'] ?? '',
      type: json['type'] ?? '',
      weightGross: json['weightGross'] ?? '',
      weightNet: json['weightNet'] ?? '',
      statusSale: json['statusSale'] ?? '',
      statusWithdraw: json['statusWithdraw'] ?? '',
      statusRefund: json['statusRefund'] ?? '',
      image: json['image'] ?? '',
      listUnit: (json['listUnit'] as List<dynamic>?)
              ?.map((unit) => Unit.fromJson(unit))
              .toList() ??
          [], // ✅ Default to empty list if null
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : DateTime.now(), // ✅ Default to current date if null
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'])
          : DateTime.now(),
    );
  }

  // ✅ Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'group': group,
      'brand': brand,
      'size': size,
      'flavour': flavour,
      'type': type,
      'weightGross': weightGross,
      'weightNet': weightNet,
      'statusSale': statusSale,
      'statusWithdraw': statusWithdraw,
      'statusRefund': statusRefund,
      'image': image,
      'listUnit': listUnit.map((unit) => unit.toJson()).toList(),
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
    };
  }

  static List<Product> fromJsonList(List list) {
    return list.map((item) => Product.fromJson(item)).toList();
  }

  @override
  String toString() => '$name $id';

  bool userFilterByCreationDate(String filter) {
    return this.name.toString().contains(filter) ||
        this.id.toString().contains(filter) ||
        this.group.toString().contains(filter) ||
        this.brand.toString().contains(filter) ||
        this.size.toString().contains(filter) ||
        this.flavour.toString().contains(filter);
  }
}

class Unit {
  final String name;
  final String unit;
  final String factor;
  final String price;

  Unit({
    required this.name,
    required this.unit,
    required this.factor,
    required this.price,
  });

  // ✅ Convert JSON to Dart Object
  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      unit: json['unit'] ?? '',
      name: json['name'] ?? '',
      factor: json['factor'] ?? '',
      price: json['price'] ?? '',
    );
  }

  // ✅ Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'unit': unit,
      'name': name,
      'factor': factor,
      'price': price,
    };
  }
}
