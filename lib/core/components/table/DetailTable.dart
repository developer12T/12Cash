import 'dart:convert';

import 'package:_12sale_app/core/page/route/DetailScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Order.dart';
import 'package:_12sale_app/data/models/search/SaleRoute.dart';
import 'package:_12sale_app/function/SavetoStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailTable extends StatefulWidget {
  final String day;
  final String customerNo;
  const DetailTable({
    super.key,
    required this.day,
    required this.customerNo,
  });

  @override
  State<DetailTable> createState() => _DetailTableState();
}

class _DetailTableState extends State<DetailTable> {
  List<Store> stores = [];
  List<ListOrder> orders = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _loadStoreDetail();
  }

  // Future<void> _loadStoreDetail() async {
  //   List<SaleRoute> routes =
  //       await loadFromStorage('saleRoutes', (json) => SaleRoute.fromJson(json));
  //   List<Store> filteredStores = routes
  //       .where((route) => route.day == widget.day.split(" ")[1])
  //       .expand((route) => route.listStore)
  //       .toList();
  //   List<ListOrder> filteredOrders = filteredStores
  //       .where((store) => store.storeInfo.storeId == widget.customerNo)
  //       .expand((store) => store.listOrder)
  //       .toList();

  //   setState(() {
  //     orders = filteredOrders;
  //   });
  // }

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr); // Parse the original date string
    DateFormat formatter =
        DateFormat('dd/MM/yyyy'); // Define the desired format
    return formatter.format(date); // Format the date
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        // height: screenHeight / 1.5,
        padding: const EdgeInsets.only(bottom: 10),
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
              offset: const Offset(
                  0, 4), // Offset of the shadow (horizontal, vertical)
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
                  Expanded(child: _buildHeaderCell("วันที่")),
                  Expanded(flex: 2, child: _buildHeaderCell("รายการ")),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: List.generate(orders.length, (index) {
                    final order = orders[index];
                    return _buildDataRow(
                        formatDate(order.date.toString()),
                        order.orderId,
                        order.orderId,
                        order.orderId,
                        Styles.successBackgroundColor,
                        Styles.successTextColor,
                        index);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String customerNo, String customerName, String address,
      String status, Color? bgColor, Color? textColor, int index) {
    // Alternate row background color
    Color rowBgColor =
        (index % 2 == 0) ? Colors.white : Styles.backgroundTableColor;

    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => DetailScreen(
        //         route:,
        //         route: widget.day,
        //         customerNo: customerNo,
        //         customerName: customerName,
        //         address: address,
        //         status: status),
        //   ),
        // );
      },
      child: Container(
        decoration: BoxDecoration(
          color: rowBgColor,
        ),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: _buildTableCell(
                    customerNo)), // Use Expanded to distribute space equally
            Expanded(flex: 2, child: _buildTableCell(customerName)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCell(
      String status, Color? bgColor, Color? textColor, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      alignment: Alignment.center,
      child: Container(
        width: screenWidth / 5, // Optional inner width for the status cell
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(
              100), // Rounded corners for the inner container
        ),
        alignment: Alignment.center,
        child: Text(
          status,
          style:
              GoogleFonts.kanit(color: textColor, fontSize: screenWidth / 35),
        ),
      ),
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
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: Styles.grey18(context),
      ),
    );
  }
}
