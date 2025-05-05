class Stock {
  final String id;
  final String area;
  final String saleCode;
  final String period;
  final String warehouse;
  final List<Product> listProduct;

  Stock({
    required this.id,
    required this.area,
    required this.saleCode,
    required this.period,
    required this.warehouse,
    required this.listProduct,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['_id'],
      area: json['area'],
      saleCode: json['saleCode'],
      period: json['period'],
      warehouse: json['warehouse'],
      listProduct: (json['listProduct'] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'area': area,
      'saleCode': saleCode,
      'period': period,
      'warehouse': warehouse,
      'listProduct': listProduct.map((e) => e.toJson()).toList(),
    };
  }
}

class Product {
  final String productId;
  final int sumQtyPcs;
  final int sumQtyCtn;
  final List<Available> available;

  Product({
    required this.productId,
    required this.sumQtyPcs,
    required this.sumQtyCtn,
    required this.available,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      sumQtyPcs: json['sumQtyPcs'],
      sumQtyCtn: json['sumQtyCtn'],
      available: (json['available'] as List)
          .map((e) => Available.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'sumQtyPcs': sumQtyPcs,
      'sumQtyCtn': sumQtyCtn,
      'available': available.map((e) => e.toJson()).toList(),
    };
  }
}

class Available {
  final String location;
  final String lot;
  final int qtyPcs;
  final int qtyCtn;

  Available({
    required this.location,
    required this.lot,
    required this.qtyPcs,
    required this.qtyCtn,
  });

  factory Available.fromJson(Map<String, dynamic> json) {
    return Available(
      location: json['location'],
      lot: json['lot'],
      qtyPcs: json['qtyPcs'],
      qtyCtn: json['qtyCtn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'lot': lot,
      'qtyPcs': qtyPcs,
      'qtyCtn': qtyCtn,
    };
  }
}
