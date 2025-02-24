import 'dart:async';
import 'dart:convert';

import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/card/StoreVisitCard.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchCustom.dart';
import 'package:_12sale_app/core/page/route/DetailScreen.dart';
import 'package:_12sale_app/core/page/route/RouteScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/route/RouteVisit.dart';
import 'package:_12sale_app/data/models/route/StoreVisit.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RouteAjustCard extends StatefulWidget {
  final RouteVisit routeVisit;
  const RouteAjustCard({
    super.key,
    required this.routeVisit,
  });

  @override
  State<RouteAjustCard> createState() => _RouteAjustCardState();
}

class _RouteAjustCardState extends State<RouteAjustCard> {
  @override
  Widget build(BuildContext context) {
    return RouteAjust(
      routeVisit: widget.routeVisit,
    );
  }
}

class RouteAjust extends StatefulWidget {
  final RouteVisit routeVisit;

  const RouteAjust({
    super.key,
    required this.routeVisit,
  });

  @override
  State<RouteAjust> createState() => _RouteAjustState();
}

class _RouteAjustState extends State<RouteAjust> {
  List<ListStore> listStore = [];
  StoreVisit? storeVisit;
  bool _loadingAllStore = true;
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  Future<void> _getListStore() async {
    ApiService apiService = ApiService();
    await apiService.init();

    var response = await apiService.request(
      endpoint:
          'api/cash/route/getRoute?area=${User.area}&period=${period}&routeId=${widget.routeVisit.id}',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'][0]['listStore'];
      final List<dynamic> dataStore = response.data['data'];
      print("getRoute: ${response.data['data']}");
      if (mounted) {
        setState(() {
          listStore = data.map((item) => ListStore.fromJson(item)).toList();
          storeVisit =
              data.isNotEmpty ? StoreVisit.fromJson(dataStore[0]) : null;
        });
      }
      Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _loadingAllStore = false;
          });
        }
      });
      print("storeVisit: $storeVisit");
      print("listStore: ${data.length}");
    }
  }

  @override
  Widget build(BuildContext context) {
    double sreenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onDoubleTap: () {},
      child: Card(
        margin: EdgeInsets.only(left: 10, top: 5, right: 2, bottom: 5),
        color: Colors.white,
        child: ExpansionTile(
          minTileHeight: 75,
          // collapsedBackgroundColor: Colors.white,
          backgroundColor: Colors.grey[100],
          leading: Icon(
            Icons.route,
            color: Styles.primaryColor,
            size: 40,
          ),
          onExpansionChanged: (value) {
            if (value) _getListStore(); // Fetch data only when expanded
          },
          collapsedShape: RoundedRectangleBorder(
            side: BorderSide.none, // No border when collapsed
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide.none, // No border when expanded
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "R${widget.routeVisit.day}",
                      style: Styles.headerPirmary24(context),
                    ),
                    Text(
                      "${widget.routeVisit.storeAll} ร้าน",
                      style: Styles.headerPirmary24(context),
                    ),
                  ],
                ),
              ),
            ],
          ),

          children: [
            Container(
              height:
                  listStore.isNotEmpty ? sreenWidth : 100, // Set a fixed height
              child: listStore.isEmpty
                  ? Center(
                      child: SizedBox(),
                    ) // Show loader when fetching

                  : LoadingSkeletonizer(
                      loading: _loadingAllStore,
                      child: ListView.builder(
                        itemCount: listStore.length,
                        shrinkWrap: true, // Allow the ListView to size itself
                        physics:
                            BouncingScrollPhysics(), // Enable smooth scrolling
                        itemBuilder: (context, index) {
                          return StoreAjustRouteCard(
                            index: index,
                            route: widget.routeVisit.day,
                            routeId: widget.routeVisit.id,
                            store: listStore[index],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
