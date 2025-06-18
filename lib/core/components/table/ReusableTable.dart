import 'package:_12sale_app/core/page/stock/StockDetail.dart';
import 'package:flutter/material.dart';
import 'package:_12sale_app/core/styles/style.dart';

class ReusableTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final List<List<String>> itemCodes;

  const ReusableTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.itemCodes,
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
                    width: index == 0
                        ? MediaQuery.of(context).size.width * 0.35
                        : MediaQuery.of(context).size.width * 0.15,
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
                      return GestureDetector(
                        onTap: () {
                          // Replace this with navigation logic
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockDetail(
                                itemCode: itemCodes[rows.indexOf(row)][0],
                              ), // row[0] = productId
                            ),
                          );
                        },
                        child: Row(
                          children: row.asMap().entries.map((entry) {
                            final index = entry.key;
                            final cell = entry.value;

                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black), // Border added here
                              ),
                              width: index == 0
                                  ? MediaQuery.of(context).size.width * 0.35
                                  : MediaQuery.of(context).size.width * 0.15,
                              height: 95,
                              padding: const EdgeInsets.all(8),
                              alignment: Alignment.center,
                              child: Text(
                                cell,
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
          ],
        ),
      ),
    );
  }
}
