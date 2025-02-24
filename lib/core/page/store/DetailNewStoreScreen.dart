import 'dart:convert';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/button/IconButtonWithLabel.dart';
import 'package:_12sale_app/core/components/button/MenuButton.dart';
import 'package:_12sale_app/core/components/button/ShowPhotoButton.dart';
import 'package:_12sale_app/core/components/chart/CircularChart.dart';
import 'package:_12sale_app/core/components/chart/ItemSummarize.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchCustom.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/dashboard/DashboardScreen.dart';
import 'package:_12sale_app/core/page/order/OrderScreen.dart';
import 'package:_12sale_app/core/page/store/ProcessTimelineScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toastification/toastification.dart';

class DetailNewStoreScreen extends StatefulWidget {
  String customerNo;
  String customerName;
  Store store;
  RouteStore initialSelectedRoute;

  DetailNewStoreScreen({
    super.key,
    required this.customerNo,
    required this.customerName,
    required this.store,
    required this.initialSelectedRoute,
  });

  @override
  State<DetailNewStoreScreen> createState() => _DetailNewStoreScreenState();
}

class _DetailNewStoreScreenState extends State<DetailNewStoreScreen> {
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
            style: Styles.black18(context),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen(index: 2)),
        );
      } else {
        toastification.show(
          autoCloseDuration: Duration(seconds: 3),
          context: context,
          primaryColor: Colors.red,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: Text(
            "เกิดข้อผิดพลาด",
            style: Styles.black18(context),
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
          style: Styles.black18(context),
        ),
      );
    }
  }

  Future<void> _editStore() async {
    Dio dio = Dio();

    final String apiUrl2 =
        "${ApiService.apiHost}/api/cash/store/editStore/${widget.store.storeId}";

    Map<String, dynamic> jsonData = {
      "name": "${storeNameController.text}",
      "taxId": "",
      "tel": "${storePhoneController.text}",
      "route": "${selectedRoute}",
      "type": "",
      "typeName": "",
      "address": "",
      "district": "",
      "subDistrict": "",
      "province": "",
      "provinceCode": "",
      "postCode": "",
      "note": "${storeNoteController.text}",
      "zone": "",
      "area": "",
      "latitude": "",
      "longtitude": "",
      "lineId": "${storeLineIdController.text}"
    };

    try {
      final response = await dio.patch(
        apiUrl2,
        data: jsonData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      if (response.statusCode == 200) {
        print(response.data['message']);
        print(response.data);

        toastification.show(
          autoCloseDuration: Duration(seconds: 3),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "แก้ไขข้อมูลเรียบร้อย",
            style: Styles.black18(context),
          ),
        );
      } else {
        toastification.show(
          autoCloseDuration: Duration(seconds: 3),
          context: context,
          primaryColor: Colors.red,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: Text(
            "เกิดข้อผิดพลาด ",
            style: Styles.black18(context),
          ),
        );
      }
      print(response);
    } catch (e) {
      print(e);
      toastification.show(
        autoCloseDuration: Duration(seconds: 3),
        context: context,
        primaryColor: Colors.red,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(
          "เกิดข้อผิดพลาด",
          style: Styles.black18(context),
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
      // floatingActionButton: SizedBox(
      //   width: 100, // Set the width of the button
      //   height: screenWidth / 8, // Set the height of the button
      //   child: AddStoreButton(
      //     icon: Icons.add,
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => ProcessTimelinePage(),
      //         ),
      //       );
      //     },
      //   ),
      // ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                style: Styles.black24(context),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Styles.skybluePastel,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(8),
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16),
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: Text(
                                                  'ใหม่',
                                                  style:
                                                      Styles.black18(context),
                                                ),
                                              )
                                            ],
                                          ),
                                          Text(
                                            '${'route.detail_screen.store_id'.tr()} : ${widget.customerNo}',
                                            style: Styles.black18(context),
                                          ),
                                          Text(
                                            'เลขประจำตัวผู้เสียภาษี : ${widget.store.taxId}',
                                            style: Styles.black18(context),
                                          ),
                                          Text(
                                            'เบอร์โทรศัพท์ : ${storePhoneController.text}',
                                            style: Styles.black18(context),
                                          ),
                                          Text(
                                            'รูท : ${widget.store.route}',
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
                                          icon: Icons.store_rounded,
                                          label: "เช็คอิน",
                                          color: Styles.bluePastel,
                                          onPressed: () {
                                            fetchLocation();
                                            Alert(
                                              context: context,
                                              title:
                                                  "store.processtimeline_screen.alert.title"
                                                      .tr(),
                                              style: AlertStyle(
                                                animationType:
                                                    AnimationType.grow,
                                                isCloseButton: true,
                                                isOverlayTapDismiss: false,
                                                descStyle:
                                                    Styles.black18(context),
                                                descTextAlign: TextAlign.start,
                                                animationDuration:
                                                    const Duration(
                                                        milliseconds: 400),
                                                alertBorder:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          22.0),
                                                  side: const BorderSide(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                titleStyle:
                                                    Styles.headerBlack32(
                                                        context),
                                                alertAlignment:
                                                    Alignment.center,
                                              ),
                                              desc:
                                                  "คุณต้องการยืนยันการเช็คอินร้านค้าใช่หรือไม่ ?",
                                              buttons: [
                                                DialogButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  color: Styles.failTextColor,
                                                  child: Text(
                                                    "store.processtimeline_screen.alert.cancel"
                                                        .tr(),
                                                    style:
                                                        Styles.black18(context),
                                                  ),
                                                ),
                                                DialogButton(
                                                  onPressed: () {
                                                    _checkin();
                                                  },
                                                  color:
                                                      Styles.successButtonColor,
                                                  child: Text(
                                                    "store.processtimeline_screen.alert.submit"
                                                        .tr(),
                                                    style:
                                                        Styles.black18(context),
                                                  ),
                                                )
                                              ],
                                            ).show();
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
                                          icon: Icons.add_shopping_cart_rounded,
                                          label: "ขาย",
                                          // color: Colors.teal,
                                          color: Styles.grey,
                                          onPressed: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         Orderscreen(
                                            //             customerNo:
                                            //                 widget.customerNo,
                                            //             customerName:
                                            //                 widget.customerName,
                                            //             status: widget
                                            //                 .store.status),
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
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.bar_chart_outlined,
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
                                  //   padding: EdgeInsets.symmetric(vertical: 35),
                                  //   child: CustomPaint(
                                  //     size: Size(200, 200),
                                  //     painter: CircularChartPainter(
                                  //         completionPercentage:
                                  //             completionPercentage),
                                  //     child: Center(
                                  //       child: Column(
                                  //         mainAxisSize: MainAxisSize.min,
                                  //         children: [
                                  //           Text(
                                  //             "${((completionPercentage * 100) / 360).toStringAsFixed(2)}%",
                                  //             style: Styles.black24(context),
                                  //           ),
                                  //           Text(
                                  //             "150,000 ฿",
                                  //             style: Styles.black24(context),
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
                                      //           style: Styles.black24(context),
                                      //         ),
                                      //         Row(
                                      //           children: [
                                      //             FaIcon(
                                      //                 FontAwesomeIcons
                                      //                     .caretDown,
                                      //                 color:
                                      //                     Styles.failTextColor),
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
                                                style: Styles.black24(context),
                                              ),
                                              Row(
                                                children: [
                                                  FaIcon(
                                                      FontAwesomeIcons
                                                          .caretDown,
                                                      color:
                                                          Styles.failTextColor),
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
                        SizedBox(height: 20),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black.withOpacity(
                        //             0.2), // Shadow color with transparency
                        //         spreadRadius: 2, // Spread of the shadow
                        //         blurRadius: 8, // Blur radius of the shadow
                        //         offset: const Offset(0,
                        //             4), // Offset of the shadow (horizontal, vertical)
                        //       ),
                        //     ],
                        //     // border: Border.all(color: Colors.grey),
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(16.0),
                        //     child: Column(
                        //       children: [
                        //         Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Row(
                        //               children: [
                        //                 const Icon(
                        //                   Icons.store,
                        //                   size: 40,
                        //                 ),
                        //                 const SizedBox(width: 8),
                        //                 Text(
                        //                   "แก้ไขข้อมูลร้านค้า",
                        //                   style: Styles.black24(context),
                        //                 ),
                        //               ],
                        //             ),
                        //             Row(
                        //               children: [
                        //                 // GestureDetector(
                        //                 //   onTap: () {
                        //                 //     fetchLocation();
                        //                 //     Alert(
                        //                 //       context: context,
                        //                 //       title:
                        //                 //           "store.processtimeline_screen.alert.title"
                        //                 //               .tr(),
                        //                 //       style: AlertStyle(
                        //                 //         animationType:
                        //                 //             AnimationType.grow,
                        //                 //         isCloseButton: true,
                        //                 //         isOverlayTapDismiss: false,
                        //                 //         descStyle:
                        //                 //             Styles.black18(context),
                        //                 //         descTextAlign: TextAlign.start,
                        //                 //         animationDuration:
                        //                 //             const Duration(
                        //                 //                 milliseconds: 400),
                        //                 //         alertBorder:
                        //                 //             RoundedRectangleBorder(
                        //                 //           borderRadius:
                        //                 //               BorderRadius.circular(
                        //                 //                   22.0),
                        //                 //           side: const BorderSide(
                        //                 //             color: Colors.grey,
                        //                 //           ),
                        //                 //         ),
                        //                 //         titleStyle:
                        //                 //             Styles.headerBlack32(
                        //                 //                 context),
                        //                 //         alertAlignment:
                        //                 //             Alignment.center,
                        //                 //       ),
                        //                 //       desc:
                        //                 //           "คุณต้องการยืนยันการเช็คอินร้านค้าใช่หรือไม่ ?",
                        //                 //       buttons: [
                        //                 //         DialogButton(
                        //                 //           onPressed: () =>
                        //                 //               Navigator.pop(context),
                        //                 //           color: Styles.failTextColor,
                        //                 //           child: Text(
                        //                 //             "store.processtimeline_screen.alert.cancel"
                        //                 //                 .tr(),
                        //                 //             style:
                        //                 //                 Styles.white18(context),
                        //                 //           ),
                        //                 //         ),
                        //                 //         DialogButton(
                        //                 //           onPressed: () {
                        //                 //             _checkin();
                        //                 //           },
                        //                 //           color:
                        //                 //               Styles.successButtonColor,
                        //                 //           child: Text(
                        //                 //             "store.processtimeline_screen.alert.submit"
                        //                 //                 .tr(),
                        //                 //             style:
                        //                 //                 Styles.white18(context),
                        //                 //           ),
                        //                 //         )
                        //                 //       ],
                        //                 //     ).show();
                        //                 //   },
                        //                 //   child: BoxShadowCustom(
                        //                 //     child: Container(
                        //                 //       padding: const EdgeInsets.all(8),
                        //                 //       decoration: BoxDecoration(
                        //                 //           borderRadius:
                        //                 //               BorderRadius.circular(8),
                        //                 //           color: Styles
                        //                 //               .successButtonColor),
                        //                 //       child: Row(
                        //                 //         children: [
                        //                 //           const Icon(
                        //                 //             Icons.login,
                        //                 //             size: 40,
                        //                 //             color: Colors.white,
                        //                 //           ),
                        //                 //           const SizedBox(width: 8),
                        //                 //           Text(
                        //                 //             "เช็คอิน",
                        //                 //             style:
                        //                 //                 Styles.white18(context),
                        //                 //           ),
                        //                 //         ],
                        //                 //       ),
                        //                 //     ),
                        //                 //   ),
                        //                 // ),
                        //                 SizedBox(
                        //                   width: screenWidth / 40,
                        //                 ),
                        //                 GestureDetector(
                        //                   onTap: () {
                        //                     setState(() {
                        //                       onEdit =
                        //                           !onEdit; // Toggle the value of onEdit
                        //                     });
                        //                     if (onEdit) {
                        //                       _editStore();
                        //                     }
                        //                   },
                        //                   child: BoxShadowCustom(
                        //                     child: Container(
                        //                       padding: const EdgeInsets.all(8),
                        //                       decoration: BoxDecoration(
                        //                           borderRadius:
                        //                               BorderRadius.circular(8),
                        //                           color: onEdit
                        //                               ? Styles.primaryColor
                        //                               : Styles
                        //                                   .successButtonColor),
                        //                       child: Row(
                        //                         children: [
                        //                           Icon(
                        //                             onEdit
                        //                                 ? Icons.edit
                        //                                 : Icons.save_outlined,
                        //                             size: 40,
                        //                             color: Colors.white,
                        //                           ),
                        //                           const SizedBox(width: 8),
                        //                           Text(
                        //                             onEdit ? "แก้ไข" : "บันทึก",
                        //                             style:
                        //                                 Styles.white18(context),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             )
                        //           ],
                        //         ),
                        //         SizedBox(height: screenWidth / 37),
                        //         _buildCustomFormField(
                        //             'ชื่อร้านค้า',
                        //             storeNameController.text,
                        //             Icons.store,
                        //             storeNameController,
                        //             readOnly: onEdit),
                        //         _buildCustomFormField(
                        //             'เลขประจำตัวผู้เสียภาษี',
                        //             '${widget.store.taxId}',
                        //             Icons.person_outline,
                        //             storeTaxConroller),
                        //         Row(
                        //           children: [
                        //             Expanded(
                        //               child: _buildCustomFormField(
                        //                   max: 10,
                        //                   'โทรศัพท์',
                        //                   '${storePhoneController.text}',
                        //                   Icons.phone,
                        //                   storePhoneController,
                        //                   keypadType: TextInputType.number,
                        //                   readOnly: onEdit),
                        //             ),
                        //             const SizedBox(width: 16),
                        //             Expanded(
                        //               child: Padding(
                        //                 padding:
                        //                     const EdgeInsets.only(bottom: 16.0),
                        //                 child: Container(
                        //                   color: true
                        //                       ? Colors.grey[200]
                        //                       : Colors.white,
                        //                   child:
                        //                       DropdownSearchCustom<RouteStore>(
                        //                     enabled: true,
                        //                     initialSelectedValue: widget
                        //                                 .initialSelectedRoute
                        //                                 .route ==
                        //                             ''
                        //                         ? null
                        //                         : widget.initialSelectedRoute,
                        //                     label: "รูท",
                        //                     titleText: "รูท",
                        //                     icon: Icon(Icons.route_outlined),
                        //                     fetchItems: (filter) =>
                        //                         getRoutes(filter),
                        //                     onChanged:
                        //                         (RouteStore? selected) async {
                        //                       if (selected != null) {
                        //                         setState(() {
                        //                           widget.initialSelectedRoute =
                        //                               RouteStore(
                        //                                   route:
                        //                                       selected.route);
                        //                           selectedRoute =
                        //                               selected.route;
                        //                         });
                        //                       }
                        //                     },
                        //                     itemAsString: (RouteStore data) =>
                        //                         data.route,
                        //                     itemBuilder:
                        //                         (context, item, isSelected) {
                        //                       return Column(
                        //                         children: [
                        //                           ListTile(
                        //                             title: Text(
                        //                               " ${item.route}",
                        //                               style: Styles.black18(
                        //                                   context),
                        //                             ),
                        //                             selected: isSelected,
                        //                           ),
                        //                           Divider(
                        //                             color: Colors.grey[
                        //                                 200], // Color of the divider line
                        //                             thickness:
                        //                                 1, // Thickness of the line
                        //                             indent:
                        //                                 16, // Left padding for the divider line
                        //                             endIndent:
                        //                                 16, // Right padding for the divider line
                        //                           ),
                        //                         ],
                        //                       );
                        //                     },
                        //                   ),
                        //                 ),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //         _buildCustomFormField(
                        //             'ไลน์',
                        //             storeLineIdController.text,
                        //             Icons.alternate_email,
                        //             storeLineIdController,
                        //             readOnly: onEdit),
                        //         _buildCustomFormField(
                        //             'ประเภทร้านค้า',
                        //             '${widget.store.typeName}',
                        //             Icons.store_mall_directory,
                        //             storeShoptypeController),
                        //         _buildCustomFormField(
                        //             'หมายเหตุ',
                        //             storeNoteController.text,
                        //             Icons.note,
                        //             storeNoteController,
                        //             readOnly: onEdit),
                        //         // SizedBox(height: screenWidth / 37),
                        //         _buildCustomFormField(
                        //             'ที่อยู่',
                        //             '${widget.store.address} ${widget.store.province != 'กรุงเทพมหานคร' ? 'ต.' : 'แขวง'}${widget.store.subDistrict} ${widget.store.province != 'กรุงเทพมหานคร' ? 'อ.' : 'เขต'}${widget.store.district} ${widget.store.province != 'กรุงเทพมหานคร' ? 'จ.' : ''}${widget.store.province} ${widget.store.postCode}',
                        //             Icons.location_on_rounded,
                        //             storeAddressController),
                        //         Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceAround,
                        //           children: [
                        //             ShowPhotoButton(
                        //               checkNetwork: true,
                        //               label: "ร้านค้า",
                        //               icon: Icons.image_not_supported_outlined,
                        //               imagePath: widget
                        //                       .store.imageList.isNotEmpty
                        //                   ? (widget.store.imageList
                        //                           .where((image) =>
                        //                               image.type == "store")
                        //                           .isNotEmpty
                        //                       ? "${ApiService.apiHost}/image/stores/${User.area}/${widget.store.imageList.where((image) => image.type == "store").last.name}"
                        //                       : null)
                        //                   : null,
                        //             ),
                        //             ShowPhotoButton(
                        //               checkNetwork: true,
                        //               label: "ภ.พ.20",
                        //               icon: Icons.image_not_supported_outlined,
                        //               imagePath: widget
                        //                       .store.imageList.isNotEmpty
                        //                   ? (widget.store.imageList
                        //                           .where((image) =>
                        //                               image.type == "document")
                        //                           .isNotEmpty
                        //                       ? "${ApiService.apiHost}/image/stores/${User.area}/${widget.store.imageList.where((image) => image.type == "document").last.name}"
                        //                       : null)
                        //                   : null,
                        //             ),
                        //             ShowPhotoButton(
                        //               checkNetwork: true,
                        //               label: "สำเนาบัตรปปช.",
                        //               icon: Icons.image_not_supported_outlined,
                        //               imagePath: widget
                        //                       .store.imageList.isNotEmpty
                        //                   ? (widget.store.imageList
                        //                           .where((image) =>
                        //                               image.type == "idCard")
                        //                           .isNotEmpty
                        //                       ? "${ApiService.apiHost}/image/stores/${User.area}/${widget.store.imageList.where((image) => image.type == "idCard").last.name}"
                        //                       : null)
                        //                   : null,
                        //             ),
                        //           ],
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenWidth / 37),
            ],
          ),
        );
      }),
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
