import 'package:_12sale_app/core/page/sendmoney/SendMoneyScreen.dart';
import 'package:_12sale_app/core/page/stock/StockDetail.dart';
import 'package:dartx/dartx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:_12sale_app/core/styles/style.dart';

class SendmoneyTableShow extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final List<List<String>>? itemCodes;
  final List<String>? footer; // Add this

  const SendmoneyTableShow({
    super.key,
    required this.columns,
    required this.rows,
    this.itemCodes,
    this.footer, // Add this
  });

  @override
  Widget build(BuildContext context) {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return Scrollbar(
      controller: horizontalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: horizontalController,
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sticky Header Row
            Container(
              child: Row(
                children: columns.asMap().entries.map((entry) {
                  final index = entry.key;
                  final column = entry.value;
                  return Container(
                    decoration: BoxDecoration(
                      color: Styles.primaryColor,
                      border:
                          Border.all(color: Colors.black), // Border added here
                    ),
                    width: index == 1
                        ? MediaQuery.of(context).size.width * 0.25
                        : MediaQuery.of(context).size.width * 0.25,
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: Text(
                      column,
                      style: Styles.white18(context)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            // Scrollable Body Rows
            Expanded(
              child: Scrollbar(
                controller: verticalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: verticalController,
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: rows.map((row) {
                      final String date = row[0].toString();
                      DateTime dt = DateFormat('dd/MM/yyyy').parse(date);
                      String output =
                          "${dt.year}${DateFormat('MM').format(dt)}${DateFormat('dd').format(dt)}";
                      return GestureDetector(
                        onTap: () {
                          // Replace this with navigation logic
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SendMoneyScreen(
                                      date: output,
                                      dateTime: dt,
                                    ) // row[0] = productId
                                ),
                          );
                        },
                        child: Row(
                          children: row.asMap().entries.map((entry) {
                            final index = entry.key;
                            final cell = entry.value;
                            double numValue = double.tryParse(cell) ?? 0.0;
                            return Container(
                              decoration: BoxDecoration(
                                color: index == 1
                                    ? cell != 'ยังไม่ส่งเงิน'
                                        ? Colors.green
                                        : Colors.amber
                                    : index == 4
                                        ? cell.toDouble() > 0
                                            ? Colors.green
                                            : cell.toDouble() == 0
                                                ? Colors.grey
                                                : Colors.red
                                        : Colors.white,
                                border: Border.all(
                                    color: Colors.black), // Border added here
                              ),
                              width: index == 1
                                  ? MediaQuery.of(context).size.width * 0.25
                                  : MediaQuery.of(context).size.width * 0.25,
                              height: 50,
                              padding: const EdgeInsets.all(8),
                              alignment: index == 0
                                  ? Alignment.center
                                  : Alignment.centerRight,
                              child: index == 1 || index == 4
                                  ? Text(
                                      cell,
                                      style: Styles.white18(context),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : index == 0
                                      ? Text(
                                          cell,
                                          style: Styles.black18(context),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : Text(
                                          numValue == 0
                                              ? '-'
                                              : NumberFormat.currency(
                                                      locale: 'th_TH',
                                                      symbol: '')
                                                  .format(numValue),
                                          style: Styles.black18(context),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            // Freeze Footer
            if (footer != null)
              Container(
                color: Colors.grey[200],
                child: Row(
                  children: footer!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cell = entry.value;
                    double numValue = double.tryParse(cell) ?? 0.0;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      width: index == 0
                          ? MediaQuery.of(context).size.width * 0.25
                          : MediaQuery.of(context).size.width * 0.25,
                      height: 56,
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        numValue == 0
                            ? '-'
                            : NumberFormat.currency(locale: 'th_TH', symbol: '')
                                .format(numValue),
                        style: Styles.black18(context)
                            .copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
