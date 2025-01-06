import 'dart:convert';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShopTableNew extends StatefulWidget {
  const ShopTableNew({super.key});

  @override
  State<ShopTableNew> createState() => _ShopTableNew();
}

class _ShopTableNew extends State<ShopTableNew> {
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
  //     _jsonString = jsonDecode(jsonString)["shop_new_table"];
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
                  _buildHeaderCellName(
                      _jsonString?['customer_no'] ?? 'Customer No',
                      screenWidth / 3.5),
                  _buildHeaderCellName(
                      _jsonString?['customer_name'] ?? 'Customer Name',
                      screenWidth / 3.5),
                  _buildHeaderCell(_jsonString?['route'] ?? 'Route'),
                  _buildHeaderCell(_jsonString?['address'] ?? 'Address'),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    _buildDataRow('MBE23000001', 'เจ๊กุ้ง', 'R01', 'รออนุมัติ',
                        0, context),
                    _buildDataRow('MBE23000002', 'บริษัท ขายของชำไม่จำกัด',
                        'R03', 'ไม่อนุมัติ', 1, context),
                    _buildDataRow('MBE23000003', 'บริษัท ขายส้มตำ จำกัด', 'R01',
                        'อนุมัติ', 2, context),
                    _buildDataRow('MBE23000004', 'บริษัท ขายส้มตำภาษี จำกัด',
                        'R01', 'อนุมัติ', 3, context),
                    _buildDataRow('MBE23000005', 'บริษัท เก่งกำไรจำกัด มหาชน',
                        'R10', 'อนุมัติ', 4, context),
                    _buildDataRow('MBE23000006', 'ร้านลุงอ่อย ขายส้มตำ', 'R08',
                        'อนุมัติ', 5, context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String customerNo, String customerName, String route,
      String status, int index, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Alternate row background color
    Color rowBgColor =
        (index % 2 == 0) ? Colors.white : Styles.backgroundTableColor;

    Color backgroundColor = (status == 'ไม่อนุมัติ')
        ? Colors.red
        : (status == 'รออนุมัติ')
            ? Colors.orange
            : Colors.green;
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: rowBgColor,
        ),
        child: Row(
          children: [
            _buildTableCellName(customerNo, screenWidth / 3.5),
            _buildTableCellName(customerName, screenWidth / 3.5),
            Expanded(child: _buildTableCell(route, Alignment.center)),
            _buildStatusCell(context, backgroundColor, screenWidth / 8, status),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCellName(String text, double width) {
    return Container(
      alignment: Alignment.centerLeft,
      width: width,
      padding: const EdgeInsets.all(8),
      child: Text(text, style: Styles.black18(context)),
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
}

Widget _buildStatusCell(
    BuildContext context, Color? bgColor, double? width, String text) {
  return Expanded(
    child: Container(
      width: width,
      alignment: Alignment.center,
      child: Container(
        // width: 50, // Optional inner width for the status cell
        // padding: EdgeInsets.all(10),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(
              100), // Rounded corners for the inner container
        ),
        alignment: Alignment.center,
        child: Text(text, style: Styles.white18(context)),
      ),
    ),
  );
}
