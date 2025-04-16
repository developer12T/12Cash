class Cart {
  // final String id;
  final String type;
  // final String area;
  // final String storeId;
  final CartListStore store;
  final double total;
  final List<CartList> listCartList;
  final DateTime created;
  final DateTime updated;

  Cart({
    // required this.id,
    required this.type,
    // required this.area,
    required this.store,
    required this.total,
    required this.listCartList,
    required this.created,
    required this.updated,
  });

  // ✅ Convert JSON to Dart Object
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      // id: json['_id'],
      type: json['type'],
      // area: json['area'],
      // storeId: json['storeId'],
      store: json['store'] is Map<String, dynamic>
          ? CartListStore.fromJson(json['store'] ?? {})
          : CartListStore.fromJson(json['store'] ?? {}),
      total: json['total'].toDouble(),
      listCartList: (json['listProduct'] as List)
          .map((item) => CartList.fromJson(item))
          .toList(),
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  // ✅ Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      // '_id': id,
      'type': type,
      // 'area': area,
      'store': store,
      'total': total,
      'listCartList': listCartList.map((product) => product.toJson()).toList(),
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  // @override
  // String toString() {
  //   return 'Cart(id: $id, type: $type, area: $area, storeId: $storeId, total: $total, created: $created, updated: $updated, listCartList: $listCartList)';
  // }
}

class CartList {
  final String id;
  String lot;
  final String name;
  final String group;
  final String brand;
  final String size;
  final String flavour;
  double qty;
  final String unit;
  final String unitName;
  final double price;
  final double total;
  final int qtyPcs;

  CartList({
    required this.id,
    required this.lot,
    required this.name,
    required this.group,
    required this.brand,
    required this.size,
    required this.flavour,
    required this.qty,
    required this.unit,
    required this.unitName,
    required this.price,
    required this.total,
    required this.qtyPcs,
  });

  // ✅ Convert JSON to Dart Object
  factory CartList.fromJson(Map<String, dynamic> json) {
    return CartList(
      id: json['id'],
      lot: json['lot'] ?? '',
      name: json['name'],
      group: json['group'],
      brand: json['brand'],
      size: json['size'],
      flavour: json['flavour'],
      qty: json['qty'].toDouble(),
      unit: json['unit'],
      unitName: json['unitName'] ?? '',
      price: json['price'].toDouble(),
      total: json['total'].toDouble(),
      qtyPcs: json['qtyPcs'] as int,
    );
  }

  // ✅ Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lot': lot,
      'name': name,
      'group': group,
      'brand': brand,
      'size': size,
      'flavour': flavour,
      'qty': qty,
      'unit': unit,
      'unitName': unitName,
      'price': price,
      'total': total,
      'qtyPcs': qtyPcs,
    };
  }
}

class CartListStore {
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

  CartListStore({
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

  // ✅ Convert JSON to Dart Object
  factory CartListStore.fromJson(Map<String, dynamic> json) {
    return CartListStore(
      storeId: json['storeId'],
      name: json['name'],
      taxId: json['taxId'],
      tel: json['tel'],
      route: json['route'],
      storeType: json['storeType'],
      typeName: json['typeName'],
      address: json['address'],
      subDistrict: json['subDistrict'],
      district: json['district'],
      province: json['province'],
      zone: json['zone'],
      area: json['area'],
    );
  }

  // ✅ Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'name': name,
      'taxId': taxId,
      'tel': tel,
      'route': route,
      'storeType': storeType,
      'typeName': typeName,
      'address': address,
      'subDistrict': subDistrict,
      'district': district,
      'province': province,
      'zone': zone,
      'area': area,
    };
  }
}
