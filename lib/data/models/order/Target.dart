class Dashboard {
  // Amounts (เงิน)
  final double sale;
  final double good;
  final double damaged;
  final double refund;
  final double change;
  final double give;
  final double withdraw;
  final double recieve; // คงสะกดตาม API
  final double adjustStock;
  final double target;
  final double targetPercent;

  // Quantities (จำนวนชิ้น/หน่วย)
  final int saleQty;
  final int goodQty;
  final int damagedQty;
  final int refundQty;
  final int changeQty;
  final int giveQty;
  final int withdrawQty;
  final int recieveQty;
  final int adjustStockQty;

  const Dashboard({
    this.sale = 0,
    this.saleQty = 0,
    this.good = 0,
    this.goodQty = 0,
    this.damaged = 0,
    this.damagedQty = 0,
    this.refund = 0,
    this.refundQty = 0,
    this.change = 0,
    this.changeQty = 0,
    this.give = 0,
    this.giveQty = 0,
    this.withdraw = 0,
    this.withdrawQty = 0,
    this.recieve = 0,
    this.recieveQty = 0,
    this.adjustStock = 0,
    this.adjustStockQty = 0,
    this.target = 0,
    this.targetPercent = 0,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int _i(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      if (v is String)
        return int.tryParse(v) ?? (double.tryParse(v)?.round() ?? 0);
      return 0;
    }

    return Dashboard(
      sale: _d(json['sale']),
      saleQty: _i(json['saleQty']),
      good: _d(json['good']),
      goodQty: _i(json['goodQty']),
      damaged: _d(json['damaged']),
      damagedQty: _i(json['damagedQty']),
      refund: _d(json['refund']),
      refundQty: _i(json['refundQty']),
      change: _d(json['change']),
      changeQty: _i(json['changeQty']),
      give: _d(json['give']),
      giveQty: _i(json['giveQty']),
      withdraw: _d(json['withdraw']),
      withdrawQty: _i(json['withdrawQty']),
      recieve: _d(json['recieve']), // สะกดตาม API
      recieveQty: _i(json['recieveQty']),
      adjustStock: _d(json['adjustStock']),
      adjustStockQty: _i(json['adjustStockQty']),
      target: _d(json['target']),
      targetPercent: _d(json['targetPercent']),
    );
  }

  Map<String, dynamic> toJson() => {
        'sale': sale,
        'saleQty': saleQty,
        'good': good,
        'goodQty': goodQty,
        'damaged': damaged,
        'damagedQty': damagedQty,
        'refund': refund,
        'refundQty': refundQty,
        'change': change,
        'changeQty': changeQty,
        'give': give,
        'giveQty': giveQty,
        'withdraw': withdraw,
        'withdrawQty': withdrawQty,
        'recieve': recieve, // คงคีย์เดิม
        'recieveQty': recieveQty,
        'adjustStock': adjustStock,
        'adjustStockQty': adjustStockQty,
        'target': target,
        'targetPercent': targetPercent,
      };

  Dashboard copyWith({
    double? sale,
    int? saleQty,
    double? good,
    int? goodQty,
    double? damaged,
    int? damagedQty,
    double? refund,
    int? refundQty,
    double? change,
    int? changeQty,
    double? give,
    int? giveQty,
    double? withdraw,
    int? withdrawQty,
    double? recieve,
    int? recieveQty,
    double? adjustStock,
    int? adjustStockQty,
    double? target,
    double? targetPercent,
  }) {
    return Dashboard(
      sale: sale ?? this.sale,
      saleQty: saleQty ?? this.saleQty,
      good: good ?? this.good,
      goodQty: goodQty ?? this.goodQty,
      damaged: damaged ?? this.damaged,
      damagedQty: damagedQty ?? this.damagedQty,
      refund: refund ?? this.refund,
      refundQty: refundQty ?? this.refundQty,
      change: change ?? this.change,
      changeQty: changeQty ?? this.changeQty,
      give: give ?? this.give,
      giveQty: giveQty ?? this.giveQty,
      withdraw: withdraw ?? this.withdraw,
      withdrawQty: withdrawQty ?? this.withdrawQty,
      recieve: recieve ?? this.recieve,
      recieveQty: recieveQty ?? this.recieveQty,
      adjustStock: adjustStock ?? this.adjustStock,
      adjustStockQty: adjustStockQty ?? this.adjustStockQty,
      target: target ?? this.target,
      targetPercent: targetPercent ?? this.targetPercent,
    );
  }

  // Helper getters (ถ้าต้องใช้)
  double get totalOutAmount =>
      sale + promotionLike + change + give + damaged + refund;
  double get promotionLike => 0; // ใส่เพิ่มได้ถ้ามี field แยกเรื่องแถม
}
