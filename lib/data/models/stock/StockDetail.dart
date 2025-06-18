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
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      stock: StockGroup.fromJson(json['STOCK'] ?? {}),
      inData: InOutGroup.fromJson(json['IN'] ?? {}),
      outData: InOutGroup.fromJson(json['OUT'] ?? {}),
      balance: (json['BALANCE'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e))
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
              ?.map((e) => UnitQty.fromJson(e))
              .toList() ??
          [],
      date: json['date'] ?? '',
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
  final List<UnitQty>? promotionStock;
  final List<UnitQty>? change;

  // เพิ่ม field ใหม่
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
            .map((e) => UnitQty.fromJson(e))
            .toList()
        : (rawStock is List)
            ? rawStock.map((e) => UnitQty.fromJson(e)).toList()
            : <UnitQty>[];

    return InOutGroup(
      stock: stockList,
      withdrawStock: (json['withdrawStock'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e))
              .toList() ??
          [],
      withdraw: (json['withdraw'] as List<dynamic>?)
          ?.map((e) => Withdraw.fromJson(e))
          .toList(),
      refundStock: (json['refundStock'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e))
              .toList() ??
          [],
      refund: (json['refund'] as List<dynamic>?)
          ?.map((e) => RefundOrder.fromJson(e))
          .toList(),
      summaryStock: (json['summaryStock'] as List<dynamic>?)
              ?.map((e) => UnitQty.fromJson(e))
              .toList() ??
          [],
      summary: (json['summary'] as num?)?.toDouble() ?? 0.0,
      orderStock: (json['orderStock'] as List<dynamic>?)
          ?.map((e) => UnitQty.fromJson(e))
          .toList(),
      order: (json['order'] as List<dynamic>?)
          ?.map((e) => Orders.fromJson(e))
          .toList(),
      promotionStock: (json['promotionStock'] as List<dynamic>?)
          ?.map((e) => UnitQty.fromJson(e))
          .toList(),
      change: (json['change'] as List<dynamic>?)
          ?.map((e) => UnitQty.fromJson(e))
          .toList(),
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
      unit: json['unit'] ?? '',
      qty: json['qty'] ?? 0,
      unitName: json['unitName'], // optional
    );
  }
}
