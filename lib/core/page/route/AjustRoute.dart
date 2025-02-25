import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/CalendarPicker.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/card/route/RouteAjustCard.dart';
import 'package:_12sale_app/core/components/card/route/StoreVisitCard.dart';
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
import 'package:toastification/toastification.dart';

class AjustRoute extends StatefulWidget {
  const AjustRoute({super.key});

  @override
  State<AjustRoute> createState() => _AjustRouteState();
}

class _AjustRouteState extends State<AjustRoute> {
  bool isLoading = true;
  bool isEdit = true;
  bool _loadingAllStore = true;
  List<RouteVisit> routeVisits = [];
  List<ListStore> listStore = [];
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";
  DateTime? _selectedDate;
  RouteStore selectedRoute = RouteStore(route: "R01");
  RouteStore selectedToRoute = RouteStore(route: "R02");
  List<bool> checkedItems = [];
  List<ListStore> toStore = [];
  List<String> toStoreString = [];

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
    String type,
  ) async {
    try {
      AllAlert.acceptAlert(
        context,
        () async {
          print("fromRoute: ${selectedRoute.route}");
          print("toRoute: ${selectedToRoute.route}");
          print("listStore: ${toStoreString}");
          if (toStoreString.isNotEmpty) {
            ApiService apiService = ApiService();
            await apiService.init();
            var response = await apiService.request(
              endpoint: 'api/cash/route/change',
              method: 'POST',
              body: {
                "area": "${User.area}",
                "period": "${period}",
                "type": "${type}",
                "fromRoute": "${selectedRoute.route}",
                "toRoute": "${selectedToRoute.route}",
                "changedBy": "${User.username}",
                "listStore": toStoreString,
              },
            );

            if (response.statusCode == 201 || response.statusCode == 200) {
              print("statusCode: $response.statusCode");
              toastification.show(
                autoCloseDuration: const Duration(seconds: 5),
                context: context,
                primaryColor: Colors.green[600],
                type: ToastificationType.success,
                style: ToastificationStyle.flatColored,
                title: Text(
                  "บันทึกข้อมูลสำเร็จ",
                  style: Styles.green18(context),
                ),
              );
              setState(
                () {
                  toStore.clear();
                  toStoreString.clear();
                  checkedItems =
                      List.generate(listStore.length, (index) => false);
                },
              );
            }
          } else {
            toastification.show(
              autoCloseDuration: const Duration(seconds: 5),
              context: context,
              primaryColor: Colors.red,
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              title: Text(
                "คุณยังไม่ได้เลือกร้านค้า",
                style: Styles.red18(context),
              ),
            );
          }
        },
      );
    } catch (e) {
      toastification.show(
        autoCloseDuration: const Duration(seconds: 5),
        context: context,
        primaryColor: Colors.red,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(
          "$e",
          style: Styles.red18(context),
        ),
      );
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

      print("getRoute: ${response.data['data']}");
      if (mounted) {
        setState(() {
          listStore = data.map((item) => ListStore.fromJson(item)).toList();
          checkedItems = List.generate(listStore.length, (index) => false);
          toStore.clear();
          toStoreString.clear();
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
    double screenWidth = MediaQuery.of(context).size.width;
    String routeId = "${period}${User.area}${selectedRoute.route}";

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppbarCustom(
            title: "ตัวอย่างการปรับรูท ",
            icon: Icons.route_outlined,
          ),
        ),
        body: Container(
          // color: Colors.white,
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
                          monthPickerDialogSettings: MonthPickerDialogSettings(
                            headerSettings: PickerHeaderSettings(
                              headerBackgroundColor: Styles.primaryColor,
                              headerCurrentPageTextStyle:
                                  Styles.white18(context),
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
                                  : "${DateFormat('MM').format(DateTime.now())}/${DateTime.now().year}",
                              style: Styles.black18(context),
                            ),
                            const Icon(Icons.calendar_today,
                                size: 20, color: Styles.primaryColor),
                          ],
                        ),
                      ),
                    ),
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
                                if (toStore.isNotEmpty) {
                                  AllAlert.changeAddRouteAlert(
                                    context,
                                    () {
                                      setState(() {
                                        isEdit = true;
                                        toStore.clear();
                                        toStoreString.clear();
                                        checkedItems = List.generate(
                                            listStore.length, (index) => false);
                                      });
                                    },
                                  );
                                } else {
                                  setState(() {
                                    isEdit = true;
                                    checkedItems = List.generate(
                                        listStore.length, (index) => false);
                                  });
                                }
                              }
                            },
                            child: BoxShadowCustom(
                              borderColor: isEdit ? Colors.amber : Colors.grey,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: isEdit ? Colors.amber : Colors.grey,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                if (toStore.isNotEmpty) {
                                  AllAlert.changeAjustRouteAlert(
                                    context,
                                    () {
                                      setState(() {
                                        isEdit = false;
                                        toStore.clear();
                                        toStoreString.clear();
                                        checkedItems = List.generate(
                                            listStore.length, (index) => false);
                                      });
                                    },
                                  );
                                } else {
                                  setState(() {
                                    isEdit = false;
                                    checkedItems = List.generate(
                                        listStore.length, (index) => false);
                                  });
                                }
                              }
                            },
                            child: BoxShadowCustom(
                              borderColor:
                                  isEdit ? Colors.grey : Styles.primaryColor,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: isEdit
                                        ? Colors.grey
                                        : Styles.primaryColor),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
              Expanded(
                child: LoadingSkeletonizer(
                  loading: isLoading,
                  child: BoxShadowCustom(
                      child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadiusDirectional.only(
                            topEnd: Radius.circular(8),
                            topStart: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                                child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    "เลือกร้านค้าที่จะ${isEdit ? "ย้าย " : "เพิ่ม"}",
                                    style: Styles.black24(context),
                                    // style: Styles.headerBlack20(context),
                                  ),
                                )
                              ],
                            )),
                            Container(
                              // color: Colors.white,
                              padding: EdgeInsets.only(top: 8),
                              margin: EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              width: 110,
                              height: 75,
                              child: DropdownSearchCustom<RouteStore>(
                                initialSelectedValue: RouteStore(
                                  route: 'R01',
                                ),
                                label: "เลือกรูท ",
                                titleText: "เลือกรูท ",
                                filterFn: (RouteStore product, String filter) {
                                  return product.route != "R" &&
                                      product.route
                                          .toLowerCase()
                                          .contains(filter.toLowerCase());
                                },
                                fetchItems: (filter) => getRoutes(filter),
                                onChanged: (RouteStore? selected) async {
                                  if (selected != null) {
                                    selectedRoute =
                                        RouteStore(route: selected.route);
                                    _loadingAllStore = true;
                                    _getListStore();
                                    if (selected.route ==
                                        selectedToRoute.route) {
                                      toastification.show(
                                        autoCloseDuration:
                                            const Duration(seconds: 5),
                                        context: context,
                                        primaryColor: Colors.red,
                                        type: ToastificationType.error,
                                        style: ToastificationStyle.flatColored,
                                        title: Text(
                                          "ไม่สามารถเลือกรูทเดียวกันได้",
                                          style: Styles.black18(context),
                                        ),
                                      );
                                    }

                                    // if (toStore.isNotEmpty) {
                                    //   AllAlert.changeAjustRouteAlert(
                                    //     context,
                                    //     () {
                                    //       setState(() {
                                    //         toStore.clear();
                                    //         toStoreString.clear();
                                    //         checkedItems = List.generate(
                                    //             listStore.length,
                                    //             (index) => false);
                                    //       });
                                    //     },
                                    //   );
                                    // } else {
                                    //   setState(() {
                                    //     checkedItems = List.generate(
                                    //         listStore.length, (index) => false);
                                    //   });
                                    // }
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
                            Container(
                              width: 130,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: GestureDetector(
                                  onTap: () {
                                    if (selectedRoute.route !=
                                        selectedToRoute.route) {
                                      if (isEdit) {
                                        _updateRouteStore('edit');
                                      } else {
                                        _updateRouteStore('add');
                                      }
                                    } else {
                                      toastification.show(
                                        autoCloseDuration:
                                            const Duration(seconds: 5),
                                        context: context,
                                        primaryColor: Colors.red,
                                        type: ToastificationType.error,
                                        style: ToastificationStyle.flatColored,
                                        title: Text(
                                          "ไม่สามารถเลือกรูทเดียวกันได้",
                                          style: Styles.black18(context),
                                        ),
                                      );
                                    }
                                  },
                                  child: BoxShadowCustom(
                                    // color: Styles.success,
                                    borderColor: Styles.success!,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.green[600],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(height: 35),
                                          Text(
                                            "ขออนุมัติ",
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
                      ),
                      Expanded(
                        child: LoadingSkeletonizer(
                          loading: _loadingAllStore,
                          child: ListView.builder(
                            itemCount: listStore.length,
                            itemBuilder: (context, index) {
                              return _buildRouteFrom(
                                listStore[index],
                                index,
                                routeId,
                                selectedRoute.route,
                                checkedItems[index],
                                (bool value) {
                                  setState(() {
                                    checkedItems[index] = value; // Update state
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  )),
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: LoadingSkeletonizer(
                  loading: isLoading,
                  child: BoxShadowCustom(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadiusDirectional.only(
                              topEnd: Radius.circular(8),
                              topStart: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.store,
                                            color: Styles.primaryColor,
                                            size: 50,
                                          ),
                                          Text(
                                            " ${toStore.length} ร้าน",
                                            style: Styles.black24(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${isEdit ? "ย้ายไปยังรูท " : "เพิ่มไปยังรูท "}",
                                          style: Styles.black24(context),
                                        ),
                                        Icon(
                                          isEdit
                                              ? Icons
                                                  .arrow_circle_right_outlined
                                              : Icons.add_circle_outline,
                                          color: Styles.primaryColor,
                                          size: 50,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                // color: Colors.white,
                                padding: EdgeInsets.only(top: 8),
                                margin: EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                ),
                                width: 100,
                                height: 75,
                                child: DropdownSearchCustom<RouteStore>(
                                  initialSelectedValue: RouteStore(
                                    route: 'R02',
                                  ),
                                  label: "เลือกรูท",
                                  titleText: "เลือกรูท",
                                  // label: "ปรับรูท R${widget.route}",
                                  // titleText: "ปรับรูท R${widget.route}",
                                  fetchItems: (filter) => getRoutes(filter),
                                  onChanged: (RouteStore? selected) async {
                                    if (selected != null) {
                                      selectedToRoute =
                                          RouteStore(route: selected.route);
                                      if (selected.route ==
                                          selectedRoute.route) {
                                        toastification.show(
                                          autoCloseDuration:
                                              const Duration(seconds: 5),
                                          context: context,
                                          primaryColor: Colors.red,
                                          type: ToastificationType.error,
                                          style:
                                              ToastificationStyle.flatColored,
                                          title: Text(
                                            "ไม่สามารถเลือกรูทเดียวกันได้",
                                            style: Styles.black18(context),
                                          ),
                                        );
                                      }
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
                            ],
                          ),
                        ),
                        Expanded(
                          child: LoadingSkeletonizer(
                            loading: _loadingAllStore,
                            child: ListView.builder(
                              itemCount: toStore.length,
                              itemBuilder: (context, index) {
                                return _buildRouteTo(
                                  toStore[index],
                                  index,
                                  routeId,
                                  selectedRoute.route,
                                  checkedItems[index],
                                  (bool value) {
                                    setState(() {
                                      checkedItems[index] =
                                          value; // Update state
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteFrom(
    ListStore store,
    int index,
    String routeId,
    String route,
    bool checked,
    Function(bool) onCheckedChanged, // Callback to update parent state
  ) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Styles.primaryColor;
      }
      return Colors.grey;
    }

    return ListTile(
      leading: Text(
        "${index + 1}",
        style: Styles.black18(context),
      ),
      trailing: Transform.scale(
        scale: 1.5,
        child: Checkbox(
          splashRadius: 20,
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return Styles.primaryColor; // Checked state background color
            }
            return Colors.white; // Unchecked state background color
          }),
          checkColor: Colors.white, // Checkmark color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // Rounded corners
          ),
          // fillColor: WidgetStateProperty.resolveWith(getColor),
          value: checked,
          onChanged: (bool? value) {
            onCheckedChanged(value!); // Call parent function to update state
            toStore.add(store);
            toStoreString.add(store.storeInfo.storeId);
            if (checked == true &&
                toStore.any((item) =>
                    item.storeInfo.storeId == store.storeInfo.storeId)) {
              toStore.removeWhere(
                  (item) => item.storeInfo.storeId == store.storeInfo.storeId);
              toStoreString
                  .removeWhere((item) => item == store.storeInfo.storeId);
            }
          },
        ),
      ),
      title: Text(
        store.storeInfo.name,
        // style: Styles.black24(context),
        style: Styles.black20(context),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   store.storeInfo.storeId,
          //   style: Styles.black18(context),
          // ),
          Text(
            store.storeInfo.address,
            style: Styles.black18(context),
          ),
          Text(
            store.storeInfo.typeName,
            style: Styles.black18(context),
          ),
          Divider(
            color: Colors.grey[200], // Color of the divider line
            thickness: 1, // Thickness of the line
            // indent: 16, // Left padding for the divider line
          )
        ],
      ),
      // trailing: IconButton(
      //   icon: const Icon(Icons.delete, color: Colors.red),
      //   onPressed: () {},
      // ),
    );
  }

  Widget _buildRouteTo(
    ListStore store,
    int index,
    String routeId,
    String route,
    bool checked,
    Function(bool) onCheckedChanged, // Callback to update parent state
  ) {
    return ListTile(
      leading: Text(
        "${index + 1}",
        style: Styles.black24(context),
      ),
      title: Text(
        store.storeInfo.name,
        style: Styles.black24(context),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            store.storeInfo.address,
            style: Styles.black18(context),
          ),
          Text(
            store.storeInfo.typeName,
            style: Styles.black18(context),
          ),
          Divider(
            color: Colors.grey[200], // Color of the divider line
            thickness: 1, // Thickness of the line
          )
        ],
      ),
    );
  }
}
