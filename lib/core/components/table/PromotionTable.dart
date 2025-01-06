import 'dart:convert';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Promotiontable extends StatefulWidget {
  const Promotiontable({super.key});

  @override
  State<Promotiontable> createState() => _PromotiontableState();
}

class _PromotiontableState extends State<Promotiontable> {
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
  //     _jsonString = jsonDecode(jsonString)["promotion_table"];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        height: screenWidth / 2,
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
                      screenWidth / 2),
                  _buildHeaderCell(_jsonString?['qty'] ?? 'QTY'),
                  _buildHeaderCell(_jsonString?['amount'] ?? 'Amount'),
                  _buildHeaderCellIcon('', 50),
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
                        Styles.successBackgroundColor,
                        Styles.successTextColor,
                        0,
                        context),
                    _buildDataRow(
                        '1011447875',
                        'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                        '58.00',
                        Styles.successBackgroundColor,
                        Styles.successTextColor,
                        1,
                        context),
                    _buildDataRow(
                        '1011447875',
                        'ผงปรุงรสเห็ดหอม ฟ้าไทย 75g x10x8',
                        '5800.00',
                        Styles.failBackgroundColor,
                        Styles.failTextColor,
                        2,
                        context),
                    _buildDataRow(
                        '1011447875',
                        'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                        '58.00',
                        Styles.paddingBackgroundColor,
                        Colors.blue,
                        3,
                        context),
                    _buildDataRow(
                        '1011447875',
                        'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                        '58.00',
                        Styles.paddingBackgroundColor,
                        Colors.blue,
                        4,
                        context),
                    _buildDataRow(
                        '1011447875',
                        'ผงปรุงรสไก่ ฟ้าไทย 75g x10x8',
                        '58.00',
                        Styles.successBackgroundColor,
                        Styles.successTextColor,
                        5,
                        context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String itemCode, String itemName, String count,
      Color? bgColor, Color? textColor, int index, BuildContext context) {
    // Alternate row background color
    Color rowBgColor =
        (index % 2 == 0) ? Colors.white : Styles.backgroundTableColor;
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        _showSheetChangePromotion(context, itemCode, itemName, count);
      },
      child: Container(
        decoration: BoxDecoration(
          color: rowBgColor,
        ),
        child: Row(
          children: [
            _buildTableCellName(itemName, screenWidth / 2),
            Expanded(child: _buildTableCell(count)),
            Expanded(child: _buildTableCell(count)),
            _buildStatusCell(count, bgColor, textColor,
                50), // Custom function for "สถานะ" column
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCell(
      String count, Color? bgColor, Color? textColor, double? width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Container(
        width: 50, // Optional inner width for the status cell
        // padding: EdgeInsets.all(10),
        margin: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.red,
          // borderRadius: BorderRadius.circular(
          //     100), // Rounded corners for the inner container
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.close, color: Colors.white, size: 40),
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

  Widget _buildTableCell(String text) {
    return Container(
      alignment: Alignment.centerRight,
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
        alignment: Alignment.centerRight,
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
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: Styles.grey18(context),
      ),
    );
  }

  void _showSheetChangePromotion(
      BuildContext context, String itemCode, String itemName, String count) {
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
          width: screenWidth, // Fixed width
          height: screenWidth / 1.3,
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                    Text('เปลี่ยนของแถม', style: Styles.headerBlack18(context)),
                  ],
                ),
                const SizedBox(height: 8),
                // Store Information
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${itemName}',
                        style: Styles.black18(context),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                              child: Text('กลุ่ม',
                                  style: Styles.black18(context))),
                          Flexible(
                            // fit: FlexFit.tight,
                            flex: 4,
                            child: Container(
                              // width: 100,
                              height: screenWidth / 11,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[
                                      300], // Set the fill color to match the image
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide
                                        .none, // Remove border if not needed
                                  ),
                                  // contentPadding: EdgeInsets.only(left: 250),
                                ),
                                style: Styles.white18(context),

                                value: 'อื่นๆ', // Default value
                                alignment: Alignment
                                    .center, // Center the selected value text
                                items: <String>['อื่นๆ', 'เหตุผล 1', 'เหตุผล 2']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(
                                      // Center-align the text inside the dropdown items
                                      child: Text(
                                        value,
                                        style: Styles.black18(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                              child: Text('น้ำหนัก',
                                  style: Styles.black18(context))),
                          Flexible(
                            // fit: FlexFit.tight,
                            flex: 4,
                            child: Container(
                              // width: 100,
                              height: screenWidth / 11,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[
                                      300], // Set the fill color to match the image
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide
                                        .none, // Remove border if not needed
                                  ),
                                  // contentPadding: EdgeInsets.only(left: 250),
                                ),
                                style: Styles.white18(context),

                                value: 'อื่นๆ', // Default value
                                alignment: Alignment
                                    .center, // Center the selected value text
                                items: <String>['อื่นๆ', 'เหตุผล 1', 'เหตุผล 2']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(
                                      // Center-align the text inside the dropdown items
                                      child: Text(
                                        value,
                                        style: Styles.black18(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Dropdown field

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                              child: Text('ของแถม',
                                  style: Styles.black18(context))),
                          Flexible(
                            // fit: FlexFit.tight,
                            flex: 4,
                            child: SizedBox(
                              // width: 100,
                              height: screenWidth / 11,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[
                                      300], // Set the fill color to match the image
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide
                                        .none, // Remove border if not needed
                                  ),
                                  // contentPadding: EdgeInsets.only(left: 250),
                                ),
                                style: Styles.white18(context),

                                value: 'อื่นๆ', // Default value
                                alignment: Alignment
                                    .center, // Center the selected value text
                                items: <String>['อื่นๆ', 'เหตุผล 1', 'เหตุผล 2']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(
                                      // Center-align the text inside the dropdown items
                                      child: Text(
                                        value,
                                        style: Styles.black18(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                              child: Text('จำนวน',
                                  style: Styles.black18(context))),
                          Flexible(
                            // fit: FlexFit.tight,
                            flex: 4,
                            child: SizedBox(
                              // width: 100,
                              height: screenWidth / 11,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[
                                      300], // Set the fill color to match the image
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide
                                        .none, // Remove border if not needed
                                  ),
                                  // contentPadding: EdgeInsets.only(left: 250),
                                ),
                                style: Styles.white18(context),

                                value: 'อื่นๆ', // Default value
                                alignment: Alignment
                                    .center, // Center the selected value text
                                items: <String>['อื่นๆ', 'เหตุผล 1', 'เหตุผล 2']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(
                                      // Center-align the text inside the dropdown items
                                      child: Text(
                                        value,
                                        style: Styles.black18(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      // Spacer(),
                      // Save button
                      SizedBox(
                        width: double.infinity, // Full width button
                        child: ElevatedButton(
                          onPressed: () {
                            // Perform save action
                            Navigator.of(context)
                                .pop(); // Close the bottom sheet
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Styles.successButtonColor,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('บันทึก', style: Styles.white18(context)),
                        ),
                      ),
                    ],
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
