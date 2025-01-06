import 'dart:convert';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyTable extends StatefulWidget {
  const VerifyTable({super.key});

  @override
  State<VerifyTable> createState() => _VerifyTable();
}

class _VerifyTable extends State<VerifyTable> {
  Map<String, dynamic>? _jsonString;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _loadJson();
  }

  // Future<void> _loadJson() async {
  //   String jsonString = await rootBundle.loadString('lang/main-th.json');
  //   setState(() {
  //     _jsonString = jsonDecode(jsonString)["verify_table"];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        height: screenWidth / 2.5,
        // Adds space around the entire table
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
              16), // Rounded corners for the outer container
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
                  _buildHeaderCellName(_jsonString?['item_name'] ?? 'Item Name',
                      screenWidth / 2.6),
                  _buildHeaderCell(_jsonString?['qty'] ?? 'QTY'),
                  _buildHeaderCell(
                      _jsonString?['customer_name'] ?? 'Customer Name'),
                  _buildHeaderCell(_jsonString?['discount'] ?? 'Discount'),
                  _buildHeaderCell(_jsonString?['sum'] ?? 'Sum'),
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
                        '1011447875',
                        'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                        '58.00',
                        '00.00',
                        '1 หีบ',
                        Styles.successBackgroundColor,
                        Styles.successTextColor,
                        0),
                    _buildDataRow(
                        '1011447875',
                        'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                        '58.00',
                        '00.00',
                        '1 หีบ',
                        Styles.successBackgroundColor,
                        Styles.successTextColor,
                        1),
                    _buildDataRow(
                        '1011447875',
                        'ผงปรุงรสเห็ดหอม ฟ้าไทย 75g x10x8',
                        '5800.00',
                        '00.00',
                        '1 หีบ',
                        Styles.failBackgroundColor,
                        Styles.failTextColor,
                        2),
                    _buildDataRow(
                        '1011447875',
                        'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                        '58.00',
                        '00.00',
                        '10 ซอง',
                        Styles.paddingBackgroundColor,
                        Colors.blue,
                        3),
                    _buildDataRow(
                        '1011447875',
                        'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                        '58.00',
                        '00.00',
                        '10 หีบ',
                        Styles.paddingBackgroundColor,
                        Colors.blue,
                        4),
                    _buildDataRow(
                        '1011447875',
                        'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                        '58.00',
                        '00.00',
                        '100 ถุง',
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

  Widget _buildDataRow(
      String itemCode,
      String itemName,
      String price,
      String discount,
      String count,
      Color? bgColor,
      Color? textColor,
      int index) {
    // Alternate row background color
    Color rowBgColor =
        (index % 2 == 0) ? Colors.white : Styles.backgroundTableColor;

    return InkWell(
      onTap: () {
        _showSheetChangePromotion(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: rowBgColor,
        ),
        child: Row(
          children: [
            Expanded(
                flex: 3,
                child: _buildTableCell(itemName, Alignment.centerLeft)),
            Expanded(
                flex: 1, child: _buildTableCell(count, Alignment.centerRight)),
            Expanded(
                flex: 1, child: _buildTableCell(price, Alignment.centerRight)),
            Expanded(
                flex: 1,
                child: _buildTableCell(discount, Alignment.centerRight)),
            Expanded(
                flex: 1, child: _buildTableCell(price, Alignment.centerRight)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRowSheet(
      String itemCode,
      String itemName,
      String price,
      String discount,
      String count,
      Color? bgColor,
      Color? textColor,
      int index) {
    // Alternate row background color
    Color rowBgColor =
        (index % 2 == 0) ? Colors.white : Styles.backgroundTableColor;

    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: rowBgColor,
        ),
        child: Row(
          children: [
            Expanded(
                flex: 3,
                child: _buildTableCell(itemName, Alignment.centerLeft)),
            Expanded(flex: 1, child: _buildTableCell(count, Alignment.center)),
            Expanded(
                flex: 1, child: _buildTableCell(price, Alignment.centerRight)),
            Expanded(
                flex: 1,
                child: _buildTableCell(discount, Alignment.centerRight)),
            Expanded(
                flex: 1, child: _buildTableCell(price, Alignment.centerRight)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.all(8),
      child: Text(text, style: Styles.black18(context)),
    );
  }

  Widget _buildHeaderCellName(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: Styles.grey18(context),
      ),
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

  void _showSheetChangePromotion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes the bottom sheet full screen height
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        return Container(
          // width: screenWidth, // Fixed width
          height: screenWidth + 100,
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 40,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close bottom sheet
                      },
                    ),
                    Text('ตารางสินค้า', style: Styles.headerBlack18(context)),
                  ],
                ),
                const SizedBox(height: 8),
                // Store Information
                Center(
                  child: Container(
                    height: screenWidth,
                    margin: EdgeInsets.all(
                        screenWidth / 50), // Adds space around the entire table
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          16), // Rounded corners for the outer container
                      border: Border.all(
                          color: Colors.grey, width: 1), // Outer border
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fixed header
                        Container(
                          decoration: const BoxDecoration(
                            color: Styles.backgroundTableColor,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(
                                    16)), // Rounded corners at the top
                          ),
                          child: Row(
                            children: [
                              _buildHeaderCellName(
                                  'ชื่อสินค้า', screenWidth / 2.7),
                              _buildHeaderCell('จำนวน'),
                              _buildHeaderCell('ราคา'),
                              _buildHeaderCell('ส่วนลด'),
                              _buildHeaderCell('รวม'),
                            ],
                          ),
                        ),
                        // Scrollable content
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                _buildDataRowSheet(
                                    '1011447875',
                                    'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                                    '58.00',
                                    '00.00',
                                    '1 หีบ',
                                    Styles.successBackgroundColor,
                                    Styles.successTextColor,
                                    0),
                                _buildDataRowSheet(
                                    '1011447875',
                                    'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                                    '58.00',
                                    '00.00',
                                    '1 หีบ',
                                    Styles.successBackgroundColor,
                                    Styles.successTextColor,
                                    1),
                                _buildDataRowSheet(
                                    '1011447875',
                                    'ผงปรุงรสเห็ดหอม ฟ้าไทย 75g x10x8',
                                    '5800.00',
                                    '00.00',
                                    '1 หีบ',
                                    Styles.failBackgroundColor,
                                    Styles.failTextColor,
                                    2),
                                _buildDataRowSheet(
                                    '1011447875',
                                    'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                                    '58.00',
                                    '00.00',
                                    '10 ซอง',
                                    Styles.paddingBackgroundColor,
                                    Colors.blue,
                                    3),
                                _buildDataRowSheet(
                                    '1011447875',
                                    'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                                    '58.00',
                                    '00.00',
                                    '10 หีบ',
                                    Styles.paddingBackgroundColor,
                                    Colors.blue,
                                    4),
                                _buildDataRowSheet(
                                    '1011447875',
                                    'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                                    '58.00',
                                    '00.00',
                                    '100 ถุง',
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
