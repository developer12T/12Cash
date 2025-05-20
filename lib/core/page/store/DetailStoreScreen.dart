import 'dart:convert';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/button/MenuButton.dart';
import 'package:_12sale_app/core/components/chart/CircularChart.dart';
import 'package:_12sale_app/core/components/chart/ItemSummarize.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchCustom.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/dashboard/DashboardScreen.dart';
import 'package:_12sale_app/core/page/order/OrderINRouteScreen.dart';
import 'package:_12sale_app/core/page/store/EditStoreDataScreen.dart';
import 'package:_12sale_app/core/page/store/ProcessTimelineScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/route/DetailStoreVisit.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toastification/toastification.dart';

class DetailStoreScreen extends StatefulWidget {
  String customerNo;
  String customerName;
  Store store;
  RouteStore initialSelectedRoute;

  DetailStoreScreen({
    super.key,
    required this.customerNo,
    required this.customerName,
    required this.store,
    required this.initialSelectedRoute,
  });

  @override
  State<DetailStoreScreen> createState() => _DetailStoreScreenState();
}

class _DetailStoreScreenState extends State<DetailStoreScreen> {
  bool onEdit = true;
  late TextEditingController storeNameController;
  late TextEditingController storePhoneController;
  late TextEditingController storeLineIdController;
  late TextEditingController storeNoteController;
  late TextEditingController storeTaxConroller;
  late TextEditingController storeShoptypeController;
  late TextEditingController storeAddressController;

  String selectedRoute = "";

  final LocationService locationService = LocationService();
  String latitude = '';
  String longitude = '';
  String api_url = '${ApiService.apiHost}/api/cash/store/checkIn/';

  double completionPercentage = 220;

  @override
  initState() {
    super.initState();
    storeNameController = TextEditingController();
    storePhoneController = TextEditingController();
    storeLineIdController = TextEditingController();
    storeShoptypeController = TextEditingController();
    storeTaxConroller = TextEditingController();
    storeNoteController = TextEditingController();
    storeAddressController = TextEditingController();
    _setStoreName();
  }

  Future<void> _setStoreName() async {
    setState(() {
      storeNameController.text = widget.store.name;
      storePhoneController.text = widget.store.tel;
      storeLineIdController.text = widget.store.lineId;
      storeNoteController.text = widget.store.note;
    });
  }

