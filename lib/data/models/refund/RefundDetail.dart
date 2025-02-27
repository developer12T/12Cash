class RefundDetail {
  final String type;
  final String orderId;
  final String reference;
  final Sale sale;
  final Store store;
  final String note;
  final double latitude;
  final double longitude;
  final String status;
  final List<Product> listProductRefund;
  final List<Product> listProductChange;
  final double totalChange;
  final double totalRefund;
  final double vat;
  final double totalExVat;
  final double total;
  final Shipping shipping;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ListImage> listImage;

  RefundDetail({
    required this.type,
    required this.orderId,
    required this.reference,
    required this.sale,
    required this.store,
    required this.note,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.listProductRefund,
    required this.listProductChange,
    required this.totalChange,
    required this.totalRefund,
    required this.vat,
    required this.totalExVat,
    required this.total,
    required this.shipping,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.listImage,
  });

  factory RefundDetail.fromJson(Map<String, dynamic> json) {
    return RefundDetail(
      type: json['type'],
      orderId: json['orderId'],
      reference: json['reference'],
      sale: Sale.fromJson(json['sale']),
      store: Store.fromJson(json['store']),
      note: json['note'],
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      status: json['status'],
      listProductRefund: (json['listProductRefund'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      listProductChange: (json['listProductChange'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      totalChange: double.tryParse(json['totalChange'].toString()) ?? 0.0,
      totalRefund: double.tryParse(json['totalRefund'].toString()) ?? 0.0,
      vat: double.tryParse(json['vat'].toString()) ?? 0.0,
      totalExVat: double.tryParse(json['totalExVat'].toString()) ?? 0.0,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      shipping: Shipping.fromJson(json['shipping']),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      listImage: (json['listImage'] as List)
          .map((item) => ListImage.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'orderId': orderId,
      'reference': reference,
      'sale': sale.toJson(),
      'store': store.toJson(),
      'note': note,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'status': status,
      'listProductRefund':
          listProductRefund.map((product) => product.toJson()).toList(),
      'listProductChange':
          listProductChange.map((product) => product.toJson()).toList(),
      'totalChange': totalChange.toStringAsFixed(2),
      'totalRefund': totalRefund.toStringAsFixed(2),
      'vat': vat.toStringAsFixed(2),
      'totalExVat': totalExVat.toStringAsFixed(2),
      'total': total.toStringAsFixed(2),
      'shipping': shipping.toJson(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'listImage': listImage,
    };
  }
}

// Sale model
class Sale {
  final String saleCode;
  final String salePayer;
  final String name;
  final String tel;
  final String warehouse;
  final String id;

  Sale({
    required this.saleCode,
    required this.salePayer,
    required this.name,
    required this.tel,
    required this.warehouse,
    required this.id,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      saleCode: json['saleCode'],
      salePayer: json['salePayer'],
      name: json['name'],
      tel: json['tel'],
      warehouse: json['warehouse'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saleCode': saleCode,
      'salePayer': salePayer,
      'name': name,
      'tel': tel,
      'warehouse': warehouse,
      '_id': id,
    };
  }
}

// Store model
class Store {
  final String storeId;
  final String name;
  final String address;
  final String taxId;
  final String tel;
  final String area;
  final String zone;
  final String id;

  Store({
    required this.storeId,
    required this.name,
    required this.address,
    required this.taxId,
    required this.tel,
    required this.area,
    required this.zone,
    required this.id,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['storeId'],
      name: json['name'],
      address: json['address'],
      taxId: json['taxId'],
      tel: json['tel'],
      area: json['area'],
      zone: json['zone'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'name': name,
      'address': address,
      'taxId': taxId,
      'tel': tel,
      'area': area,
      'zone': zone,
      '_id': id,
    };
  }
}

// Product model
class Product {
  final String id;
  final String name;
  final String group;
  final String brand;
  final String size;
  final String flavour;
  final double qty;
  final String unit;
  final String unitName;
  final double price;
  final double netTotal;
  final String? condition;

  Product({
    required this.id,
    required this.name,
    required this.group,
    required this.brand,
    required this.size,
    required this.flavour,
    required this.qty,
    required this.unit,
    required this.unitName,
    required this.price,
    required this.netTotal,
    this.condition,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      group: json['group'],
      brand: json['brand'],
      size: json['size'],
      flavour: json['flavour'],
      qty: double.tryParse(json['qty'].toString()) ?? 0.0,
      unit: json['unit'],
      unitName: json['unitName'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      netTotal: double.tryParse(json['netTotal'].toString()) ?? 0.0,
      condition: json['condition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'group': group,
      'brand': brand,
      'size': size,
      'flavour': flavour,
      'qty': qty.toStringAsFixed(2),
      'unit': unit,
      'unitName': unitName,
      'price': price.toStringAsFixed(2),
      'netTotal': netTotal.toStringAsFixed(2),
      'condition': condition,
    };
  }
}

// Shipping model
class Shipping {
  final String shippingId;
  final String address;

  Shipping({required this.shippingId, required this.address});

  factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      shippingId: json['shippingId'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shippingId': shippingId,
      'address': address,
    };
  }
}

class ListImage {
  final String name;
  final String path;
  final String type;

  ListImage({
    required this.name,
    required this.path,
    required this.type,
  });

  // ✅ Convert JSON to Dart Object
  factory ListImage.fromJson(Map<String, dynamic> json) {
    return ListImage(
      name: json['name'] ?? '', //  field name
      path: json['path'] ?? '', //  field name
      type: json['type'] ?? '', //  field name
    );
  }

  // ✅ Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'type': type,
    };
  }
}
