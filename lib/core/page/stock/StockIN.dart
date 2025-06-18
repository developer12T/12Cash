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
    final withdrawList = widget.stockIN.withdraw ?? [];
    final refundList = widget.stockIN.refund ?? [];
    final withdrawStock = widget.stockIN.withdrawStock ?? [];
    final refundStock = widget.stockIN.refundStock ?? [];
    final summaryStock = widget.stockIN.summaryStock ?? [];
    final stock = widget.stockIN.stock ?? [];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(title: " Stock-IN", icon: Icons.warehouse),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Withdraw", style: Styles.black20(context)),
            Expanded(
              child: ListView.builder(
                itemCount: withdrawList.length,
                itemBuilder: (context, index) {
                  final withdraw = withdrawList[index];
                  return WithDrawCard(
                    item: withdraw,
                    onDetailsPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              WithdrawDetailScreen(orderId: withdraw.orderId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text("Refund", style: Styles.black20(context)),
            Expanded(
              child: ListView.builder(
                itemCount: refundList.length,
                itemBuilder: (context, index) {
                  final refund = refundList[index];
                  return RefundCard(
                    item: refund,
                    onDetailsPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              RefundDetailScreen(orderId: refund.orderId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            BoxShadowCustom(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Stock-IN", style: Styles.headerBlack24(context)),
                      ],
                    ),
                    _buildInfoRow("ยอดยกมา", stock),
                    _buildInfoRow("เบิกระหว่างทริป", withdrawStock),
                    _buildInfoRow("รับคืนดี", refundStock),
                    _buildInfoRow("รวมรับเข้า", summaryStock),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("มูลค่ารับเข้า", style: Styles.black18(context)),
                        Text(
                          NumberFormat.currency(locale: 'th_TH', symbol: '฿')
                              .format(widget.stockIN.summaryStockInOut ?? 0),
                          style: Styles.black18(context),
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

  Widget _buildInfoRow(String label, List<UnitQty> unitList) {
    final text = unitList.map((u) => '${u.qty} ${u.unitName}').join(' ');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Styles.black18(context)),
        Text(text, style: Styles.black18(context)),
      ],
    );
  }
}
