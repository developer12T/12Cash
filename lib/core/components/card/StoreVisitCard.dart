import 'dart:convert';

import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchCustom.dart';
import 'package:_12sale_app/core/page/route/DetailScreen.dart';
import 'package:_12sale_app/core/page/route/DetailScreen.dart';
import 'package:_12sale_app/core/page/route/RouteScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/route/StoreVisit.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:toastification/toastification.dart';

class StoreVisitCard extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final ListStore store;
  final String route;
  final String routeId;

  const StoreVisitCard({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.store,
    required this.route,
    required this.routeId,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 30,
        height: 30,
        color: store.status == '1'
            ? Styles.success!
            : store.status == '2'
                ? Styles.success!
                : Styles.fail!,
        indicator: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: store.status == '1'
                ? Styles.success!
                : store.status == '2'
                    ? Styles.success!
                    : Styles.fail!,
          ),
          child: store.status == '1'
              ? Icon(
                  Icons.attach_money_rounded,
                  color: Colors.white,
                )
              : store.status == '2'
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.schedule,
                      color: Colors.white,
                    ),
        ),
      ),
      afterLineStyle: LineStyle(
        thickness: 1,
        color: store.status == '1'
            ? Styles.success!
            : store.status == '2'
                ? Styles.success!
                : Styles.fail!,
      ),
      beforeLineStyle: LineStyle(
        thickness: 1,
        color: store.status == '1'
            ? Styles.success!
            : store.status == '2'
                ? Styles.success!
                : Styles.fail!,
      ),
      endChild: StoreCard(
        store: store,
        route: route,
        routeId: routeId,
      ),
    );
  }
}

class StoreCard extends StatelessWidget {
  final ListStore store;
  final String route;
  final String routeId;

  const StoreCard({
    super.key,
    required this.store,
    required this.route,
    required this.routeId,
  });

