import 'package:_12sale_app/data/models/order/Orders.dart';
import 'package:_12sale_app/data/models/refund/RefundOrder.dart';
import 'package:_12sale_app/data/models/withdraw/Withdraw.dart';

class StockDetailData {
  final String productId;
  final String productName;
  final StockGroup stock;
  final InOutGroup inData;
  final InOutGroup outData;
  final List<UnitQty> balance;
  final double summary;

  StockDetailData({
    required this.productId,
    required this.productName,
    required this.stock,
    required this.inData,
    required this.outData,
    required this.balance,
    required this.summary,
  });

  factory StockDetailData.fromJson(Map<String, dynamic> json) {
    return StockDetailData(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      stock: StockGroup.fromJson(json['STOCK'] is Map ? json['STOCK'] : {}),
      inData: InOutGroup.fromJson(json['IN'] is Map ? json['IN'] : {}),
      outData: InOutGroup.fromJson(json['OUT'] is Map ? json['OUT'] : {}),
      balance: (json['BALANCE'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: (json['summary'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StockGroup {
  final List<UnitQty> stock;
  final String date;

  StockGroup({
    required this.stock,
    required this.date,
  });

  factory StockGroup.fromJson(Map<String, dynamic> json) {
    return StockGroup(
      stock: (json['stock'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      date: json['date']?.toString() ?? '',
    );
  }
}

class InOutGroup {
  final List<UnitQty> stock;
  final List<UnitQty> withdrawStock;
  final List<Withdraw>? withdraw;
  final List<UnitQty> refundStock;
  final List<RefundOrder>? refund;
  final List<UnitQty> summaryStock;
  final double summary;
  final List<UnitQty>? orderStock;
  final List<Orders>? order;
  final List<Orders>? changeDetail;
  final List<UnitQty>? promotionStock;
  final List<UnitQty>? change;

  final double? summaryStockIn;
  final double? orderSum;
  final double? promotionSum;
  final double? changeSum;
  final double? summaryStockInOut;

  InOutGroup({
    required this.stock,
    required this.withdrawStock,
    this.withdraw,
    required this.refundStock,
    this.refund,
    required this.summaryStock,
    required this.summary,
    this.orderStock,
    this.order,
    this.changeDetail,
    this.promotionStock,
    this.change,
    this.summaryStockIn,
    this.orderSum,
    this.changeSum,
    this.promotionSum,
    this.summaryStockInOut,
  });

  factory InOutGroup.fromJson(Map<String, dynamic> json) {
    final rawStock = json['stock'];
    final stockList = (rawStock is Map && rawStock['stock'] is List)
        ? (rawStock['stock'] as List<dynamic>)
            .map((e) => UnitQty.fromJson(e as Map<String, dynamic>))
            .toList()
        : (rawStock is List)
            ? rawStock
                .map((e) => UnitQty.fromJson(e as Map<String, dynamic>))
                .toList()
            : <UnitQty>[];

    return InOutGroup(
      stock: stockList,
      withdrawStock: (json['withdrawStock'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      withdraw: (json['withdraw'] as List<dynamic>?)
              ?.map((e) => Withdraw.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      refundStock: (json['refundStock'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      refund: (json['refund'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => RefundOrder.fromJson(e))
              .toList() ??
          [],
      summaryStock: (json['summaryStock'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: (json['summary'] as num?)?.toDouble() ?? 0.0,
      orderStock: (json['orderStock'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      order: (json['order'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => Orders.fromJson(e))
              .toList() ??
          [],
      changeDetail: (json['changeDetail'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => Orders.fromJson(e))
              .toList() ??
          [],
      promotionStock: (json['promotionStock'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      change: (json['change'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summaryStockIn: (json['summaryStockIn'] as num?)?.toDouble(),
      orderSum: (json['orderSum'] as num?)?.toDouble(),
      changeSum: (json['changeSum'] as num?)?.toDouble(),
      promotionSum: (json['promotionSum'] as num?)?.toDouble(),
      summaryStockInOut: (json['summaryStockInOut'] as num?)?.toDouble(),
    );
  }
}

class UnitQty {
  final String unit;
  final String? unitName;
  final int qty;

  UnitQty({
    required this.unit,
    required this.qty,
    this.unitName,
  });

  factory UnitQty.fromJson(Map<String, dynamic> json) {
    return UnitQty(
      unit: json['unit']?.toString() ?? '',
      qty: json['qty'] is int
          ? json['qty']
          : int.tryParse(json['qty']?.toString() ?? '') ?? 0,
      unitName: json['unitName']?.toString(),
    );
  }
}
