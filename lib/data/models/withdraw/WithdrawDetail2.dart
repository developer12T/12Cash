class WithdrawDetail {
  final String id;
  final String type;
  final String withdrawType;
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
  final double total;
  final int totalQty;
  final double totalWeightGross;
  final double totalWeightNet;
  final int receivetotal;
  final int receivetotalQty;
  final double receivetotalWeightGross;
  final double receivetotalWeightNet;
  final String status;
  final String statusTH;
  final String newTrip;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  WithdrawDetail({
    required this.id,
    required this.type,
    required this.withdrawType,
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
    required this.receivetotal,
    required this.receivetotalQty,
    required this.receivetotalWeightGross,
    required this.receivetotalWeightNet,
    required this.status,
    required this.statusTH,
    required this.newTrip,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory WithdrawDetail.fromJson(Map<String, dynamic> json) {
    return WithdrawDetail(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      withdrawType: json['withdrawType'] ?? '',
      orderId: json['orderId'] ?? '',
      orderType: json['orderType'] ?? '',
      orderTypeName: json['orderTypeName'] ?? '',
      area: json['area'] ?? '',
      fromWarehouse: json['fromWarehouse'] ?? '',
      toWarehouse: json['toWarehouse'] ?? '',
      shippingId: json['shippingId'] ?? '',
      shippingRoute: json['shippingRoute'] ?? '',
      shippingName: json['shippingName'] ?? '',
      sendAddress: json['sendAddress'] ?? '',
      sendDate: json['sendDate'] ?? '',
      remark: json['remark'] ?? '',
      listProduct: (json['listProduct'] as List? ?? [])
          .map((item) => Product.fromJson(item))
          .toList(),
      total: (json['total'] ?? 0).toDouble(),
      totalQty: json['totalQty'] ?? 0,
      totalWeightGross: (json['totalWeightGross'] ?? 0).toDouble(),
      totalWeightNet: (json['totalWeightNet'] ?? 0).toDouble(),
      receivetotal: json['receivetotal'] ?? 0,
      receivetotalQty: json['receivetotalQty'] ?? 0,
      receivetotalWeightGross:
          (json['receivetotalWeightGross'] ?? 0).toDouble(),
      receivetotalWeightNet: (json['receivetotalWeightNet'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      newTrip: json['newTrip'] ?? '',
      statusTH: json['statusTH'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'type': type,
        'withdrawType': withdrawType,
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
        'receivetotal': receivetotal,
        'receivetotalQty': receivetotalQty,
        'receivetotalWeightGross': receivetotalWeightGross,
        'receivetotalWeightNet': receivetotalWeightNet,
        'status': status,
        'newTrip': newTrip,
        'statusTH': statusTH,
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
  final int receiveQty;
  final String unit;
  final int qtyPcs;
  final double price;
  final double total;
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
    required this.receiveQty,
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      group: json['group'] ?? '',
      brand: json['brand'] ?? '',
      size: json['size'] ?? '',
      flavour: json['flavour'] ?? '',
      qty: json['qty'] ?? 0,
      receiveQty: json['receiveQty'] ?? 0,
      unit: json['unit'] ?? '',
      qtyPcs: json['qtyPcs'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      weightGross: (json['weightGross'] ?? 0).toDouble(),
      weightNet: (json['weightNet'] ?? 0).toDouble(),
      productId: json['_id'] ?? '',
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
        'receiveQty': receiveQty,
        'unit': unit,
        'qtyPcs': qtyPcs,
        'price': price,
        'total': total,
        'weightGross': weightGross,
        'weightNet': weightNet,
        '_id': productId,
      };
}
