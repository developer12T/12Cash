import 'dart:math';

/// ===== helpers: แปลงค่าแบบ null-safe =====
double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  if (v is Map) {
    // รองรับเคสที่ price เป็น map: เลือกคีย์ยอดนิยม ถ้าไม่เจอให้พยายามหยิบตัวแรกที่เป็นตัวเลข
    for (final k in const [
      'sale',
      'refund',
      'refundDmg',
      'change',
      'value',
      'amount'
    ]) {
      final d = _asDouble(v[k]);
      if (d != 0.0) return d;
    }
    for (final val in v.values) {
      final d = _asDouble(val);
      if (d != 0.0) return d;
    }
    return 0.0;
  }
  return 0.0;
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

DateTime _asDate(dynamic v, {DateTime? orElse}) {
  if (v == null) return orElse ?? DateTime.now();
  if (v is DateTime) return v;
  if (v is String) {
    final d = DateTime.tryParse(v);
    if (d != null) return d;
  }
  return orElse ?? DateTime.now();
}

/// ================== MODELS ==================

class Product {
  final String id;
  final String name;
  final String group;
  final String brand;
  final String size;
  final String flavour;
  final String type;
  final double weightGross;
  final double weightNet;
  final String statusSale;
  final String statusWithdraw;
  final String statusRefund;
  final String image;
  final List<Unit> listUnit;
  final DateTime createdDate;
  final DateTime updatedDate;
  final int? qtyCtn;
  final int? qtyPcs;

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
    this.qtyCtn,
    this.qtyPcs,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // 1) พยายามอ่าน listUnit ถ้ามี
    List<Unit> units = [];
    final rawUnits = json['listUnit'];
    if (rawUnits is List) {
      units = rawUnits
          .whereType<Map>()
          .map((m) => Unit.fromJson(m.cast<String, dynamic>()))
          .toList();
    }

    // 2) ถ้าไม่มี listUnit แต่มี unit/qty ระดับบน → สร้าง Unit หนึ่งตัวจากข้อมูลบนสุด
    if (units.isEmpty &&
        (json.containsKey('unit') || json.containsKey('qty'))) {
      units = [Unit.fromTopLevel(json)];
    }

    return Product(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      group: (json['group'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      size: (json['size'] ?? '').toString(),
      flavour: (json['flavour'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      weightGross: _asDouble(json['weightGross']),
      weightNet: _asDouble(json['weightNet']),
      statusSale: (json['statusSale'] ?? '').toString(),
      statusWithdraw: (json['statusWithdraw'] ?? '').toString(),
      statusRefund: (json['statusRefund'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      listUnit: units,
      // รองรับทั้ง createdDate/updatedDate และ createdAt/updatedAt
      createdDate: _asDate(json['createdDate'] ?? json['createdAt']),
      updatedDate: _asDate(json['updatedDate'] ?? json['updatedAt']),
      qtyCtn: json['qtyCtn'] == null ? null : _asInt(json['qtyCtn']),
      qtyPcs: json['qtyPcs'] == null ? null : _asInt(json['qtyPcs']),
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
      'type': type,
      'weightGross': weightGross,
      'weightNet': weightNet,
      'statusSale': statusSale,
      'statusWithdraw': statusWithdraw,
      'statusRefund': statusRefund,
      'image': image,
      'listUnit': listUnit.map((u) => u.toJson()).toList(),
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'qtyCtn': qtyCtn,
      'qtyPcs': qtyPcs,
    };
  }

  static List<Product> fromJsonList(List list) {
    return list
        .whereType<Map>()
        .map((item) => Product.fromJson(item.cast<String, dynamic>()))
        .toList();
  }

  @override
  String toString() => '$name $id';

  bool userFilterByCreationDate(String filter) {
    return name.contains(filter) ||
        id.contains(filter) ||
        group.contains(filter) ||
        brand.contains(filter) ||
        size.contains(filter) ||
        flavour.contains(filter);
  }

  /// ตัวช่วย: ราคาขายของหน่วยแรก (ถ้ามี)
  double get salePrice => listUnit.isNotEmpty ? listUnit.first.price : 0.0;
}

class Unit {
  final String name;
  final String unit;
  final int factor;
  final double price;
  final int? qty;
  final int? qtyPro;

  Unit({
    required this.name,
    required this.unit,
    required this.factor,
    required this.price,
    this.qty,
    this.qtyPro,
  });

  /// JSON หน่วยมาตรฐาน (รองรับ price เป็น number หรือ map)
  factory Unit.fromJson(Map<String, dynamic> json) {
    final priceField = json['price'];
    return Unit(
      unit: (json['unit'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      factor: _asInt(json['factor']),
      price: _asDouble(priceField), // รองรับทั้ง num/String/Map
      qty: json['qty'] == null ? null : _asInt(json['qty']),
      qtyPro: json['qtyPro'] == null ? null : _asInt(json['qtyPro']),
    );
  }

  /// Fallback: กรณีข้อมูลอยู่ระดับบนสุดของ product (ไม่มี listUnit)
  factory Unit.fromTopLevel(Map<String, dynamic> json) {
    return Unit(
      unit: (json['unit'] ?? '').toString(),
      name: '', // ไม่มี name ในโครงนี้
      factor: 1, // ไม่ทราบ factor → สมมุติ 1
      price: 0.0, // ไม่ทราบราคา → 0
      qty: json['qty'] == null ? null : _asInt(json['qty']),
      qtyPro: json['qtyPro'] == null ? null : _asInt(json['qtyPro']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit': unit,
      'name': name,
      'factor': factor,
      'price': price,
      'qty': qty,
      'qtyPro': qtyPro,
    };
  }
}
