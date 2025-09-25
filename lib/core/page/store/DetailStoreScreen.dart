import 'dart:convert';
import 'dart:io';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/camera/CameraExpand.dart';
import 'package:_12sale_app/core/components/card/dashboard/BudgetCard.dart';
import 'package:_12sale_app/core/components/chart/SummarybyMonth.dart';
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
import 'package:_12sale_app/core/page/store/OrderStoreScreen.dart';
import 'package:_12sale_app/core/page/store/ProcessTimelineScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/route/DetailStoreVisit.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";
  List<FlSpot> spots = [];
  bool isLoadingGraph = true;
  String date =
      "${DateFormat('dd').format(DateTime.now())}${DateFormat('MM').format(DateTime.now())}${DateTime.now().year}";

  double completionPercentage = 220;
  double totalSale = 0;
  double totalRefund = 0;
  double totalSummary = 0;

  String? changeLatLngImagePath; // Path to store the captured image

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
    getDataSummary();
    getDataSummaryChoince('year');
  }

  Future<void> _setStoreName() async {
    setState(() {
      storeNameController.text = widget.store.name;
      storePhoneController.text = widget.store.tel;
      storeLineIdController.text = widget.store.lineId;
      storeNoteController.text = widget.store.note;
    });
  }

  Future<void> getDataSummary() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/order/getSummarybyMonth?area=${User.area}&period=${period}&storeId=${widget.store.storeId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        // dashboard = data.map((item) => MonthlySummary.fromJson(item)).toList();
        var data = response.data['data'];
        spots = data.map<FlSpot>((item) {
          double x = (item['month'] as num).toDouble();
          double y = (item['summary'] as num).toDouble();
          return FlSpot(x, y);
        }).toList();
        setState(() {
          isLoadingGraph = false;
        });
      }
      // print(spots);
    } catch (e) {
      print("Error on getDataSummary is $e");
    }
  }

  Future<MultipartFile> compressImages(File image) async {
    final targetPath =
        image.path.replaceAll(RegExp(r'\.(jpg|jpeg|png)$'), '_compressed.jpg');
    var result = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 1024,
      minHeight: 1024,
    );
    File finalFile;
    if (result == null) {
      finalFile = image;
    } else if (result is XFile) {
      finalFile = File(result.path);
    } else {
      finalFile = result as File;
    }
    return await MultipartFile.fromFile(finalFile.path);
  }

  Future<void> addLatLong(BuildContext context) async {
    try {
      await fetchLocation();
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/store/addLatLong',
        method: 'POST',
        body: {
          "storeId": "${widget.customerNo}",
          "latitude": "${latitude}",
          "longtitude": "${longitude}",
        },
      );
      if (response.statusCode == 200) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "ขออนุมัติเปลี่ยน Location ร้านค้าสำเร็จ",
            style: Styles.green18(context),
          ),
        );
        print(response.data['data']['orderId']);
        await addImageLatLong(context, response.data['data']['orderId']);
        Navigator.pop(context);
        // Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print('Error addLatLong: $e');
      context.loaderOverlay.hide();
    }
  }

  Future<void> addImageLatLong(BuildContext context, String orderId) async {
    try {
      await fetchLocation();
      ApiService apiService = ApiService();
      await apiService.init();
      File imageFile = File(changeLatLngImagePath!);
      // ใช้ฟังก์ชัน compressImages ที่เราสร้าง
      MultipartFile compressedFile = await compressImages(imageFile);
      var formData = FormData.fromMap(
        {
          'orderId': orderId,
          'storeImages': compressedFile,
          'type': 'store',
        },
      );
      var response = await apiService.request2(
        endpoint: 'api/cash/store/addImageLatLong',
        method: 'POST',
        body: formData,
        headers: {
          'x-channel': 'cash',
          'Content-Type': 'multipart/form-data',
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "อัพโหลดรูปขออนุมัติเปลี่ยน Location สำเร็จ",
            style: Styles.green18(context),
          ),
        );
      }
    } catch (e) {
      print('Error addImageLatLong: $e');
      context.loaderOverlay.hide();
    }
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

  void openGoogleMapDirection(double lat, double lng) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode
            .externalApplication, // เปิดใน browser หรือแอป Google Maps
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> getDataSummaryChoince(String type) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      print({
        "area": "${User.area}",
        "date": "$date",
        "type": "$type",
      });
      var response = await apiService.request(
        endpoint: 'api/cash/order/getSummarybyChoice',
        method: 'POST',
        body: {
          "area": "${User.area}",
          "date": "$date",
          "storeId": "${widget.store.storeId}",
          "type": "$type",
        },
      );
      if (response.statusCode == 200) {
        print(response.data);
        setState(() {
          totalSale = response.data['total'].toDouble();
        });
      }
    } catch (e) {
      print("Error on getDataSummaryChoince is $e");
      setState(() {
        totalSale = 0.0;
      });
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
                                                Expanded(
                                                  child: Text(
                                                    "${widget.customerName}",
                                                    style:
                                                        Styles.black24(context),
                                                  ),
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
                                      MenuButton(
                                        icon: Icons.change_circle_outlined,
                                        label: "ขอเปลี่ยน",
                                        color: Colors.deepPurple,
                                        onPressed: () async {
                                          _showChaneUpdateStoreLatLng(context);
                                        },
                                      ),
                                      MenuButton(
                                        icon:
                                            widget.store.latitude != "0.000000"
                                                ? Icons.gps_fixed_rounded
                                                : Icons.gps_off_rounded,
                                        label:
                                            widget.store.latitude != "0.000000"
                                                ? "นำทาง"
                                                : "เช็คอิน",
                                        color: Styles.primaryColor,
                                        onPressed: () async {
                                          if (widget.store.latitude ==
                                              "0.000000") {
                                            await fetchLocation();
                                            AllAlert.checkinAlert(
                                                context, _checkin);
                                          } else {
                                            var storeLatitude = widget
                                                .store.latitude
                                                .toDouble();
                                            var storeLongitude = widget
                                                .store.longitude
                                                .toDouble();
                                            openGoogleMapDirection(
                                                storeLatitude,
                                                storeLongitude); // ใส่ lat,lng จุดหมาย
                                          }
                                        },
                                      ),
                                      MenuButton(
                                        icon: Icons.add_shopping_cart_rounded,
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
                                                storeDetail: DetailStoreVisit(
                                                    id: '',
                                                    period: '',
                                                    area: '',
                                                    day: '',
                                                    listStore: [
                                                      ListStore(
                                                          storeInfo: StoreInfo(
                                                              id: '',
                                                              storeId: widget
                                                                  .customerNo,
                                                              name: widget
                                                                  .customerName,
                                                              taxId: widget
                                                                  .store.taxId,
                                                              tel: widget
                                                                  .store.tel,
                                                              typeName: widget
                                                                  .store
                                                                  .typeName,
                                                              address: widget
                                                                  .store
                                                                  .address),
                                                          note:
                                                              widget.store.note,
                                                          status: widget
                                                              .store.status,
                                                          statusText: '',
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
                                        'ยอดการขายตามร้านค้า',
                                        textAlign: TextAlign.start,
                                        style: Styles.black24(context),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderStoreScreen(
                                          storeId: widget.store.storeId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: BudgetCard(
                                    title: 'Total Sales',
                                    icon: Icons.attach_money,
                                    color: Colors.green,
                                    storeId: widget.store.storeId,
                                  ),
                                ),
                                // Row(
                                //   mainAxisAlignment:
                                //       MainAxisAlignment.spaceEvenly,
                                //   children: [
                                //     // Container(
                                //     //   padding:
                                //     //       EdgeInsets.symmetric(vertical: 35),
                                //     //   child: CustomPaint(
                                //     //     size: Size(200, 200),
                                //     //     painter: CircularChartPainter(
                                //     //         completionPercentage:
                                //     //             completionPercentage),
                                //     //     child: Center(
                                //     //       child: Column(
                                //     //         mainAxisSize: MainAxisSize.min,
                                //     //         children: [
                                //     //           // Text(
                                //     //           //   "${((completionPercentage * 100) / 360).toStringAsFixed(2)}%",
                                //     //           //   style: Styles.black18(context),
                                //     //           // ),
                                //     //           Row(
                                //     //             children: [
                                //     //               Text(
                                //     //                 "ขาย : ",
                                //     //                 style:
                                //     //                     Styles.black18(context),
                                //     //               ),
                                //     //               Text(
                                //     //                 "${((completionPercentage * 100) / 360).toStringAsFixed(2)}%",
                                //     //                 style:
                                //     //                     Styles.black18(context),
                                //     //               ),
                                //     //             ],
                                //     //           ),
                                //     //           Row(
                                //     //             children: [
                                //     //               Text(
                                //     //                 "คืน : ",
                                //     //                 style:
                                //     //                     Styles.black18(context),
                                //     //               ),
                                //     //               Text(
                                //     //                 "${((140 * 100) / 360).toStringAsFixed(2)}%",
                                //     //                 style:
                                //     //                     Styles.black18(context),
                                //     //               ),
                                //     //             ],
                                //     //           ),
                                //     //         ],
                                //     //       ),
                                //     //     ),
                                //     //   ),
                                //     // ),
                                //     // Padding(
                                //     //   padding: const EdgeInsets.symmetric(
                                //     //       vertical: 8.0),
                                //     //   child: Column(
                                //     //     children: [
                                //     //       Container(
                                //     //         decoration: BoxDecoration(
                                //     //           color: Colors.grey[200],
                                //     //           borderRadius:
                                //     //               BorderRadius.circular(10),
                                //     //         ),
                                //     //         child: Padding(
                                //     //           padding: EdgeInsets.all(8),
                                //     //           child: Column(
                                //     //             children: [
                                //     //               Text(
                                //     //                 "ยอดขาย",
                                //     //                 style:
                                //     //                     Styles.black24(context),
                                //     //               ),
                                //     //               Row(
                                //     //                 children: [
                                //     //                   // FaIcon(
                                //     //                   //     FontAwesomeIcons
                                //     //                   //         .caretUp,
                                //     //                   //     color: Styles
                                //     //                   //         .successButtonColor),
                                //     //                   // Text(
                                //     //                   //   " 10%",
                                //     //                   //   style: Styles.green10(
                                //     //                   //       context),
                                //     //                   // ),
                                //     //                   Text(
                                //     //                     " ${totalSale.toStringAsFixed(2)} บาท",
                                //     //                     style: Styles.green24(
                                //     //                         context),
                                //     //                   ),
                                //     //                 ],
                                //     //               ),
                                //     //             ],
                                //     //           ),
                                //     //         ),
                                //     //       ),
                                //     //       SizedBox(height: 10),
                                //     //       Container(
                                //     //         decoration: BoxDecoration(
                                //     //           color: Colors.grey[200],
                                //     //           borderRadius:
                                //     //               BorderRadius.circular(10),
                                //     //         ),
                                //     //         child: Padding(
                                //     //           padding: EdgeInsets.all(8),
                                //     //           child: Column(
                                //     //             children: [
                                //     //               Text(
                                //     //                 "ยอดคืน",
                                //     //                 style:
                                //     //                     Styles.black24(context),
                                //     //               ),
                                //     //               Row(
                                //     //                 children: [
                                //     //                   // FaIcon(
                                //     //                   //     FontAwesomeIcons
                                //     //                   //         .caretDown,
                                //     //                   //     color: Styles
                                //     //                   //         .failTextColor),
                                //     //                   // Text(
                                //     //                   //   " 10%",
                                //     //                   //   style: Styles.red10(
                                //     //                   //       context),
                                //     //                   // ),
                                //     //                   Text(
                                //     //                     " ${totalRefund.toStringAsFixed(2)} บาท",
                                //     //                     style:
                                //     //                         Styles.headerRed24(
                                //     //                             context),
                                //     //                   ),
                                //     //                 ],
                                //     //               ),
                                //     //             ],
                                //     //           ),
                                //     //         ),
                                //     //       ),
                                //     //     ],
                                //     //   ),
                                //     // ),
                                //     // Column(
                                //     //   children: [
                                //     //     // Container(
                                //     //     //   decoration: BoxDecoration(
                                //     //     //     color: Colors.grey[200],
                                //     //     //     borderRadius:
                                //     //     //         BorderRadius.circular(10),
                                //     //     //   ),
                                //     //     //   child: Padding(
                                //     //     //     padding: EdgeInsets.all(8),
                                //     //     //     child: Column(
                                //     //     //       children: [
                                //     //     //         Text(
                                //     //     //           "เป้าหมาย",
                                //     //     //           style:
                                //     //     //               Styles.black24(context),
                                //     //     //         ),
                                //     //     //         Row(
                                //     //     //           children: [
                                //     //     //             FaIcon(
                                //     //     //                 FontAwesomeIcons
                                //     //     //                     .caretDown,
                                //     //     //                 color: Styles
                                //     //     //                     .failTextColor),
                                //     //     //             Text(
                                //     //     //               " 10%",
                                //     //     //               style:
                                //     //     //                   Styles.red10(context),
                                //     //     //             ),
                                //     //     //             Text(
                                //     //     //               " ${1500} บาท",
                                //     //     //               style: Styles.headerRed24(
                                //     //     //                   context),
                                //     //     //             ),
                                //     //     //           ],
                                //     //     //         ),
                                //     //     //       ],
                                //     //     //     ),
                                //     //     //   ),
                                //     //     // ),
                                //     //     // SizedBox(height: 10),
                                //     //     Container(
                                //     //       decoration: BoxDecoration(
                                //     //         color: Colors.grey[200],
                                //     //         borderRadius:
                                //     //             BorderRadius.circular(10),
                                //     //       ),
                                //     //       child: Padding(
                                //     //         padding: EdgeInsets.all(8),
                                //     //         child: Column(
                                //     //           children: [
                                //     //             Text(
                                //     //               "ยอดรวม",
                                //     //               style:
                                //     //                   Styles.black24(context),
                                //     //             ),
                                //     //             Row(
                                //     //               children: [
                                //     //                 // FaIcon(
                                //     //                 //     FontAwesomeIcons
                                //     //                 //         .caretDown,
                                //     //                 //     color: Styles
                                //     //                 //         .successButtonColor),
                                //     //                 // Text(
                                //     //                 //   " 10%",
                                //     //                 //   style:
                                //     //                 //       Styles.red10(context),
                                //     //                 // ),
                                //     //                 Text(
                                //     //                   " ${totalSummary.toStringAsFixed(2)} บาท",
                                //     //                   style:
                                //     //                       Styles.headerGreen24(
                                //     //                           context),
                                //     //                 ),
                                //     //               ],
                                //     //             ),
                                //     //           ],
                                //     //         ),
                                //     //       ),
                                //     //     ),
                                //     //   ],
                                //     // ),
                                //   ],
                                // ),
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
                                        'สรุปการขาย',
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
                                        child: SummarybyMonth(
                                          spots: spots,
                                        ),
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

  void _showChaneUpdateStoreLatLng(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes the bottom sheet full screen height
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (
        BuildContext context,
      ) {
        double screenWidth = MediaQuery.of(context).size.width;
        // double screenHeight = MediaQuery.of(context).size.height;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            width: screenWidth * 0.9, // Fixed width
            // height: screenHeight * 0.8,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ขอเปลี่ยน Location ร้านค้า',
                        style: Styles.headerBlack32(context),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close bottom sheet
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Store Information
                  // Text(
                  //   '${storeDetail?.listStore[0].storeInfo.name}',
                  //   style: Styles.black24(context),
                  // ),
                  Text(
                    '${widget.customerNo}',
                    style: Styles.black24(context),
                  ),
                  CameraExpand(
                    icon: Icons.photo_camera,
                    imagePath: changeLatLngImagePath != ""
                        ? changeLatLngImagePath
                        : null,
                    label: "หน้าร้านค้า",
                    onImageSelected: (String imagePath) async {
                      setState(() {
                        changeLatLngImagePath = imagePath;
                      });
                    },
                  ),
                  Container(
                    width: double.infinity, // Full width button
                    child: ElevatedButton(
                      onPressed: () async {
                        if (changeLatLngImagePath != null) {
                          Alert(
                            context: context,
                            title:
                                "store.processtimeline_screen.alert.title".tr(),
                            style: AlertStyle(
                              animationType: AnimationType.grow,
                              isCloseButton: true,
                              isOverlayTapDismiss: false,
                              descStyle: Styles.black18(context),
                              descTextAlign: TextAlign.start,
                              animationDuration:
                                  const Duration(milliseconds: 400),
                              alertBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22.0),
                                side: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              titleStyle: Styles.headerBlack32(context),
                              alertAlignment: Alignment.center,
                            ),
                            desc:
                                "คุณต้องการยืนยันการเปลี่ยน Location ร้านค้าใช่หรือไม่ ?",
                            buttons: [
                              DialogButton(
                                onPressed: () => Navigator.pop(context),
                                color: Styles.failTextColor,
                                child: Text(
                                  "store.processtimeline_screen.alert.cancel"
                                      .tr(),
                                  style: Styles.white18(context),
                                ),
                              ),
                              DialogButton(
                                onPressed: () async {
                                  context.loaderOverlay.show();
                                  await addLatLong(context);

                                  context.loaderOverlay.hide();
                                },
                                color: Styles.successButtonColor,
                                child: Text(
                                  "store.processtimeline_screen.alert.submit"
                                      .tr(),
                                  style: Styles.white18(context),
                                ),
                              )
                            ],
                          ).show();
                        } else {
                          toastification.show(
                            autoCloseDuration: const Duration(seconds: 5),
                            context: context,
                            primaryColor: Colors.red,
                            type: ToastificationType.error,
                            style: ToastificationStyle.flatColored,
                            title: Text(
                              "กรุณาถ่ายรูปก่อนขอเปลี่ยน",
                              style: Styles.red18(context),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.primaryColor,
                        // padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('ขออนุมัติเปลี่ยน',
                          style: Styles.white24(context)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          );
        });
      },
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
