import 'dart:convert';
import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/CustomerDropdownSearch.dart';
import 'package:_12sale_app/core/components/badge/CustomBadge.dart';
import 'package:_12sale_app/core/components/table/ShopRouteTable.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/route/TestGooglemap.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/SaleRoute.dart';
import 'package:_12sale_app/function/SavetoStorage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopRouteScreen extends StatefulWidget {
  final String day;
  final String route;
  final String status;

  const ShopRouteScreen(
      {super.key,
      required this.day,
      required this.route,
      required this.status});

  @override
  State<ShopRouteScreen> createState() => _ShopRouteScreenState();
}

class _ShopRouteScreenState extends State<ShopRouteScreen> {
  SaleRoute? routes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadSaleRoute();
  }

  Future<void> _loadSaleRoute() async {
    List<SaleRoute> routesData =
        await loadFromStorage('saleRoutes', (json) => SaleRoute.fromJson(json));
    SaleRoute? routeFilter = routesData.firstWhere(
      (route) => route.day == widget.day.split(" ")[1],
    );
    setState(() {
      routes = routeFilter;
    });
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
      webViewConfiguration: const WebViewConfiguration(
        enableJavaScript: true,
      ),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(
            title: ' ${"route.store_screen.title".tr()} ${widget.day}',
            icon: Icons.event),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CustomerDropdownSearch(),
            SizedBox(
              height: screenWidth / 30,
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBadge(
                    label: "route.store_screen.checkin".tr(),
                    count: '${routes?.storeCheckin ?? '0'}',
                    backgroundColor: Styles.successTextColor,
                    countBackgroundColor: Colors.white,
                  ),
                  CustomBadge(
                    label: "route.store_screen.order".tr(),
                    count: '${routes?.storeBuy ?? '0'}',
                    backgroundColor: Styles.paddingTextColor,
                    countBackgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenWidth / 30,
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBadge(
                    label: "route.store_screen.cancel".tr(),
                    count: '${routes?.storeNotBuy ?? '0'}',
                    backgroundColor: Styles.failTextColor,
                    countBackgroundColor: Colors.white,
                  ),
                  CustomBadge(
                    label: "route.store_screen.all".tr(),
                    count: '${routes?.storeAll ?? '0'}',
                    backgroundColor: Colors.grey,
                    countBackgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            // SizedBox(
            //   height: screenWidth / 30,
            // ),
            // Expanded(child: BoxShadowCustom(child: PolylineWithLabels())),
            SizedBox(
              height: screenWidth / 30,
            ),
            // TextButton.icon(
            //   icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
            //   style: ButtonStyle(
            //     backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            //   ),
            //   onPressed: () async {
            //     // final String url =
            //     //     'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}'
            //     //     '&destination=${destination.latitude},${destination.longitude}'
            //     //     '&waypoints=$waypointsString'
            //     //     '&travelmode=$travelMode';
            //     final Uri url = Uri.parse(
            //         "https://www.google.com/maps/dir/?api=1&origin=13.689600,100.608600&destination=13.918764,100.56767&waypoints=13.760493,100.474507|13.71104,100.517814&travelmode=driving");
            //     _launchUrl(url);
            //   },
            //   label: Text(
            //     "เปิด Google Maps",
            //     style: Styles.white18(context),
            //   ),
            // ),
            // SizedBox(
            //   height: screenWidth / 30,
            // ),
            Expanded(
              child: ShopRouteTable(
                day: widget.day,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
