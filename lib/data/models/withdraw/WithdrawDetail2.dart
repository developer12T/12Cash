class WithdrawDetail {
  final String id;
  final String type;
  final String orderId;
  final String orderType;
  final String orderTypeName;
  final String area;
  final String fromWarehouse;
  final String toWarehouse;
  final String shippingId;
  final String shippingRoute;
  final String shippingName;
  final String sendAddress;
  final String sendDate;
  final String remark;
  final List<Product> listProduct;
  final int total;
  final int totalQty;
  final double totalWeightGross;
  final double totalWeightNet;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  WithdrawDetail({
    required this.id,
    required this.type,
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
    required this.listProduct,
    required this.total,
    required this.totalQty,
    required this.totalWeightGross,
    required this.totalWeightNet,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory WithdrawDetail.fromJson(Map<String, dynamic> json) {
    return WithdrawDetail(
      id: json['_id'],
      type: json['type'],
      orderId: json['orderId'],
      orderType: json['orderType'],
      orderTypeName: json['orderTypeName'],
      area: json['area'],
      fromWarehouse: json['fromWarehouse'],
      toWarehouse: json['toWarehouse'],
      shippingId: json['shippingId'],
      shippingRoute: json['shippingRoute'],
      shippingName: json['shippingName'],
      sendAddress: json['sendAddress'],
      sendDate: json['sendDate'],
      remark: json['remark'],
      listProduct: (json['listProduct'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      total: json['total'],
      totalQty: json['totalQty'],
      totalWeightGross: (json['totalWeightGross'] as num).toDouble(),
      totalWeightNet: (json['totalWeightNet'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'type': type,
        'orderId': orderId,
        'orderType': orderType,
        'orderTypeName': orderTypeName,
        'area': area,
        'fromWarehouse': fromWarehouse,
        'toWarehouse': toWarehouse,
        'shippingId': shippingId,
        'shippingRoute': shippingRoute,
        'shippingName': shippingName,
        'sendAddress': sendAddress,
        'sendDate': sendDate,
        'remark': remark,
        'listProduct': listProduct.map((e) => e.toJson()).toList(),
        'total': total,
        'totalQty': totalQty,
        'totalWeightGross': totalWeightGross,
        'totalWeightNet': totalWeightNet,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        '__v': v,
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
  final int qtyPcs;
  final int price;
  final int total;
  final double weightGross;
  final double weightNet;
  final String productId;

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
    required this.total,
    required this.weightGross,
    required this.weightNet,
    required this.productId,
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
      qtyPcs: json['qtyPcs'],
      price: json['price'],
      total: json['total'],
      weightGross: (json['weightGross'] as num).toDouble(),
      weightNet: (json['weightNet'] as num).toDouble(),
      productId: json['_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group': group,
        'brand': brand,
        'size': size,
        'flavour': flavour,
        'qty': qty,
        'unit': unit,
        'qtyPcs': qtyPcs,
        'price': price,
        'total': total,
        'weightGross': weightGross,
        'weightNet': weightNet,
        '_id': productId,
      };
}