  Future<void> _checkin() async {
    await fetchLocation();
    Dio dio = Dio();
    final String apiUrl =
        "${ApiService.apiHost}/api/cash/store/checkIn/${widget.store.storeId}";
    Map<String, dynamic> jsonData = {
      "latitude": latitude,
      "longtitude": longitude
    };
    print("API latitude ${latitude} longtitude ${longitude}");
    try {
      final response = await dio.post(
        apiUrl,
        data: jsonData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            'x-channel': 'cash',
          },
        ),
      );
      if (response.statusCode == 200) {
        // print(response.data['message']);
        // print(response.data);
        toastification.show(
          autoCloseDuration: Duration(seconds: 3),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "เช็คอินสําเร็จ",
            style: Styles.green18(context),
          ),
        );
        Navigator.pop(context);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomeScreen(index: 2)),
        // );
      } else {
        toastification.show(
          autoCloseDuration: Duration(seconds: 3),
          context: context,
          primaryColor: Colors.red,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: Text(
            "เกิดข้อผิดพลาด",
            style: Styles.red18(context),
          ),
        );
      }
    } catch (e) {
      toastification.show(
        autoCloseDuration: Duration(seconds: 3),
        context: context,
        primaryColor: Colors.red,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(
          "เกิดข้อผิดพลาด",
          style: Styles.red18(context),
        ),
      );
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

  Future<void> fetchLocation() async {
    try {
      // Initialize the location service
      await locationService.initialize();

      // Get latitude and longitude
      double? lat = await locationService.getLatitude();
      double? lon = await locationService.getLongitude();

      setState(() {
        latitude = lat?.toString() ?? "Unavailable";
        longitude = lon?.toString() ?? "Unavailable";
      });
      print("${latitude}, ${longitude}");
    } catch (e) {
      if (mounted) {
        setState(() {
          latitude = "Error fetching latitude";
          longitude = "Error fetching longitude";
        });
      }
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    storeNameController.dispose();
    storePhoneController.dispose();
    storeLineIdController.dispose();
    storeNoteController.dispose();
    storeTaxConroller.dispose();
    storeShoptypeController.dispose();
    storeAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
            title: " รายละเอียดร้านค้า",
            icon: Icons.store_mall_directory_rounded),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenWidth / 80),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          BoxShadowCustom(
                            // color: Styles.primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${widget.customerName}",
                                                  style:
                                                      Styles.black24(context),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              'รูท : ${widget.store.route}',
                                              style: Styles.black18(context),
                                            ),
                                            Text(
                                              '${'route.detail_screen.store_id'.tr()} : ${widget.customerNo}',
                                              style: Styles.black18(context),
                                            ),
                                            Text(
                                              'เลขผู้เสียภาษี : ${widget.store.taxId}',
                                              style: Styles.black18(context),
                                            ),
                                            Text(
                                              'เบอร์โทรศัพท์ : ${storePhoneController.text}',
                                              style: Styles.black18(context),
                                            ),
                                            Text(
                                              'ประเภทร้านค้า : ${widget.store.typeName}',
                                              style: Styles.black18(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${'route.detail_screen.store_address'.tr()} : ${widget.store.address} ${widget.store.subDistrict} ${widget.store.district} ${widget.store.province} ${widget.store.postCode}",
                                          style: Styles.black18(context),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Column(
                                        children: [
                                          MenuButton(
                                            icon: Icons.image,
                                            label: "รูปภาพ",
                                            // color: Colors.teal,
                                            color: Styles.grey,
                                            onPressed: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         EditStoreDataScreen(
                                              //             initialSelectedRoute: RouteStore(
                                              //                 route: widget
                                              //                     .initialSelectedRoute
                                              //                     .route),
                                              //             store: widget.store,
                                              //             customerNo:
                                              //                 widget.customerNo,
                                              //             customerName:
                                              //                 widget.customerName),
                                              //   ),
                                              // );
                                            },
                                          ),
                                          Text(
                                            'ยังไม่เปิดให้บริการ',
                                            style: Styles.black12(context),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          MenuButton(
                                            icon: Icons.edit_document,
                                            label: "แก้ไข",
                                            // color: Colors.teal,
                                            color: Styles.warning!,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditStoreDataScreen(
                                                          initialSelectedRoute:
                                                              RouteStore(
                                                                  route: widget
                                                                      .initialSelectedRoute
                                                                      .route),
                                                          store: widget.store,
                                                          customerNo:
                                                              widget.customerNo,
                                                          customerName: widget
                                                              .customerName),
                                                ),
                                              );
                                            },
                                          ),
                                          Text(
                                            '',
                                            style: Styles.black12(context),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          MenuButton(
                                            icon: Icons.store_rounded,
                                            label: "เช็คอิน",
                                            color: Styles.primaryColor,
                                            onPressed: () async {
                                              await fetchLocation();
                                              AllAlert.checkinAlert(
                                                  context, _checkin);
                                            },
                                          ),
                                          Text(
                                            '',
                                            style: Styles.black12(context),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          MenuButton(
                                            icon:
                                                Icons.add_shopping_cart_rounded,
                                            label: "ขาย",
                                            color: Styles.success!,
                                            // color: Styles.grey,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderINRouteScreen(
                                                    routeId: '',
                                                    storeDetail:
                                                        DetailStoreVisit(
                                                            id: '',
                                                            period: '',
                                                            area: '',
                                                            day: '',
                                                            listStore: [
                                                              ListStore(
                                                                  storeInfo: StoreInfo(
                                                                      id: '',
                                                                      storeId:
                                                                          widget
                                                                              .customerNo,
                                                                      name: widget
                                                                          .customerName,
                                                                      taxId: widget
                                                                          .store
                                                                          .taxId,
                                                                      tel: widget
                                                                          .store
                                                                          .tel,
                                                                      typeName: widget
                                                                          .store
                                                                          .typeName,
                                                                      address: widget
                                                                          .store
                                                                          .address),
                                                                  note: widget
                                                                      .store
                                                                      .note,
                                                                  status: widget
                                                                      .store
                                                                      .status,
                                                                  statusText:
                                                                      '',
                                                                  listOrder: [])
                                                            ],
                                                            storeAll: 0,
                                                            storePending: 0,
                                                            storeSell: 0,
                                                            storeNotSell: 0,
                                                            storeTotal: 0,
                                                            percentComplete: 0,
                                                            percentEffective: 0,
                                                            percentVisit: 0),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          Text(
                                            'ทดสอบระบบ',
                                            style: Styles.black12(context),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          BoxShadowCustom(
                              child: Column(
                            children: [],
                          )),
                          SizedBox(
                            height: 10,
                          ),
                          BoxShadowCustom(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.bar_chart,
                                        size: 40,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'ตัวอย่าง Dashboard',
                                        textAlign: TextAlign.start,
                                        style: Styles.black24(context),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Container(
                                    //   padding:
                                    //       EdgeInsets.symmetric(vertical: 35),
                                    //   child: CustomPaint(
                                    //     size: Size(200, 200),
                                    //     painter: CircularChartPainter(
                                    //         completionPercentage:
                                    //             completionPercentage),
                                    //     child: Center(
                                    //       child: Column(
                                    //         mainAxisSize: MainAxisSize.min,
                                    //         children: [
                                    //           // Text(
                                    //           //   "${((completionPercentage * 100) / 360).toStringAsFixed(2)}%",
                                    //           //   style: Styles.black18(context),
                                    //           // ),
                                    //           Row(
                                    //             children: [
                                    //               Text(
                                    //                 "ขาย : ",
                                    //                 style:
                                    //                     Styles.black18(context),
                                    //               ),
                                    //               Text(
                                    //                 "${((completionPercentage * 100) / 360).toStringAsFixed(2)}%",
                                    //                 style:
                                    //                     Styles.black18(context),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //           Row(
                                    //             children: [
                                    //               Text(
                                    //                 "คืน : ",
                                    //                 style:
                                    //                     Styles.black18(context),
                                    //               ),
                                    //               Text(
                                    //                 "${((140 * 100) / 360).toStringAsFixed(2)}%",
                                    //                 style:
                                    //                     Styles.black18(context),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "ยอดขาย",
                                                    style:
                                                        Styles.black24(context),
                                                  ),
                                                  Row(
                                                    children: [
                                                      FaIcon(
                                                          FontAwesomeIcons
                                                              .caretUp,
                                                          color: Styles
                                                              .successButtonColor),
                                                      Text(
                                                        " 10%",
                                                        style: Styles.green10(
                                                            context),
                                                      ),
                                                      Text(
                                                        " ${1500} บาท",
                                                        style: Styles.green24(
                                                            context),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "ยอดคืน",
                                                    style:
                                                        Styles.black24(context),
                                                  ),
                                                  Row(
                                                    children: [
                                                      FaIcon(
                                                          FontAwesomeIcons
                                                              .caretDown,
                                                          color: Styles
                                                              .failTextColor),
                                                      Text(
                                                        " 10%",
                                                        style: Styles.red10(
                                                            context),
                                                      ),
                                                      Text(
                                                        " ${1500} บาท",
                                                        style:
                                                            Styles.headerRed24(
                                                                context),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        // Container(
                                        //   decoration: BoxDecoration(
                                        //     color: Colors.grey[200],
                                        //     borderRadius:
                                        //         BorderRadius.circular(10),
                                        //   ),
                                        //   child: Padding(
                                        //     padding: EdgeInsets.all(8),
                                        //     child: Column(
                                        //       children: [
                                        //         Text(
                                        //           "เป้าหมาย",
                                        //           style:
                                        //               Styles.black24(context),
                                        //         ),
                                        //         Row(
                                        //           children: [
                                        //             FaIcon(
                                        //                 FontAwesomeIcons
                                        //                     .caretDown,
                                        //                 color: Styles
                                        //                     .failTextColor),
                                        //             Text(
                                        //               " 10%",
                                        //               style:
                                        //                   Styles.red10(context),
                                        //             ),
                                        //             Text(
                                        //               " ${1500} บาท",
                                        //               style: Styles.headerRed24(
                                        //                   context),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ),
                                        // ),
                                        // SizedBox(height: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "ยอดรวม",
                                                  style:
                                                      Styles.black24(context),
                                                ),
                                                Row(
                                                  children: [
                                                    FaIcon(
                                                        FontAwesomeIcons
                                                            .caretDown,
                                                        color: Styles
                                                            .failTextColor),
                                                    Text(
                                                      " 10%",
                                                      style:
                                                          Styles.red10(context),
                                                    ),
                                                    Text(
                                                      " ${1500} บาท",
                                                      style: Styles.headerRed24(
                                                          context),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          BoxShadowCustom(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.line_axis_outlined,
                                        size: 40,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'ตัวอย่างสรุปการขาย',
                                        textAlign: TextAlign.start,
                                        style: Styles.black24(context),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        // height: 400,
                                        // width: 500,
                                        child: ItemSummarize(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth / 37),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomFormField(String label, String value, IconData icon,
      TextEditingController? controller,
      {bool readOnly = true,
      TextInputType? keypadType = TextInputType.text,
      int? max = 36}) {
    if (controller != null) {
      controller.text = value; // Set initial value to the controller
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: readOnly ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          // focusNode: _focusNode,
          // maxLines: ,
          maxLength: max,
          keyboardType: keypadType,
          controller: controller,
          enabled: !readOnly,
          initialValue: controller != null ? null : '',
          style: Styles.black18(context),
          readOnly: readOnly, // Makes the TextFormField read-only
          decoration: InputDecoration(
            // fillColor: Colors.black,
            counterText: '',
            labelText: label,
            // hintStyle: Styles.kanit18,
            labelStyle: Styles.black18(context),
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
