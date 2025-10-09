import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/chart/SummarybyMonth.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/alert/Alert.dart';
import 'package:_12sale_app/core/components/camera/CameraExpand.dart';
import 'package:_12sale_app/core/components/camera/CameraPreviewScreen.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelFixed.dart';
import 'package:_12sale_app/core/components/button/MenuButton.dart';
import 'package:_12sale_app/core/components/card/order/InvoiceCard.dart';
import 'package:_12sale_app/core/components/chart/CircularChart.dart';
import 'package:_12sale_app/core/components/chart/ItemSummarize.dart';
import 'package:_12sale_app/core/components/chart/TrendingMusicChart.dart';
// import 'package:_12sale_app/core/components/table/ShopRouteTable.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/order/OrderDetail.dart';
import 'package:_12sale_app/core/page/order/OrderINRouteScreen.dart';
import 'package:_12sale_app/core/page/order/OrderOutRouteScreen.dart';
import 'package:_12sale_app/core/page/route/ShopRouteScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/Orders.dart';
import 'package:_12sale_app/data/models/route/Cause.dart';
import 'package:_12sale_app/data/models/route/DetailStoreVisit.dart';
import 'package:_12sale_app/data/models/route/StoreLatLong.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/checkRadiusArea.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:_12sale_app/data/service/sockertService.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final String customerNo;
  final String routeId;
  final String route;
  final String latitude;
  final String longtitude;

  DetailScreen({
    super.key,
    required this.customerNo,
    required this.routeId,
    required this.route,
    this.latitude = '0.000000',
    this.longtitude = '0.000000',
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? checkinImagePath; // Path to store the captured image
  String? changeLatLngImagePath; // Path to store the captured image
  String? checkinSellImagePath; // Path to store the captured image
  String selectedCause = 'เลือกเหตุผล';
  String latitude = '00.00';
  String latitudeDirection = '0.000000';
  String longitude = '00.00';
  String longitudeDirection = '0.000000';
  DetailStoreVisit? storeDetail;
  bool _loadingDetailStore = true;
  double completionPercentage = 220;
  final LocationService locationService = LocationService();
  TextEditingController noteController = TextEditingController();
  late DetailStoreVisit? detailStoreVisit;
  String status = "0";
  int statusCheck = 0;
  List<Cause> causes = [];
  List<Orders> orders = [];
  List<StoreLatLong> storeLatLong = [];
  bool _loading = true;
  DateTime dateCheck = DateTime.now().add(Duration(hours: 1));

  final ScrollController _scrollController = ScrollController();

  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";
  // double raduis = 50;

  List<FlSpot> spots = [];
  late SocketService socketService;

  bool checkStoreLatLongStatus = true;

  // String

  @override
  void initState() {
    super.initState();
    _getDetailStore();
    _getCauses();
    _getOrder();
    getDataSummary();
    _getStore();
    // _getLatLongStore();
    _checkLatLongStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    socketService = Provider.of<SocketService>(context, listen: false);
  }

  Future<void> getDataSummary() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/order/getSummarybyMonth?area=${User.area}&period=${period}&storeId=${widget.customerNo}',
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
          // isLoadingGraph = false;
        });
      }
      // print(spots);
    } catch (e) {
      print("Error on getDataSummary is $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _getOrder() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/order/all?type=sale&area=${User.area}&period=${period}&store=${widget.customerNo}',
        method: 'GET',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        // print(response.data['data']);
        // setState(() {});
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              orders = data.map((item) => Orders.fromJson(item)).toList();
              _loading = false;
            });
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<Cause>> getRoutesDropdown(String filter) async {
    try {
      // Load the JSON file for districts
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/manage/option/get?module=route&type=notSell',
        method: 'GET',
      );

      // Filter and map JSON data to District model based on selected province and filter
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          causes = data.map((item) => Cause.fromJson(item)).toList();
        });
      }

      // Group districts by amphoe
      return causes;
    } catch (e) {
      print("Error _getOrder occurred: $e");
      return [];
    }
  }

  Future<void> _getCauses() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/manage/option/get?module=route&type=notSell',
        method: 'GET',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          causes = data.map((item) => Cause.fromJson(item)).toList();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // Future<void> _getRadius() async {
  //   try {
  //     ApiService apiService = ApiService();
  //     await apiService.init();
  //     var response = await apiService.request(
  //       endpoint: 'api/cash/route/getRadius?period=${period}',
  //       method: 'GET',
  //     );
  //     if (response.statusCode == 200) {
  //       final data = response.data['data'];
  //       setState(() {
  //         raduis = data['radius'].toDouble();
  //       });
  //     }
  //   } catch (e) {
  //     print("Error _getRadius $e");
  //   }
  // }

  Future<void> _checkLatLongStatus() async {
    try {
      await fetchLocation();
      // await _getRadius();
      // print("_checkLatLongStatus ${latitude}");
      // print("_checkLatLongStatus ${longitude}");

      // setState(() {
      //   latitude = "13.649143";
      //   longitude = "100.594010";
      // });

      print("_checkLatLongStatus ${latitude}");
      print("_checkLatLongStatus ${longitude}");

      print("_checkLatLongStatus ${latitudeDirection}");
      print("_checkLatLongStatus ${longitudeDirection}");

      // setState(() {
      //   checkStoreLatLongStatus = true;

      // });

      // print(longitude);
      // if (!isOutOfRange(
      //     latitude.toDouble(),
      //     longitude.toDouble(),
      //     latitudeDirection.toDouble(),
      //     longitudeDirection.toDouble(),
      //     raduis)) {
      //   setState(() {
      //     checkStoreLatLongStatus = true;
      //   });
      // }

      const double radius = 50; // เมตร

      final double originLat = double.parse(latitude);
      final double originLng = double.parse(longitude);
      final double destLat = double.parse(latitudeDirection);
      final double destLng = double.parse(longitudeDirection);

      if (!isOutOfRange(originLat, originLng, destLat, destLng, radius)) {
        setState(() {
          checkStoreLatLongStatus = true;
        });
      }
    } catch (e) {
      print("Error in function ${e}");
    }
  }

  Future<void> _getStore() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
        endpoint: 'api/cash/store/${widget.customerNo}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final store = response.data['data'];
        setState(() {
          latitudeDirection = store['latitude'];
          longitudeDirection = store['longtitude'];
        });
      }
    } catch (e) {
      print("Error _getStore $e");
    }
  }

  Future<void> _getDetailStore() async {
    ApiService apiService = ApiService();
    await apiService.init();

    var response = await apiService.request(
      endpoint:
          'api/cash/route/getRoute?area=${User.area}&period=${period}&routeId=${widget.routeId}&storeId=${widget.customerNo}',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      print("statusCheck: ${response.data['data']}");

      setState(() {
        storeDetail =
            data.isNotEmpty ? DetailStoreVisit.fromJson(data[0]) : null;
        status = storeDetail?.listStore[0].status ?? "0";
        statusCheck = int.tryParse(status) ?? 0;
        String inputString = storeDetail?.listStore[0].date ?? "0";
        print("inputString $inputString");
        if (inputString != "0") {
          DateTime inputDate = DateTime.parse(inputString);
          dateCheck = inputDate.add(Duration(hours: 7));
        }
      });
      // print("statusCheck $statusCheck");
      print("dateCheck $dateCheck");
      print("DateTime.now() ${DateTime.now()}");

      Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _loadingDetailStore = false;
          });
        }
      });
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
      print("Error fetchLocation: $e");
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

  Future<void> _checkin() async {
    await fetchLocation();
    Dio dio = Dio();
    final String apiUrl =
        "${ApiService.apiHost}/api/cash/store/checkIn/${widget.customerNo}";
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

  Future<void> checkInStore(BuildContext context) async {
    try {
      await fetchLocation();
      ApiService apiService = ApiService();
      await apiService.init();
      print('selectedCause ${selectedCause == 'เลือกเหตุผล'}');
      Dio dio = Dio();
      // MultipartFile? imageFile;
      File imageFile = File(checkinImagePath!);

      // ใช้ฟังก์ชัน compressImages ที่เราสร้าง
      MultipartFile compressedFile = await compressImages(imageFile);

      // imageFile = await MultipartFile.fromFile(checkinImagePath!);
      // convert = await compressImages(imageFile!);

      if (selectedCause == 'เลือกเหตุผล') {
        Navigator.of(context).pop();
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.red,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: Text(
            "กรุณาเลือกเหตุผลที่เช็คอิน",
            style: Styles.red18(context),
          ),
        );
      } else {
        if (checkinImagePath != null) {
          // print(
          //     "Check Data  : routeId ${widget.routeId}, storeId${widget.customerNo}, note${selectedCause}, checkInImage${imageFile}, latitude${latitude}, longtitude${longitude}");

          String note =
              selectedCause == "อื่นๆ" ? noteController.text : selectedCause;
          print("TestNote ${note}");
          var formData = FormData.fromMap(
            {
              'routeId': storeDetail?.id,
              'storeId': widget.customerNo,
              'note': note,
              'checkInImage': compressedFile,
              // "note":
              //     noteController.text != "" ? noteController.text : selectedCause,
              // "checkInImage": imageFile,
              "latitude": latitude,
              "longtitude": longitude
            },
          );

          var response = await apiService.request2(
            endpoint: 'api/cash/route/checkIn',
            method: 'POST',
            body: formData,
            headers: {
              'x-channel': 'cash',
              'Content-Type': 'multipart/form-data',
            },
          );

          if (response.statusCode == 201 || response.statusCode == 200) {
            socketService.emitEvent('route/checkIn', {
              'message': 'Check In successfully',
            });
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
            setState(() {
              statusCheck = 3;
              storeDetail?.listStore[0].status = '3';
            });
            // await Future.delayed(Duration(milliseconds: 3000));
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ShopRouteScreen(
                  route: widget.route,
                  routeId: widget.routeId,
                ),
              ),
              (route) => route.isFirst,
            );

            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => HomeScreen(
            //       index: 1,
            //     ),
            //   ),
            //   (route) => route.isFirst,
            // );

            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ShopRouteScreen(
            //       route: widget.route,
            //       routeId: widget.routeId,
            //     ),
            //   ),
            // );
          }
        }
      }
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.orange,
          type: ToastificationType.warning,
          style: ToastificationStyle.flatColored,
          title: Text(
            "ไม่สามารถเช็คอินร้านเดิมได้",
            style: Styles.red18(context),
          ),
        );
      }
      print('Error in checkInStore: ${e.message}');
      context.loaderOverlay.hide();
    } catch (e) {
      print('Error checkInStore: $e');
      context.loaderOverlay.hide();
    }
  }

  Future<void> checkInStoreAndSell(BuildContext context) async {
    try {
      await fetchLocation();
      Dio dio = Dio();

      ApiService apiService = ApiService();
      await apiService.init();

      File imageFile = File(checkinSellImagePath!);
      MultipartFile compressedFile = await compressImages(imageFile);
      // MultipartFile? imageFile;
      // imageFile = await MultipartFile.fromFile(checkinSellImagePath!);

      if (checkinSellImagePath != null) {
        var formData = FormData.fromMap(
          {
            'routeId': storeDetail?.id,
            'storeId': widget.customerNo,
            'note': "ขายสินค้า",
            'checkInImage': compressedFile,
            "latitude": latitude,
            "longtitude": longitude
          },
        );
        // var response = await dio.post(
        //   '${ApiService.apiHost}/api/cash/route/checkInVisit',
        //   data: formData,
        //   options: Options(
        //     headers: {
        //       "Content-Type": "multipart/form-data",
        //       'x-channel': 'cash',
        //     },
        //   ),
        // );

        var response = await apiService.request2(
          endpoint: 'api/cash/route/checkInVisit',
          method: 'POST',
          body: formData,
          headers: {
            'x-channel': 'cash',
            'Content-Type': 'multipart/form-data',
          },
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          socketService.emitEvent('route/checkInVisit', {
            'message': 'Check In successfully',
          });
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
          setState(() {
            statusCheck = 2;
            storeDetail?.listStore[0].status = '2';
          });
          context.loaderOverlay.show();
          // await Future.delayed(Duration(milliseconds: 3000));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => OrderINRouteScreen(
                storeDetail: storeDetail,
                routeId: widget.routeId,
              ),
            ),
            (route) => route.isFirst,
          );
        }
      }
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.orange,
          type: ToastificationType.warning,
          style: ToastificationStyle.flatColored,
          title: Text(
            "ไม่สามารถเช็คอินร้านเดิมได้",
            style: Styles.red18(context),
          ),
        );
      }
      print('Error in checkInStore: ${e.message}');
      context.loaderOverlay.hide();
    } catch (e) {
      print('Error checkInStoreAndSell: $e');
      context.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(
            title: ' ${"route.detail_screen.title".tr()} R${storeDetail?.day}',
            icon: Icons.event),
      ),
      body: RefreshIndicator(
        edgeOffset: 0,
        color: Colors.white,
        backgroundColor: Styles.primaryColor,
        onRefresh: () async {
          _getDetailStore();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BoxShadowCustom(
                  // color: Styles.primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${storeDetail?.listStore[0].storeInfo.name}",
                                      style: Styles.black24(context)),
                                  Text('รูท : R${storeDetail?.day}',
                                      style: Styles.black18(context)),
                                  Text(
                                      '${'route.detail_screen.store_id'.tr()} : ${widget.customerNo}',
                                      style: Styles.black18(context)),
                                  Text(
                                      'เบอร์โทร : ${storeDetail?.listStore[0].storeInfo.tel}',
                                      style: Styles.black18(context)),
                                  Text(
                                      'เลขผู้เสียภาษี : ${storeDetail?.listStore[0].storeInfo.taxId}',
                                      style: Styles.black18(context)),
                                  Text(
                                      'ประเภทร้านค้า : ${storeDetail?.listStore[0].storeInfo.typeName}',
                                      style: Styles.black18(context)),
                                  Text(
                                      'สถานะ : ${storeDetail?.listStore[0].statusText}',
                                      style: Styles.black18(context)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${'route.detail_screen.store_address'.tr()} : ${storeDetail?.listStore[0].storeInfo.address}",
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
                              label: "โลเคชั่น",
                              color: Colors.deepPurple,
                              onPressed: () async {
                                _showChaneUpdateStoreLatLng(context);
                              },
                            ),
                            MenuButton(
                              icon: latitudeDirection != "0.000000"
                                  ? Icons.gps_fixed_rounded
                                  : Icons.gps_off_rounded,
                              label: latitudeDirection != "0.000000"
                                  ? "นำทาง"
                                  : "ยังไม่มี",
                              color: latitudeDirection != "0.000000"
                                  ? Styles.primaryColor
                                  : Colors.grey,
                              onPressed: () async {
                                if (latitudeDirection == "0.000000") {
                                  await fetchLocation();
                                  AllAlert.checkinAlert(context, _checkin);
                                } else {
                                  var storeLatitude =
                                      latitudeDirection.toDouble();
                                  var storeLongitude =
                                      longitudeDirection.toDouble();
                                  openGoogleMapDirection(storeLatitude,
                                      storeLongitude); // ใส่ lat,lng จุดหมาย
                                }
                              },
                            ),
                            MenuButton(
                              icon: Icons.store_rounded,
                              label: "ไม่ซื้อ",
                              // color: Styles.success!,
                              color: statusCheck > 0
                                  ? Colors.grey
                                  : Styles.secondaryColor,
                              onPressed: () async {
                                await _getStore();
                                await _checkLatLongStatus();
                                if (statusCheck <= 0) {
                                  if (checkStoreLatLongStatus) {
                                    _showCheckInSheet(context);
                                    setState(
                                      () {
                                        selectedCause = "เลือกเหตุผล";
                                      },
                                    );
                                  } else {
                                    toastification.show(
                                      autoCloseDuration:
                                          const Duration(seconds: 5),
                                      context: context,
                                      primaryColor: Colors.red,
                                      type: ToastificationType.error,
                                      style: ToastificationStyle.flatColored,
                                      title: Text(
                                        "ระยะทางเกิน 50 เมตร",
                                        style: Styles.red18(context),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            MenuButton(
                              icon: Icons.add_shopping_cart_rounded,
                              label: "เช็คอิน/ขาย",
                              color: (statusCheck == 1 || statusCheck == 0) &&
                                      DateTime.now().isBefore(dateCheck)
                                  ? Styles.success!
                                  : Colors.grey,
                              onPressed: () async {
                                await _getStore();
                                await _checkLatLongStatus();
                                if (statusCheck == 1) {
                                  if (DateTime.now().isBefore(dateCheck)) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderINRouteScreen(
                                          storeDetail: storeDetail,
                                          routeId: widget.routeId,
                                        ),
                                      ),
                                    );
                                  }
                                } else if (statusCheck == 0) {
                                  if (checkStoreLatLongStatus) {
                                    _showCheckInAndSellSheet(context);
                                  } else {
                                    toastification.show(
                                      autoCloseDuration:
                                          const Duration(seconds: 5),
                                      context: context,
                                      primaryColor: Colors.red,
                                      type: ToastificationType.error,
                                      style: ToastificationStyle.flatColored,
                                      title: Text(
                                        "ระยะทางเกิน 50 เมตร",
                                        style: Styles.red18(context),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenWidth / 37),
                BoxShadowCustom(
                  child: SizedBox(
                    height: 325,
                    width: screenWidth,
                    child: SummarybyMonth(
                      spots: spots,
                    ),
                  ),
                ),
                SizedBox(height: screenWidth / 37),
                orders.isNotEmpty
                    ? Text('รายการสั่งซื้อ', style: Styles.black24(context))
                    : SizedBox(),
                Container(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 10,
                      radius: Radius.circular(16),
                      child: LoadingSkeletonizer(
                        loading: _loading,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            return InvoiceCard(
                              item: orders[index],
                              onDetailsPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetailScreen(
                                        orderId: orders[index].orderId),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth / 37),
              ],
            ),
          ),
        ),
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
                  Text(
                    '${storeDetail?.listStore[0].storeInfo.name}',
                    style: Styles.black24(context),
                  ),
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

  void _showCheckInSheet(BuildContext context) {
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
                        'เช็คอินร้านค้า',
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
                  Text(
                    '${storeDetail?.listStore[0].storeInfo.name}',
                    style: Styles.black24(context),
                  ),
                  Text(
                    '${widget.customerNo}',
                    style: Styles.black24(context),
                  ),

                  CameraExpand(
                    icon: Icons.photo_camera,
                    imagePath: checkinImagePath != "" ? checkinImagePath : null,
                    label: "หน้าร้านค้า",
                    onImageSelected: (String imagePath) async {
                      setState(() {
                        checkinImagePath = imagePath;
                      });
                      print("checkinImagePath: ${checkinImagePath}");
                      print("Route ID : ${storeDetail?.id}");
                      print(
                          "Route ID : ${storeDetail?.listStore[0].storeInfo.id}");
                      print("Test Check-in : ${noteController.text}");
                      print(
                          "Test Check-in ${noteController.text != "" ? noteController.text : selectedCause}");
                      // await uploadFormDataWithDio(imagePath, 'store', context);
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            child: DropdownSearch<Cause>(
                              dropdownButtonProps: DropdownButtonProps(
                                color: Colors.white,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  size: screenWidth / 20,
                                  color: Colors.black54,
                                ),
                              ),

                              itemAsString: (item) => item.name,
                              asyncItems: (filter) => getRoutesDropdown(filter),

                              // items:(filter, infiniteScrollProps) =>
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                baseStyle: Styles.black18(context),
                                dropdownSearchDecoration: InputDecoration(
                                  // fillColor: Colors.white,
                                  // prefixIcon: widget.icon,
                                  labelText: "เลือกเหตุผลเช็คอิน",
                                  labelStyle: Styles.grey18(context),
                                  hintText: "เลือกเหตุผลเช็คอิน",
                                  hintStyle: Styles.grey18(context),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    borderSide: BorderSide(
                                        color: Colors.blue, width: 1.5),
                                  ),
                                ),
                              ),
                              onChanged: (Cause? data) {
                                noteController.clear();
                                setModalState(
                                  () {
                                    selectedCause = data!.name;
                                  },
                                );
                              },
                              popupProps: PopupPropsMultiSelection.dialog(
                                constraints: BoxConstraints(
                                  maxHeight: screenWidth * 0.7,
                                  maxWidth: screenWidth,
                                  minHeight: screenWidth * 0.7,
                                  minWidth: screenWidth,
                                ),
                                title: Container(
                                  decoration: const BoxDecoration(
                                    color: Styles.primaryColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    "เลือกเหตุผลเช็คอิน",
                                    style: Styles.white18(context),
                                  ),
                                ),

                                // showSearchBox: widget.showSearchBox,
                                itemBuilder: (context, item, isSelected) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          " ${item.name}",
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
                                searchFieldProps: TextFieldProps(
                                  style: Styles.black18(context),
                                  autofocus: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  selectedCause == 'อื่นๆ'
                      ? Container(
                          margin: EdgeInsets.symmetric(vertical: 16),
                          child: TextField(
                            controller: noteController,
                            style: Styles.black18(context),
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'ใส่ข้อมูล',
                              hintStyle: Styles.black18(context),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: 0),
                  // Text input field
                  // const SizedBox(height: 16),
                  // Save button
                  Container(
                    // margin: EdgeInsets.symmetric(vertical: 16),
                    // padding: const EdgeInsets.all(8.0),
                    width: double.infinity, // Full width button
                    child: ElevatedButton(
                      onPressed: () async {
                        if (checkinImagePath != null) {
                          if (selectedCause != 'เลือกเหตุผล') {
                            if (selectedCause == 'อื่นๆ') {
                              if (noteController.text == "") {
                                toastification.show(
                                  autoCloseDuration: const Duration(seconds: 5),
                                  context: context,
                                  primaryColor: Colors.red,
                                  type: ToastificationType.error,
                                  style: ToastificationStyle.flatColored,
                                  title: Text(
                                    "กรุณาใส่เหตุผลที่เช็คอิน",
                                    style: Styles.black18(context),
                                  ),
                                );
                              } else {
                                Alert(
                                  context: context,
                                  title:
                                      "store.processtimeline_screen.alert.title"
                                          .tr(),
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
                                      "คุณต้องการยืนยันการเช็คอินร้านค้าใช่หรือไม่ ?",
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
                                        await checkInStore(context);

                                        // calculateDistance()
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
                              }
                            } else {
                              Alert(
                                context: context,
                                title:
                                    "store.processtimeline_screen.alert.title"
                                        .tr(),
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
                                    "คุณต้องการยืนยันการเช็คอินร้านค้าใช่หรือไม่ ?",
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
                                      await checkInStore(context);
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
                            }
                          } else {
                            toastification.show(
                              autoCloseDuration: const Duration(seconds: 5),
                              context: context,
                              primaryColor: Colors.red,
                              type: ToastificationType.error,
                              style: ToastificationStyle.flatColored,
                              title: Text(
                                "กรุณาเลือกเหตุผลที่เช็คอิน",
                                style: Styles.red18(context),
                              ),
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
                              "กรุณาถ่ายรูปก่อนเช็คอิน",
                              style: Styles.black18(context),
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
                      child: Text('เช็คอิน', style: Styles.white24(context)),
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

  void _showCheckInAndSellSheet(BuildContext context) {
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
                        'เช็คอินร้านค้า',
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
                  Text(
                    '${storeDetail?.listStore[0].storeInfo.name}',
                    style: Styles.black24(context),
                  ),
                  Text(
                    '${widget.customerNo}',
                    style: Styles.black24(context),
                  ),
                  CameraExpand(
                    icon: Icons.photo_camera,
                    imagePath: checkinSellImagePath != ""
                        ? checkinSellImagePath
                        : null,
                    label: "หน้าร้านค้า",
                    onImageSelected: (String imagePath) async {
                      setState(() {
                        checkinSellImagePath = imagePath;
                      });
                    },
                  ),
                  Container(
                    width: double.infinity, // Full width button
                    child: ElevatedButton(
                      onPressed: () async {
                        if (checkinSellImagePath != null) {
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
                                "คุณต้องการยืนยันการเช็คอินร้านค้าใช่หรือไม่ ?",
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
                                  await checkInStoreAndSell(context);
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
                              "กรุณาถ่ายรูปก่อนเช็คอิน",
                              style: Styles.black18(context),
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
                      child: Text('เช็คอิน', style: Styles.white24(context)),
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
}
