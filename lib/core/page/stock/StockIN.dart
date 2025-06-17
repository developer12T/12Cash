import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/card/WithDrawCard.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/refund/RefundCard.dart';
import 'package:_12sale_app/core/page/refund/RefundDetailScreen.dart';
import 'package:_12sale_app/core/page/withdraw/WithdrawDetailScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/stock/StockDetail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StockIN extends StatefulWidget {
  final InOutGroup stockIN;
  const StockIN({
    super.key,
    required this.stockIN,
  });

  @override
  State<StockIN> createState() => _StockINState();
}

class _StockINState extends State<StockIN> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(title: " Stock-IN", icon: Icons.warehouse),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Withdraw",
              style: Styles.black20(context),
              textAlign: TextAlign.start,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.stockIN.withdraw?.length,
                itemBuilder: (context, index) {
                  return WithDrawCard(
                    item: widget.stockIN.withdraw![index],
                    onDetailsPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WithdrawDetailScreen(
                              orderId: widget.stockIN.withdraw?[index].orderId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              "Refund",
              style: Styles.black20(context),
              textAlign: TextAlign.start,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.stockIN.refund?.length,
                itemBuilder: (context, index) {
                  return RefundCard(
                    item: widget.stockIN.refund![index],
                    onDetailsPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RefundDetailScreen(
                              orderId: widget.stockIN.refund?[index].orderId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            BoxShadowCustom(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Stock-IN",
                          style: Styles.headerBlack24(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ยอดยกมา',
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          widget.stockIN.withdrawStock
                              // .where((u) => u.qty != 0)
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
                          'เบิกระหว่างทริป',
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          widget.stockIN.withdrawStock
                              // .where((u) => u.qty != 0)
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
                          'รับคืนดี',
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          widget.stockIN.withdrawStock
                              // .where((u) => u.qty != 0)
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
                          'รวมรับเข้า',
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          widget.stockIN.withdrawStock
                              // .where((u) => u.qty != 0)
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
                          'มูลค่ารับเข้า',
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(widget.stockIN.summary)}",
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
