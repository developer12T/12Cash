import 'dart:async';
import 'dart:convert';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/CalendarPicker%20copy.dart';
import 'package:_12sale_app/core/components/CalendarPicker.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/card/RouteAjustCard.dart';
import 'package:_12sale_app/core/components/card/StoreVisitCard.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchCustom.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/route/RouteVisit.dart';
import 'package:_12sale_app/data/models/route/StoreVisit.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:month_year_picker/month_year_picker.dart';

class AjustRoute2 extends StatefulWidget {
  const AjustRoute2({super.key});

  @override
  State<AjustRoute2> createState() => _AjustRoute2State();
}

class _AjustRoute2State extends State<AjustRoute2> {
  bool isEdit = true;
  RouteStore selectedRoute = RouteStore(route: "R01");
  String _isSelected = '1';
  bool _loadingAllStore = true;
  List<ListStore> listStore = [];
  bool isLoading = true;
  List<RouteVisit> routeVisits = [];
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";
  DateTime? _selectedDate;

  @override
  initState() {
    super.initState();
    _getRouteVisit();
    _getListStore();
  }

  Future<void> _getRouteVisit() async {
    ApiService apiService = ApiService();
    await apiService.init();

    var response = await apiService.request(
      endpoint: 'api/cash/route/getRoute?area=${User.area}&period=${period}',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      // print("getRoute: ${response.data['data']}");
      if (mounted) {
        setState(() {
          routeVisits = data.map((item) => RouteVisit.fromJson(item)).toList();
        });
      }
      Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
      print("getRoute: $routeVisits");
    }
  }

