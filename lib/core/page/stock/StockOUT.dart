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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(title: " Stock-OUT", icon: Icons.warehouse),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order",
              style: Styles.black20(context),
              textAlign: TextAlign.start,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.stockOut.order?.length,
                itemBuilder: (context, index) {
                  return InvoiceCard(
                    item: widget.stockOut.order![index],
                    onDetailsPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(
                              orderId: widget.stockOut.order?[index].orderId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Text(
              "Change",
              style: Styles.black20(context),
              textAlign: TextAlign.start,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.stockOut.refund?.length,
                itemBuilder: (context, index) {
                  return RefundCard(
                    item: widget.stockOut.refund![index],
                    onDetailsPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RefundDetailScreen(
                              orderId: widget.stockOut.refund?[index].orderId),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Stock-OUT",
                          style: Styles.headerBlack24(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ขาย',
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                widget
                                    .stockOut
                                    .orderStock
                                    // .where((u) => u.qty != 0)
                                    !
                                    .map((u) => '${u.qty} ${u.unit}')
                                    .join(' '),
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'รวมมูลค่าขาย',
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(widget.stockOut.summary)} บาท",
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'แถม',
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                widget
                                    .stockOut
                                    .orderStock
                                    // .where((u) => u.qty != 0)
                                    !
                                    .map((u) => '${u.qty} ${u.unit}')
                                    .join(' '),
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'รวมมูลค่าแถม',
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(widget.stockOut.summary)} บาท",
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'เปลี่ยน',
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                widget
                                    .stockOut
                                    .orderStock
                                    // .where((u) => u.qty != 0)
                                    !
                                    .map((u) => '${u.qty} ${u.unit}')
                                    .join(' '),
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'รวมมูลเปลี่ยน',
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(widget.stockOut.summary)} บาท",
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ค่าตั้ง',
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                widget
                                    .stockOut
                                    .orderStock
                                    // .where((u) => u.qty != 0)
                                    !
                                    .map((u) => '${u.qty} ${u.unit}')
                                    .join(' '),
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'รวมมูลค่าตั้ง',
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(widget.stockOut.summary)} บาท",
                                style: Styles.black18(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'รวม',
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          widget
                              .stockOut
                              .orderStock
                              // .where((u) => u.qty != 0)
                              !
                              .map((u) => '${u.qty} ${u.unit}')
                              .join(' '),
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'รวมมูลค่าสินค้าออก',
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(widget.stockOut.summary)}",
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
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
