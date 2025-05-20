class ProductMoveMent {
  final String productId;
  final String lot;
  final String unit;
  final int qty;

  ProductMoveMent({
    required this.productId,
    required this.lot,
    required this.unit,
    required this.qty,
  });

  factory ProductMoveMent.fromJson(Map<String, dynamic> json) {
    return ProductMoveMent(
      productId: json['productId'],
      lot: json['lot'],
      unit: json['unit'],
      qty: json['qty'],
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'lot': lot,
        'unit': unit,
        'qty': qty,
      };
}

// class Lot {
//   final String lot;
//   final String unit;
//   final int qty;

//   Lot({required this.lot, required this.unit, required this.qty});

//   factory Lot.fromJson(Map<String, dynamic> json) {
//     return Lot(
//       lot: json['lot'],
//       unit: json['unit'],
//       qty: json['qty'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'lot': lot,
//         'unit': unit,
//         'qty': qty,
//       };
// }