  Future<List<RouteStore>> getRoutes(String filter) async {
    try {
      // Load the JSON file for districts
      final String response = await rootBundle.loadString('data/route.json');
      final data = json.decode(response);

      // Filter and map JSON data to District model based on selected province and filter
      final List<RouteStore> route =
          (data as List).map((json) => RouteStore.fromJson(json)).toList();

      // Group districts by amphoe
      return route;
    } catch (e) {
      print("Error occurred: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              customerNo: store.storeInfo.storeId,
              routeId: routeId,
              route: route,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        child: ListTile(
          leading: Icon(
            Icons.store,
            color: Styles.primaryColor,
            size: 40,
          ),
          minTileHeight: 100,
          shape: RoundedRectangleBorder(
            side: BorderSide.none, // No border when expanded
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    store.storeInfo.storeId,
                    style: Styles.black18(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Skeleton.ignore(
                    child: Container(
                      // padding: EdgeInsets.symmetric(horizontal: 8),
                      width: 100,
                      decoration: BoxDecoration(
                        color: store.status == '1'
                            ? Styles.success
                            : store.status == '2'
                                ? Styles.warning
                                : Styles.fail,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${store.statusText}',
                        style: Styles.white18(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '${store.storeInfo.name}',
                style: Styles.black18(context),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${store.storeInfo.address}',
                      style: Styles.black18(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // subtitle: Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text(
          //       '${store.storeInfo.name}',
          //       style: Styles.black18(context),
          //     ),
          //     Text(
          //       '${store.storeInfo.address}',
          //       style: Styles.black18(context),
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}

class StoreAjustRouteCard extends StatefulWidget {
  final int index;
  final ListStore store;
  final String route;
  final String routeId;

  const StoreAjustRouteCard({
    super.key,
    required this.index,
    required this.store,
    required this.route,
    required this.routeId,
  });

  @override
  State<StoreAjustRouteCard> createState() => _StoreAjustRouteCardState();
}

class _StoreAjustRouteCardState extends State<StoreAjustRouteCard> {
  String toRoute = '';
  bool isChecked = false;
  Future<List<RouteStore>> getRoutes(String filter) async {
    try {
      // Load the JSON file for districts
      final String response = await rootBundle.loadString('data/route.json');
      final data = json.decode(response);

      // Filter and map JSON data to District model based on selected province and filter
      final List<RouteStore> route =
          (data as List).map((json) => RouteStore.fromJson(json)).toList();

      // Group districts by amphoe
      return route;
    } catch (e) {
      print("Error occurred: $e");
      return [];
    }
  }

  Future<void> _updateRouteStore(
    String storeId,
    String fromRoute,
    String toRoute,
    BuildContext context,
  ) async {
    try {
      AllAlert.checkinAlert(context, () async {
        ApiService apiService = ApiService();
        await apiService.init();
        var response = await apiService.request(
          endpoint: 'api/cash/route/change',
          method: 'POST',
          body: {
            "area": "${User.area}",
            "period": "${period}",
            "storeId": "${storeId}",
            "fromRoute": "R${fromRoute}",
            "toRoute": "${toRoute}",
            "changedBy": "${User.username}",
            "changedDate": "${DateTime.now()}",
            "status": "0",
            "approvedBy": "",
            "approvedDate": ""
          },
        );

        if (response.statusCode == 200) {
          print("statusCode: $response.statusCode");
          print("Response API ${response.data}");
          toastification.show(
            autoCloseDuration: const Duration(seconds: 5),
            context: context,
            primaryColor: Colors.green,
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            title: Text(
              "store.processtimeline_screen.toasting_success".tr(),
              style: Styles.black18(context),
            ),
          );
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              customerNo: widget.store.storeInfo.storeId,
              routeId: widget.routeId,
              route: widget.route,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(left: 10, top: 5, right: 2, bottom: 5),
        color: Colors.white,
        child: ExpansionTile(
          minTileHeight: 100,
          // collapsedBackgroundColor: Colors.white,
          backgroundColor: Colors.grey[100],
          leading: Checkbox(
            value: isChecked,
            onChanged: (bool? value) {
              setState(() {
                isChecked = value!;
              });
            },
          ),
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
                child: Text(
                  "${widget.index + 1}.${widget.store.storeInfo.name}",
                  style: Styles.black18(context),
                ),
              ),
            ],
          ),
          // trailing: Container(
          //   // margin: EdgeInsets.symmetric(vertical: 8),
          //   width: 175,
          //   height: 75,
          //   child: DropdownSearchCustom<RouteStore>(
          //     label: "ปรับรูท R${widget.route}",
          //     titleText: "ปรับรูท R${widget.route}",
          //     fetchItems: (filter) => getRoutes(filter),
          //     onChanged: (RouteStore? selected) async {
          //       if (selected != null) {
          //         toRoute = selected.route;
          //       }
          //     },
          //     itemAsString: (RouteStore data) => data.route,
          //     itemBuilder: (context, item, isSelected) {
          //       return Column(
          //         children: [
          //           ListTile(
          //             title: Text(
          //               " ${item.route}",
          //               style: Styles.black18(context),
          //             ),
          //             selected: isSelected,
          //           ),
          //           Divider(
          //             color: Colors.grey[200], // Color of the divider line
          //             thickness: 1, // Thickness of the line
          //             indent: 16, // Left padding for the divider line
          //             endIndent: 16, // Right padding for the divider line
          //           ),
          //         ],
          //       );
          //     },
          //   ),
          // ),
          subtitle: Text(
            '${widget.store.storeInfo.storeId}',
            style: Styles.black18(context),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "ที่อยู่: ${widget.store.storeInfo.address}",
                                style: Styles.black18(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                routeId: widget.routeId,
                                route: widget.route,
                                customerNo: widget.store.storeInfo.storeId,
                              ),
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () {
                            _updateRouteStore(
                              widget.store.storeInfo.storeId,
                              widget.route,
                              toRoute,
                              context,
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 20),
                            padding: EdgeInsets.all(8),
                            width: 125,
                            decoration: BoxDecoration(
                              color: Styles.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ปรับรูท',
                              style: Styles.white18(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "ประเภท: ${widget.store.storeInfo.typeName}",
                        style: Styles.black18(context),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class StoreAjust2RouteCard extends StatefulWidget {
  final int index;
  final ListStore store;
  final String route;
  final String routeId;

  const StoreAjust2RouteCard({
    super.key,
    required this.index,
    required this.store,
    required this.route,
    required this.routeId,
  });

  @override
  State<StoreAjust2RouteCard> createState() => _StoreAjust2RouteCardState();
}

class _StoreAjust2RouteCardState extends State<StoreAjust2RouteCard> {
  String toRoute = '';
  bool isChecked = false;
  Future<List<RouteStore>> getRoutes(String filter) async {
    try {
      // Load the JSON file for districts
      final String response = await rootBundle.loadString('data/route.json');
      final data = json.decode(response);

      // Filter and map JSON data to District model based on selected province and filter
      final List<RouteStore> route =
          (data as List).map((json) => RouteStore.fromJson(json)).toList();

      // Group districts by amphoe
      return route;
    } catch (e) {
      print("Error occurred: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              customerNo: widget.store.storeInfo.storeId,
              routeId: widget.routeId,
              route: widget.route,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(left: 10, top: 5, right: 2, bottom: 5),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${widget.store.storeInfo.name}",
                                style: Styles.black24(context),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "ที่อยู่: ${widget.store.storeInfo.address}",
                                style: Styles.black18(context),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "ประเภท: ${widget.store.storeInfo.typeName}",
                                style: Styles.black18(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