  Future<void> _updateRouteStore(
    String storeId,
    String fromRoute,
    String toRoute,
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
            "fromRoute": "${fromRoute}",
            "toRoute": "${toRoute}",
            "changedBy": "${User.username}",
            "changedDate": "${DateTime.now().toIso8601String()}",
            "status": "0",
            "approvedBy": "",
            "approvedDate": ""
          },
        );

        if (response.statusCode == 200) {
          print("statusCode: $response.statusCode");
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

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

  Future<void> _getListStore() async {
    ApiService apiService = ApiService();
    await apiService.init();
    String routeId = "${period}${User.area}${selectedRoute.route}";

    var response = await apiService.request(
      endpoint:
          'api/cash/route/getRoute?area=${User.area}&period=${period}&routeId=${routeId}',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'][0]['listStore'];
      final List<dynamic> dataStore = response.data['data'];
      print("getRoute: ${response.data['data']}");
      if (mounted) {
        setState(() {
          listStore = data.map((item) => ListStore.fromJson(item)).toList();
          // storeVisit =
          //     data.isNotEmpty ? StoreVisit.fromJson(dataStore[0]) : null;
        });
      }
      Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _loadingAllStore = false;
          });
        }
      });

      print("listStore: ${data.length}");
    }
  }

  @override
  Widget build(BuildContext context) {
    String routeId = "${period}${User.area}${selectedRoute.route}";
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(
          title: "ปรับรูท ",
          icon: Icons.route_outlined,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      showMonthPicker(
                        context: context,
                        initialDate: DateTime.now(),

                        firstDate: DateTime(2025),
                        lastDate: DateTime(2026),
                        // headerTitle: Text(
                        //   'กรุณาเลือกวันที่',
                        //   style: Styles.white24(context),
                        // ),

                        monthPickerDialogSettings: MonthPickerDialogSettings(
                          headerSettings: PickerHeaderSettings(
                            headerBackgroundColor: Styles.primaryColor,
                            headerCurrentPageTextStyle: Styles.white18(context),
                            headerSelectedIntervalTextStyle:
                                Styles.white24(context),
                          ),
                          dialogSettings: PickerDialogSettings(
                            dialogRoundedCornersRadius: 16,
                            customWidth: screenWidth * 0.7,
                            customHeight: screenWidth * 0.5,
                          ),
                          dateButtonsSettings: PickerDateButtonsSettings(
                            selectedMonthBackgroundColor: Styles.primaryColor,
                            monthTextStyle: Styles.black18(context),
                            selectedDateRadius: 20,
                          ),
                          actionBarSettings: PickerActionBarSettings(
                            confirmWidget: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'ยืนยัน',
                                style: Styles.black18(context),
                              ),
                            ),
                            cancelWidget: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'ยกเลิก',
                                style: Styles.black18(context),
                              ),
                            ),
                          ),
                        ),
                      ).then(
                        (value) {
                          if (value != null) {
                            String formattedMonth =
                                value.month.toString().padLeft(2, '0');
                            setState(() {
                              _selectedDate =
                                  DateTime(value.year, value.month, 1);
                              period = "${value.year}${formattedMonth}";
                            });

                            print("periodTEST $period}");
                            _getRouteVisit();
                          }
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Styles.primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 8),
                          Text(
                            _selectedDate != null
                                ? "${_selectedDate!.month}/${_selectedDate!.year}"
                                : "กรุณาเลือกวันที่",
                            style: Styles.black18(context),
                          ),
                          const Icon(Icons.calendar_today,
                              size: 20, color: Styles.primaryColor),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () {},
                      child: BoxShadowCustom(
                        borderColor: Colors.green[600]!,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Styles.success),
                          child: Row(
                            children: [
                              Icon(
                                Icons.save_outlined,
                                size: 40,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "ยืนยัน",
                                style: Styles.white18(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: BoxShadowCustom(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // if (_isSelected != false) {
                              //   setState(() {
                              //     _isSelected = !_isSelected;
                              //   });
                              // }
                              // _getStoreDataAll();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 16, // Add elevation for shadow
                              shadowColor: Colors.black.withOpacity(
                                  0.5), // Shadow color with opacity
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              backgroundColor: _isSelected == '1'
                                  ? Colors.white
                                  : Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "ปรับ/เพิ่ม",
                              style: Styles.headerBlack32(context),
                            ),
                          ),
                        ),
                        // Expanded(
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       // if (_isSelected != false) {
                        //       //   setState(() {
                        //       //     _isSelected = !_isSelected;
                        //       //   });
                        //       // }
                        //       // _getStoreDataAll();
                        //     },
                        //     style: ElevatedButton.styleFrom(
                        //       elevation: 16, // Add elevation for shadow
                        //       shadowColor: Colors.black.withOpacity(
                        //           0.5), // Shadow color with opacity
                        //       padding: const EdgeInsets.symmetric(
                        //         vertical: 16,
                        //       ),
                        //       backgroundColor: _isSelected == '1'
                        //           ? Colors.white
                        //           : Colors.grey[300],
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(8),
                        //       ),
                        //     ),
                        //     child: Text(
                        //       "เพิ่ม",
                        //       style: Styles.headerBlack32(context),
                        //     ),
                        //   ),
                        // ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // if (_isSelected != false) {
                              //   setState(() {
                              //     _isSelected = !_isSelected;
                              //   });
                              // }
                              // _getStoreDataAll();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 16, // Add elevation for shadow
                              shadowColor: Colors.black.withOpacity(
                                  0.5), // Shadow color with opacity
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              backgroundColor: _isSelected == '1'
                                  ? Colors.white
                                  : Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "ประวัติ",
                              style: Styles.headerBlack32(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                left: 16,
                              ),
                              width: 100,
                              height: 75,
                              child: DropdownSearchCustom<RouteStore>(
                                initialSelectedValue: RouteStore(
                                  route: 'R01',
                                ),
                                label: "ปรับรูท ",
                                titleText: "ปรับรูท ",
                                // label: "ปรับรูท R${widget.route}",
                                // titleText: "ปรับรูท R${widget.route}",
                                fetchItems: (filter) => getRoutes(filter),
                                onChanged: (RouteStore? selected) async {
                                  if (selected != null) {
                                    selectedRoute =
                                        RouteStore(route: selected.route);
                                    _loadingAllStore = true;
                                    _getListStore();
                                  }
                                },
                                itemAsString: (RouteStore data) => data.route,
                                itemBuilder: (context, item, isSelected) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          " ${item.route}",
                                          style: Styles.black18(context),
                                        ),
                                        selected: isSelected,
                                      ),
                                      Divider(
                                        color: Colors.grey[
                                            200], // Color of the divider line
                                        thickness: 1, // Thickness of the line
                                        indent:
                                            16, // Left padding for the divider line
                                        endIndent:
                                            16, // Right padding for the divider line
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Icon(
                                isEdit ? Icons.arrow_right_alt : Icons.add,
                                size: 60,
                                color: Styles.primaryColor,
                                // textDirection:,
                              ),
                            ),
                            Container(
                              // margin: EdgeInsets.symmetric(vertical: 8),
                              width: 100,
                              height: 75,
                              child: DropdownSearchCustom<RouteStore>(
                                label: "ปรับรูท ",
                                titleText: "ปรับรูท ",
                                // label: "ปรับรูท R${widget.route}",
                                // titleText: "ปรับรูท R${widget.route}",
                                fetchItems: (filter) => getRoutes(filter),
                                onChanged: (RouteStore? selected) async {
                                  // if (selected != null) {
                                  //   toRoute = selected.route;
                                  // }
                                },
                                itemAsString: (RouteStore data) => data.route,
                                itemBuilder: (context, item, isSelected) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          " ${item.route}",
                                          style: Styles.black18(context),
                                        ),
                                        selected: isSelected,
                                      ),
                                      Divider(
                                        color: Colors.grey[
                                            200], // Color of the divider line
                                        thickness: 1, // Thickness of the line
                                        indent:
                                            16, // Left padding for the divider line
                                        endIndent:
                                            16, // Right padding for the divider line
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 130,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: GestureDetector(
                                  onTap: () {
                                    if (!isEdit) {
                                      setState(() {
                                        isEdit = true;
                                      });
                                    }
                                  },
                                  child: BoxShadowCustom(
                                    borderColor: Colors.teal,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color:
                                            isEdit ? Colors.teal : Colors.grey,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.edit_location_alt_outlined,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "ปรับ",
                                            style: Styles.white18(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 130,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: GestureDetector(
                                  onTap: () {
                                    if (isEdit) {
                                      setState(() {
                                        isEdit = false;
                                      });
                                    }
                                  },
                                  child: BoxShadowCustom(
                                    borderColor:
                                        isEdit ? Colors.cyan : Colors.grey,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color:
                                            isEdit ? Colors.grey : Colors.cyan,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_location_alt_outlined,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "เพิ่ม",
                                            style: Styles.white18(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LoadingSkeletonizer(
                        loading: _loadingAllStore,
                        child: ListView.builder(
                          itemCount: listStore.length,
                          itemBuilder: (context, index) {
                            return StoreAjustRouteCard(
                              index: index,
                              store: listStore[index],
                              route: selectedRoute.route,
                              routeId: routeId,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
