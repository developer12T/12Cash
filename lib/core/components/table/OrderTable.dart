import 'dart:convert';

import 'package:_12sale_app/core/page/route/OrderDetailScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderTable extends StatefulWidget {
  final String customerNo;
  final String customerName;
  final String status;
  const OrderTable(
      {super.key,
      required this.customerNo,
      required this.customerName,
      required this.status});

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  Map<String, dynamic>? _jsonString;
  @override
  void initState() {
    super.initState();
    // _loadJson();
  }

  // Future<void> _loadJson() async {
  //   String jsonString = await rootBundle.loadString('lang/main-th.json');
  //   setState(() {
  //     _jsonString = jsonDecode(jsonString)["order_table"];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        height: screenWidth / 1.3,
        // Adds space around the entire table
        decoration: BoxDecoration(
          color: Colors.white, // Set background color if needed
          borderRadius: BorderRadius.circular(
              16), // Rounded corners for the outer container

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.2), // Shadow color with transparency
              spreadRadius: 2, // Spread of the shadow
              blurRadius: 8, // Blur radius of the shadow
              offset:
                  Offset(0, 4), // Offset of the shadow (horizontal, vertical)
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed header
            Container(
              decoration: const BoxDecoration(
                color: Styles.backgroundTableColor,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16)), // Rounded corners at the top
              ),
              child: Row(
                children: [
                  _buildHeaderCell(_jsonString?['item_code'] ?? 'Item Code'),
                  _buildHeaderCell(_jsonString?['item_name'] ?? 'Item Name'),
                  _buildHeaderCell('จำนวน (ซอง)'),
                  // _buildHeaderCellIcon('', 50),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    _buildDataRow(
                        '10010101001',
                        'ผงปรุงรสหมู ฟ้าไทย 10g x12x20',
                        '58',
                        Styles.successBackgroundColor,
                        Styles.successTextColor,
                        0),
                    _buildDataRow(
                        '10010101002',
                        'ผงปรุงรสหมู ฟ้าไทย 10g x24x10 ชนิดแผง',
                        '45',
                        Styles.successBackgroundColor,
                        Styles.successTextColor,
                        1),
                    _buildDataRow(
                        '10010101003',
                        'ผงปรุงรสหมู ฟ้าไทย 30g x20x12',
                        '345',
                        Styles.failBackgroundColor,
                        Styles.failTextColor,
                        2),
                    _buildDataRow(
                        '10010101004',
                        'ผงปรุงรสหมู ฟ้าไทย 30g x24x5 ชนิดแผง',
                        '133',
                        Styles.paddingBackgroundColor,
                        Colors.blue,
                        3),
                    _buildDataRow(
                        '10010101005',
                        'ผงปรุงรสหมู ฟ้าไทย 80g x10x8"',
                        '500',
                        Styles.paddingBackgroundColor,
                        Colors.blue,
                        4),
                    _buildDataRow(
                        '10010101006',
                        'ผงปรุงรสหมู ฟ้าไทย 80g x10x8 พิเศษ 9 บาท',
                        '8',
                        Styles.successBackgroundColor,
                        Styles.successTextColor,
                        5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String itemCode, String itemName, String qty,
      Color? bgColor, Color? textColor, int index) {
    // Alternate row background color
    Color rowBgColor =
        (index % 2 == 0) ? Colors.white : Styles.backgroundTableColor;
    // Color? badgeColor = int.parse(qty) >= 500
    //     ? Styles.successBackgroundColor
    //     : int.parse(qty) >= 100
    //         ? Styles.warningBackgroundColor
    //         : Styles.failBackgroundColor;

    Color? badgeColor = int.parse(qty) >= 500
        ? Colors.green[900]
        : int.parse(qty) >= 100
            ? Colors.orange[900]
            : Colors.red[900];

    // Color? badgeTextColor = int.parse(qty) >= 500
    //     ? Styles.successTextColor
    //     : int.parse(qty) >= 100
    //         ? Styles.warningTextColor
    //         : Styles.failTextColor;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetail(
              itemCode: itemCode,
              itemName: itemName,
              price: qty,
              customerNo: widget.customerNo,
              customerName: widget.customerName,
              status: widget.status,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: rowBgColor,
        ),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: _buildTableCell(
                    itemCode)), // Use Expanded to distribute space equally
            Expanded(flex: 3, child: _buildTableCell(itemName)),
            Expanded(child: _buildBadgeCell(qty, badgeColor)),
            _buildStatusCell(qty, bgColor, textColor, 50),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCell(
      String qty, Color? bgColor, Color? textColor, double? width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Container(
        width: 50, // Optional inner width for the status cell
        // padding: EdgeInsets.all(10),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(
              5), // Rounded corners for the inner container
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.add, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildBadgeCell(
    String text,
    Color? bgColor,
    // Color? textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(5), // Rounded corners for the inner container
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(text, style: Styles.white18(context)),
    );
  }

  Widget _buildTableCell(String text) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(text, style: Styles.black18(context)),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: Styles.grey18(context),
        ),
      ),
    );
  }

  Widget _buildHeaderCellIcon(String text, double width) {
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(16),
      // ),
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: Styles.grey18(context),
      ),
    );
  }
}
