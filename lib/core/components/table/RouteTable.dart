// ignore: file_names
import 'dart:convert';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/route/ShopRouteScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/search/SaleRoute.dart';
import 'package:_12sale_app/function/SavetoStorage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class RouteTable extends StatefulWidget {
  const RouteTable({super.key});

  @override
  State<RouteTable> createState() => _RouteTableState();
}

class _RouteTableState extends State<RouteTable> {
  List<SaleRoute> routes = [];
  @override
  void initState() {
    super.initState();
    _loadSaleRoute();
  }

  Future<void> _loadSaleRoute() async {
    List<SaleRoute> routes =
        await loadFromStorage('saleRoutes', (json) => SaleRoute.fromJson(json));
    setState(() {
      this.routes = routes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // height: screenWidth / 2.5,
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
                  _buildHeaderCell("route.route_table.date".tr()),
                  _buildHeaderCell("route.route_table.route".tr()),
                  _buildHeaderCell("route.route_table.status".tr()),
                  // _buildHeaderCell('สถานะ'),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    ...List.generate(routes.length, (index) {
                      final route = routes[index];
                      return _buildDataRow(
                          '${"route.route_table.date".tr()} ${route.day}',
                          '${int.tryParse(route.day)}',
                          '${route.storeTotal}/${route.storeAll}',
                          route.storeTotal == route.storeAll
                              ? Styles.successBackgroundColor
                              : route.storeTotal == 0
                                  ? Styles.failBackgroundColor
                                  : Styles.paddingBackgroundColor,
                          route.storeTotal == route.storeAll
                              ? Styles.successTextColor
                              : route.storeTotal == 0
                                  ? Styles.failTextColor
                                  : Colors.blue,
                          index);
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String day, String route, String status, Color? bgColor,
      Color? textColor, int index) {
    // Alternate row background color
    Color rowBgColor =
        (index % 2 == 0) ? Colors.white : Styles.backgroundTableColor;

    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         ShopRouteScreen(day: day, route: route, status: status),
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
                child: _buildTableCell(
                    day)), // Use Expanded to distribute space equally
            Expanded(child: _buildTableCell(route)),
            // Expanded(child: _buildTableCell(route)),
            Expanded(
                child: _buildStatusCell(status, bgColor, textColor,
                    context)), // Custom function for "สถานะ" column
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
