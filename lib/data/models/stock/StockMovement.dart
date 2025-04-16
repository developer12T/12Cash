class ProductMoveMent {
  final String id;
  final String lot;
  final String unit;
  final int qty;

  ProductMoveMent({
    required this.id,
    required this.lot,
    required this.unit,
    required this.qty,
  });

  factory ProductMoveMent.fromJson(Map<String, dynamic> json) {
    return ProductMoveMent(
      id: json['id'],
      lot: json['lot'],
      unit: json['unit'],
      qty: json['qty'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
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
