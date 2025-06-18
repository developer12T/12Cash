import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/card/order/InvoiceCard.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/refund/RefundCard.dart';
import 'package:_12sale_app/core/page/order/OrderDetail.dart';
import 'package:_12sale_app/core/page/refund/RefundDetailScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/stock/StockDetail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StockOUT extends StatefulWidget {
  final InOutGroup stockOut;

  const StockOUT({
    super.key,
    required this.stockOut,
  });

  @override
  State<StockOUT> createState() => _StockOUTState();
}

class _StockOUTState extends State<StockOUT> {
  String formatUnitList(List<UnitQty>? list) {
    final filtered = list?.where((u) => u.qty != 0).toList() ?? [];
    return filtered.isEmpty
        ? 'ไม่มี' // fallback if null or no quantity > 0
        : filtered.map((u) => '${u.qty} ${u.unitName}').join(' ');
  }

  String formatCurrency(double? amount) {
    return NumberFormat.currency(locale: 'th_TH', symbol: '฿')
        .format(amount ?? 0);
  }

  Widget buildLabelRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Styles.black18(context)),
        Text(value, style: Styles.black18(context)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderList = widget.stockOut.order ?? [];
    final refundList = widget.stockOut.refund ?? [];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(title: "Stock-OUT", icon: Icons.warehouse),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order", style: Styles.black20(context)),
            Expanded(
              child: ListView.builder(
                itemCount: orderList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InvoiceCard(
                      item: orderList[index],
                      onDetailsPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(
                              orderId: orderList[index].orderId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Text("Change", style: Styles.black20(context)),
            Expanded(
              child: ListView.builder(
                itemCount: refundList.length,
                itemBuilder: (context, index) {
                  return RefundCard(
                    item: refundList[index],
                    onDetailsPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RefundDetailScreen(
                            orderId: refundList[index].orderId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            BoxShadowCustom(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Stock-OUT", style: Styles.headerBlack24(context)),
                    const SizedBox(height: 16),
                    buildLabelRow(
                        'ขาย', formatUnitList(widget.stockOut.orderStock)),
                    buildLabelRow(
                        'แถม', formatUnitList(widget.stockOut.promotionStock)),
                    buildLabelRow(
                        'เปลี่ยน', formatUnitList(widget.stockOut.change)),
                    buildLabelRow(
                        'ค่าตั้ง', formatUnitList(widget.stockOut.refundStock)),
                    buildLabelRow(
                        'รวม', formatUnitList(widget.stockOut.summaryStock)),
                    buildLabelRow('รวมมูลค่าขาย',
                        "${formatCurrency(widget.stockOut.summary)} บาท"),
                    buildLabelRow('รวมมูลค่าแถม',
                        "${formatCurrency(widget.stockOut.promotionSum)} บาท"),
                    buildLabelRow('รวมมูลเปลี่ยน',
                        "${formatCurrency(widget.stockOut.changeSum)} บาท"),
                    // buildLabelRow('รวมมูลค่าตั้ง',
                    //     "${formatCurrency(widget.stockOut.refundSum)} บาท"),
                    buildLabelRow('รวมมูลค่าสินค้าออก',
                        "${formatCurrency(widget.stockOut.summary)} บาท"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
