import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/alert/Alert.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/dashboard/DashboardScreen.dart';
import 'package:_12sale_app/core/page/store/PolicyScreen.dart';
import 'package:_12sale_app/core/page/store/StoreAddressScreen.dart';
import 'package:_12sale_app/core/page/store/StoreDataScreen.dart';
import 'package:_12sale_app/core/page/store/VerifyStoreScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/core/utils/tost_util.dart';
import 'package:_12sale_app/data/models/DuplicateStore.dart';
import 'package:_12sale_app/data/models/Location.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/Shoptype.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/User.dart';
// import 'package:_12sale_app/data/service/requestPremission.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelines/timelines.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../data/service/apiService.dart';

const kTileHeight = 50.0;
const completeColor = Color(0xff5e6172);
const inProgressColor = Styles.primaryColor;
const todoColor = Color(0xffd1d2d7);

class ProcessTimelinePage extends StatefulWidget {
  ProcessTimelinePage({super.key});

  @override
  State<ProcessTimelinePage> createState() => _ProcessTimelinePageState();
}

class _ProcessTimelinePageState extends State<ProcessTimelinePage> {
  int _processIndex = 0;
  bool isPolicy = false;
  late Store _storeData;
  late TextEditingController storeNameController;
  late TextEditingController storeTaxIDController;
  late TextEditingController storeTelController;
  late TextEditingController storeLineController;
  late TextEditingController storeNoteController;
  late TextEditingController storeAddressController;
  late TextEditingController storePoscodeController;
  RouteStore initialSelectedRoute = RouteStore(route: '');
  ShopType initialSelectedShoptype =
      ShopType(id: '', name: '', descript: '', status: '');
  List<dynamic> imageList = [];
  List<Store> duplicateStores = [];
  Location initialSelectedLocation = Location(
      id: '',
      amphoe: '',
      amphoeCode: '',
      district: '',
      districtCode: '',
      province: '',
      provinceCode: '');

  @override
  initState() {
    super.initState();
    checkRequestLocation();
    _processIndex = 0;
    _clearStore();
    storeNameController = TextEditingController();
    storeTaxIDController = TextEditingController();
    storeTelController = TextEditingController();
    storeLineController = TextEditingController();
    storeNoteController = TextEditingController();
    storeAddressController = TextEditingController();
    storePoscodeController = TextEditingController();
  }

  @override
  void dispose() {
    storeNameController.dispose();
    storeTaxIDController.dispose();
    storeTelController.dispose();
    storeLineController.dispose();
    storeNoteController.dispose();
    storeAddressController.dispose();
    storePoscodeController.dispose();
    super.dispose();
  }

  Future<void> checkRequestLocation() async {
    // final status = await Permission.location.request();
    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      print(
          'requestLocation : ${await Permission.locationWhenInUse.serviceStatus.isEnabled}');
    } else {
      Navigator.of(context).pop();
      print(
          'requestLocation : ${await Permission.locationWhenInUse.serviceStatus.isEnabled}');
    }
  }

  void showCommonAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "แจ้งเตือน",
            style: Styles.black24(context),
          ),
          content: Text(
            "กรุณาเปิดการใช้งานโลเคชั่นเพื่อทำการเพื่มร้านค้า",
            style: Styles.black18(context),
          ),
          actions: [
            TextButton(
              child: Text("ตกลง", style: Styles.black18(context)),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  Widget _getBodyContent() {
    switch (_processIndex) {
      case 0:
        return const PolicyScreen();
      case 1:
        return StoreDataScreen(
          storeData: _storeData,
          storeNameController: storeNameController,
          storeTaxIDController: storeTaxIDController,
          storeTelController: storeTelController,
          storeLineController: storeLineController,
          storeNoteController: storeNoteController,
          initialSelectedRoute: initialSelectedRoute,
          initialSelectedShoptype: initialSelectedShoptype,
          imageList: imageList,
        );
      case 2:
        return StoreAddressScreen(
          storeAddressController: storeAddressController,
          storePoscodeController: storePoscodeController,
          initialSelectedLocation: initialSelectedLocation,
        );
      case 3:
        return VerifyStoreScreen(
          storeData: _storeData,
        );
      default:
        return Center(child: Text("Unknown step"));
    }
  }

  Color getColor(int index) {
    if (index == _processIndex) {
      return inProgressColor;
    } else if (index < _processIndex) {
      return completeColor;
    } else {
      return todoColor;
    }
  }

  Future<void> _clearStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('add_store'); // Clear orders from SharedPreferences
    await prefs.remove('image_store'); // Clear orders from SharedPreferences
  }

  Future<void> _loadStoreFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Get the JSON string list from SharedPreferences
    String? jsonStore = prefs.getString("add_store");
    if (jsonStore != null) {
      setState(() {
        _storeData =
            // ignore: unnecessary_null_comparison
            (jsonStore == null ? null : Store.fromJson(jsonDecode(jsonStore)))!;
      });
      if (_storeData.policyConsent.status == 'Agree') {
        isPolicy = true;
      }
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters

    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in meters
  }

  List<Map<String, dynamic>> stores = [
    {
      "storeId": 1,
      "storeName": "Store A",
      "location": {"lat": 40.7128, "lon": -74.0060}
    },
    {
      "storeId": 2,
      "storeName": "Store B",
      "location": {"lat": 40.7129, "lon": -74.0059}
    },
    {
      "storeId": 3,
      "storeName": "Store C",
      "location": {"lat": 40.7130, "lon": -74.0058}
    },
  ];

  List<Map<String, dynamic>> findStoresWithinRadius(
      double currentLat, double currentLon, double radiusMeters) {
    return stores.where((store) {
      double distance = calculateDistance(
        currentLat,
        currentLon,
        store['location']['lat'],
        store['location']['lon'],
      );
      return distance <= radiusMeters; // Check if within radius
    }).toList();
  }

  void checkNearbyStores(double currentLat, double currentLon) {
    double radius = 50.0; // Radius in meters
    List<Map<String, dynamic>> nearbyStores =
        findStoresWithinRadius(currentLat, currentLon, radius);

    if (nearbyStores.isNotEmpty) {
      print("Nearby stores within 50 meters: $nearbyStores");
    } else {
      print("No stores found within 50 meters.");
    }
  }

  Future<void> sentNoitfytoBot(storeName) async {
    try {
      Dio dio = Dio();
      final String apiUrl =
          "https://apps.onetwotrading.co.th/12chat/api/messages/send";
      var botData = {};

      switch (User.zone) {
        case "BE":
          botData = {
            "roomId": [
              "684bcc9e90a3287657d67ced"
            ], // Room IDs ที่เชื่อมต่อกับ bot นี้
            "message": [
              "มีการเพิ่มร้านใหม่ ชื่อ '$storeName' จากเขต '${User.area}' โดย '${User.fullName}'",
              "https://apps.onetwotrading.co.th/supervisor/approve/#status=ไปที่หน้าเว็บ&color=yellow"
            ],
            "employeeId": "20250008",
            "isAdminNotification": true
          };
          break;
        case "CT":
          botData = {
            "roomId": [
              "684bdd1390a3287657d6efa1"
            ], // Room IDs ที่เชื่อมต่อกับ bot นี้
            "message": [
              "มีการเพิ่มร้านใหม่ ชื่อ '$storeName' จากเขต '${User.area}' โดย '${User.fullName}'",
              "https://apps.onetwotrading.co.th/supervisor/approve/#status=ไปที่หน้าเว็บ&color=yellow"
            ],
            "employeeId": "20250011",
            "isAdminNotification": true
          };
          break;
        case "SH":
          botData = {
            "roomId": [
              "684bd38890a3287657d6db36"
            ], // Room IDs ที่เชื่อมต่อกับ bot นี้
            "message": [
              "มีการเพิ่มร้านใหม่ ชื่อ '$storeName' จากเขต '${User.area}' โดย '${User.fullName}'",
              "https://apps.onetwotrading.co.th/supervisor/approve/#status=ไปที่หน้าเว็บ&color=yellow"
            ],
            "employeeId": "20250012",
            "isAdminNotification": true
          };

          break;
        case "NS":
          botData = {
            "roomId": [
              "684bda5790a3287657d6ef1a"
            ], // Room IDs ที่เชื่อมต่อกับ bot นี้
            "message": [
              "มีการเพิ่มร้านใหม่ ชื่อ '$storeName' จากเขต '${User.area}' โดย '${User.fullName}'",
              "https://apps.onetwotrading.co.th/supervisor/approve/#status=ไปที่หน้าเว็บ&color=yellow"
            ],
            "employeeId": "20250013",
            "isAdminNotification": true
          };
          break;
        case "NE":
          botData = {
            "roomId": [
              "684bd9a090a3287657d6ed26"
            ], // Room IDs ที่เชื่อมต่อกับ bot นี้
            "message": [
              "มีการเพิ่มร้านใหม่ ชื่อ '$storeName' จากเขต '${User.area}' โดย '${User.fullName}'",
              "https://apps.onetwotrading.co.th/supervisor/approve/#status=ไปที่หน้าเว็บ&color=yellow"
            ],
            "employeeId": "20250010",
            "isAdminNotification": true
          };
          break;
        case "NH":
          botData = {
            "roomId": [
              "684bcdb090a3287657d68951"
            ], // Room IDs ที่เชื่อมต่อกับ bot นี้
            "message": [
              "มีการเพิ่มร้านใหม่ ชื่อ '$storeName' จากเขต '${User.area}' โดย '${User.fullName}'",
              "https://apps.onetwotrading.co.th/supervisor/approve/#status=ไปที่หน้าเว็บ&color=yellow"
            ],
            "employeeId": "20250009",
            "isAdminNotification": true
          };
          break;

        default:
      }

      final response = await dio.post(
        apiUrl,
        data: botData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      if (response.statusCode == 200) {
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
    } catch (e) {
      print("Error sentNotifytoBot $e");
    }
  }

  Future<List<MultipartFile>> compressImages(List<File> images) async {
    List<MultipartFile> compressed = [];
    for (File img in images) {
      final targetPath = img.path.replaceAll('.jpg', '_compressed.jpg');
      var result = await FlutterImageCompress.compressAndGetFile(
        img.absolute.path,
        targetPath,
        quality: 80,
        minWidth: 1024,
        minHeight: 1024,
      );
      late File finalFile;
      if (result == null) {
        finalFile = img;
      } else if (result is XFile) {
        finalFile = File(result.path);
      } else {
        finalFile = result as File;
      }
      compressed.add(await MultipartFile.fromFile(finalFile.path));
    }
    return compressed;
  }

  // Helper รองรับทั้ง XFile, File หรือ path String
  File getFileFromItem(dynamic item) {
    if (item is File) {
      return item;
    } else if (item is XFile) {
      return File(item.path);
    } else if (item is String) {
      return File(item);
    } else if (item.path != null) {
      // สำหรับโมเดลเช่น ImageItem ที่มี .path
      return File(item.path);
    }
    throw Exception("Invalid image item type: ${item.runtimeType}");
  }

  Future<void> addStore() async {
    String jsonData = '''
{
      "name": "${_storeData.name}",
      "taxId": "${_storeData.taxId}",
      "tel": "${_storeData.tel}",
      "route": "${_storeData.route}",
      "type": "${_storeData.type}",
      "typeName": "${_storeData.typeName}",
      "address": "${_storeData.address}",
      "district": "${_storeData.district}",
      "subDistrict": "${_storeData.subDistrict}",
      "province": "${_storeData.province}",
      "provinceCode": "${_storeData.postCode.substring(0, 2)}",
      "postCode": "${_storeData.postCode}",
      "note":"${_storeData.note}",
      "shippingAddress": [
        {
          "default": "1",
          "address": "${_storeData.address}",
          "district": "${_storeData.district}",
          "subDistrict": "${_storeData.subDistrict}",
          "province": "${_storeData.province}",
          "provinceCode": "${_storeData.postCode.substring(0, 2)}",
          "postCode": "${_storeData.postCode}",
          "latitude": "${_storeData.latitude}",
          "longtitude": "${_storeData.longitude}"
        }
      ],
      "zone": "${User.zone}",
      "area": "${User.area}",
      "latitude": "${_storeData.latitude}",
      "longtitude": "${_storeData.longitude}",
      "lineId": "${_storeData.lineId}",
      "policyConsent": {"status": "${_storeData.policyConsent.status}"},
      "approve": {"appPerson": ""}
}
''';

    try {
      // 1. ดึง path แล้วแปลงเป็น File
      List<File> fileList = _storeData.imageList
          .map<File>((item) => getFileFromItem(item))
          .toList();
      // 2. ใช้ compressImages ได้เลย
      List<MultipartFile> imageList = await compressImages(fileList);

      // List<MultipartFile> imageList = [];

      // for (var value in _storeData.imageList) {
      //   imageList.add(
      //     await MultipartFile.fromFile(
      //       value.path,
      //     ),
      //   );
      // }

      print((_storeData.imageList.any((item) => item.type == 'person')));
      String type =
          "store${(_storeData.imageList.any((item) => item.type == 'tax')) ? ",document" : ""}${(_storeData.imageList.any((item) => item.type == 'person')) ? ",idCard" : ""}";

      var formData = FormData.fromMap(
        {'storeImages': imageList, 'types': type, "store": jsonData},
      );

      print(formData);
      print(imageList);
      final apiService = ApiService();
      await apiService.init();

      var response = await apiService.request2(
        endpoint: 'api/cash/store/addStore',
        method: 'POST',
        body: formData,
        headers: {
          'x-channel': 'cash',
          'Content-Type': 'multipart/form-data',
        },
      );

      // client.findProxy = HttpClient.findProxyFromEnvironment;

      // var response = await dio.post(
      //   '${ApiService.apiHost}/api/cash/store/addStore',
      //   data: formData,
      //   options: Options(
      //     headers: {
      //       "Content-Type": "multipart/form-data",
      //       'x-channel': 'cash',
      //     },
      //   ),
      // );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Image uploaded successfully ${response.data}");
        toastification.dismissAll();
        if (response.data['message'] == 'similar store') {
          final List<dynamic> data = response.data['data'];
          setState(() {
            duplicateStores = data
                .map((item) =>
                    Store.fromJson(item['store'] as Map<String, dynamic>))
                .toList();
          });
          showToastDuplicateMenu(
            stores: duplicateStores,
            context: context,
            icon: const Icon(Icons.priority_high),
            type: ToastificationType.error,
            primaryColor: Colors.red,
            titleStyle: Styles.headerRed18(context),
            descriptionStyle: Styles.red18(context),
            message:
                "${response.data['data'][0]['similarity']}% ${"store.processtimeline_screen.toasting_similar".tr()}",
            description:
                "${"store.processtimeline_screen.toasting_similar_des".tr()} ",
          );
          context.loaderOverlay.hide();
        } else if (response.data['message'] == 'Store added successfully') {
          await sentNoitfytoBot(_storeData.name);
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
          context.loaderOverlay.hide();
          // Future.delayed(Duration(milliseconds: 3000));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen(index: 2)),
          );
        }
      }
    } catch (e) {
      toastification.show(
        autoCloseDuration: const Duration(seconds: 5),
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(
          "store.processtimeline_screen.toasting_error".tr(),
          style: Styles.black18(context),
        ),
      );
      context.loaderOverlay.hide();
      print("Error: ${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final _processes = [
      'store.processtimeline_screen.step1'.tr(),
      'store.processtimeline_screen.step2'.tr(),
      'store.processtimeline_screen.step3'.tr(),
      'store.processtimeline_screen.step4'.tr()
    ];

    double screenWidth = MediaQuery.of(context).size.width;
    return ToastificationConfigProvider(
      config: const ToastificationConfig(
        // alignment: Alignment.center,
        itemWidth: 1000,
        // animationDuration: Duration(milliseconds: 500),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: AppbarCustom(
              title: " ${"store.processtimeline_screen.appbar".tr()}",
              icon: Icons.store_mall_directory_rounded),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Timeline.tileBuilder(
                  theme: TimelineThemeData(
                    direction: Axis.horizontal,
                    connectorTheme: const ConnectorThemeData(
                      space: 30.0,
                      thickness: 5.0,
                    ),
                  ),
                  builder: TimelineTileBuilder.connected(
                    connectionDirection: ConnectionDirection.before,
                    itemExtentBuilder: (_, __) =>
                        MediaQuery.of(context).size.width / 4.4,
                    oppositeContentsBuilder: (context, index) {
                      // Define a list of icons for each step
                      final List<IconData> stepIcons = [
                        Icons.privacy_tip, // Icon for "Prospect"
                        Icons.person_pin, // Icon for "Tour"
                        Icons.location_on_rounded, // Icon for "Offer"
                        Icons.verified_user_outlined, // Icon for "Contract"
                      ];

                      // final List<FaIcon> stepIcons = [
                      //   FaIcon(FontAwesomeIcons.google),

                      // ];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: GestureDetector(
                          onTap: () => setState(() => _processIndex = index),
                          child: Icon(
                            stepIcons[
                                index], // Use the icon corresponding to the current step
                            size: 30.0,
                            color: getColor(index),
                          ),
                        ),
                      );
                    },
                    contentsBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          _processes[index],
                          style: Styles.black18(context),
                        ),
                      );
                    },
                    indicatorBuilder: (_, index) {
                      var color;
                      var child;
                      if (index == _processIndex) {
                        color = inProgressColor;
                        child = const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        );
                      } else if (index < _processIndex) {
                        color = completeColor;
                        child = GestureDetector(
                          onTap: () => setState(() => _processIndex = index),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 15.0,
                          ),
                        );
                      } else {
                        color = todoColor;
                      }

                      if (index <= _processIndex) {
                        return Stack(
                          children: [
                            CustomPaint(
                              size: Size(30.0, 30.0),
                              painter: _BezierPainter(
                                color: color,
                                drawStart: index > 0,
                                drawEnd: index < _processIndex,
                              ),
                            ),
                            DotIndicator(
                              size: 30.0,
                              color: color,
                              child: child,
                            ),
                          ],
                        );
                      } else {
                        return Stack(
                          children: [
                            CustomPaint(
                              size: const Size(15.0, 15.0),
                              painter: _BezierPainter(
                                color: color,
                                drawEnd: index < _processes.length - 1,
                              ),
                            ),
                            OutlinedDotIndicator(
                              borderWidth: 4.0,
                              color: color,
                            ),
                          ],
                        );
                      }
                    },
                    connectorBuilder: (_, index, type) {
                      if (index > 0) {
                        if (index == _processIndex) {
                          final prevColor = getColor(index - 1);
                          final color = getColor(index);
                          List<Color> gradientColors;
                          if (type == ConnectorType.start) {
                            gradientColors = [
                              Color.lerp(prevColor, color, 0.5)!,
                              color
                            ];
                          } else {
                            gradientColors = [
                              prevColor,
                              Color.lerp(prevColor, color, 0.5)!
                            ];
                          }
                          return DecoratedLineConnector(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                              ),
                            ),
                          );
                        } else {
                          return SolidLineConnector(
                            color: getColor(index),
                          );
                        }
                      } else {
                        return null;
                      }
                    },
                    itemCount: _processes.length,
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
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
                        offset: const Offset(0,
                            4), // Offset of the shadow (horizontal, vertical)
                      ),
                    ],
                  ),
                  // color: Colors.black,
                  child: _getBodyContent(),
                ), // Displays different content for each step
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                16), // Rounded corners for the outer container

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                    0.2), // Shadow color with transparency
                                spreadRadius: 2, // Spread of the shadow
                                blurRadius: 8, // Blur radius of the shadow
                                offset: const Offset(0,
                                    4), // Offset of the shadow (horizontal, vertical)
                              ),
                            ],
                          ),
                          width: screenWidth / 2.2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_processIndex == 0) {
                              } else {
                                switch (_processIndex) {
                                  case 1:
                                    return () {
                                      // setState(() {
                                      //   _processIndex = (_processIndex - 1) %
                                      //       _processes.length;
                                      // });
                                    }();
                                  case 2:
                                    return () {
                                      _loadStoreFromStorage().then((_) {
                                        setState(() {
                                          initialSelectedRoute = RouteStore(
                                              route: _storeData.route);
                                          initialSelectedShoptype = ShopType(
                                              id: _storeData.type,
                                              name: _storeData.typeName,
                                              descript: '',
                                              status: '');
                                          imageList = _storeData.imageList;
                                        });
                                        setState(() {
                                          _processIndex = (_processIndex - 1) %
                                              _processes.length;
                                        });
                                      });
                                    }();
                                  case 3:
                                    return () {
                                      _loadStoreFromStorage().then((_) {
                                        setState(() {
                                          storeAddressController =
                                              TextEditingController(
                                                  text: _storeData.address);

                                          initialSelectedLocation = Location(
                                              province: _storeData.province,
                                              amphoe: _storeData.district,
                                              districtCode: '',
                                              zipcode: _storeData.postCode,
                                              provinceCode: _storeData.postCode
                                                  .substring(1, 3),
                                              id: '',
                                              amphoeCode: '',
                                              district: _storeData.subDistrict);

                                          _processIndex = (_processIndex - 1) %
                                              _processes.length;
                                        });
                                      });
                                    }();
                                  default:
                                    return print('error');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.primaryColor,
                              padding: EdgeInsets.symmetric(
                                  vertical: screenWidth / 85,
                                  horizontal: screenWidth / 17),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                                "store.processtimeline_screen.back_button".tr(),
                                style: Styles.white18(context)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                16), // Rounded corners for the outer container
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                    0.2), // Shadow color with transparency
                                spreadRadius: 2, // Spread of the shadow
                                blurRadius: 8, // Blur radius of the shadow
                                offset: const Offset(0,
                                    4), // Offset of the shadow (horizontal, vertical)
                              ),
                            ],
                          ),
                          width: screenWidth / 2.2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_processIndex == 3) {
                                print(
                                  "store.processtimeline_screen.alert.title"
                                      .tr(),
                                );
                                CustomAlertDialog.show(
                                  context: context,
                                  alertType: AlertType.info,
                                  title:
                                      "store.processtimeline_screen.alert.title"
                                          .tr(),
                                  description:
                                      "store.processtimeline_screen.alert.desc"
                                          .tr(),
                                  onCancel: () {
                                    Navigator.pop(
                                        context); // Handle cancel logic
                                  },
                                  onSubmit: () {
                                    context.loaderOverlay.show();
                                    addStore(); // Handle submit logic
                                  },
                                  cancelText:
                                      "store.processtimeline_screen.alert.cancel"
                                          .tr(),
                                  submitText:
                                      "store.processtimeline_screen.alert.submit"
                                          .tr(),
                                  style: AlertStyle(
                                    descStyle: Styles.black18(context),
                                    titleStyle: Styles.headerBlack32(context),
                                  ),
                                );
                                // Alert(
                                //   context: context,
                                //   type: AlertType.info,
                                //   title:
                                //       "store.processtimeline_screen.alert.title"
                                //           .tr(),
                                //   style: AlertStyle(
                                //     animationType: AnimationType.grow,
                                //     isCloseButton: false,
                                //     isOverlayTapDismiss: false,
                                //     descStyle: Styles.black18(context),
                                //     descTextAlign: TextAlign.start,
                                //     animationDuration:
                                //         const Duration(milliseconds: 400),
                                //     alertBorder: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(22.0),
                                //       side: const BorderSide(
                                //         color: Colors.grey,
                                //       ),
                                //     ),
                                //     titleStyle: Styles.headerBlack32(context),
                                //     alertAlignment: Alignment.center,
                                //   ),
                                //   desc:
                                //       "store.processtimeline_screen.alert.desc"
                                //           .tr(),
                                //   buttons: [
                                //     DialogButton(
                                //       onPressed: () => Navigator.pop(context),
                                //       color: Styles.failTextColor,
                                //       child: Text(
                                //         "store.processtimeline_screen.alert.cancel"
                                //             .tr(),
                                //         style: Styles.white18(context),
                                //       ),
                                //     ),
                                //     DialogButton(
                                //       onPressed: () {
                                //         addStore();
                                //       },
                                //       color: Styles.successButtonColor,
                                //       child: Text(
                                //         "store.processtimeline_screen.alert.submit"
                                //             .tr(),
                                //         style: Styles.white18(context),
                                //       ),
                                //     )
                                //   ],
                                // ).show();
                              } else {}

                              switch (_processIndex) {
                                case 0:
                                  return () {
                                    _loadStoreFromStorage().then((_) {
                                      if (isPolicy == true) {
                                        setState(() {
                                          _processIndex = (_processIndex + 1) %
                                              _processes.length;
                                        });
                                      }
                                    });
                                  }();
                                case 1:
                                  return () {
                                    _loadStoreFromStorage().then((_) {
                                      // print(_storeData.name);
                                      // print(_storeData.taxId);
                                      // print(_storeData.typeName);
                                      print(_storeData.imageList);
                                      // Create a list to hold missing fields
                                      List<String> missingFields = [];

                                      // Check for missing fields
                                      if (_storeData.name.isEmpty) {
                                        missingFields.add(
                                            "store.processtimeline_screen.toasting.name"
                                                .tr());
                                      }
                                      if (_storeData.tel.isEmpty) {
                                        missingFields.add(
                                            "store.processtimeline_screen.toasting.phone"
                                                .tr());
                                      }
                                      if (_storeData.typeName.isEmpty) {
                                        missingFields.add(
                                            "store.processtimeline_screen.toasting.store_type"
                                                .tr());
                                      }
                                      if (_storeData.route.isEmpty) {
                                        missingFields.add(
                                            "store.processtimeline_screen.toasting.route"
                                                .tr());
                                      }

                                      // If there are missing fields, show the toast
                                      if (missingFields.isNotEmpty) {
                                        toastification.show(
                                          autoCloseDuration:
                                              const Duration(seconds: 5),
                                          style:
                                              ToastificationStyle.flatColored,
                                          context: context,
                                          title: Text(
                                            " '${"store.processtimeline_screen.toasting.message".tr()} ${missingFields.join(', ')}'",
                                            style: Styles.red18(context),
                                          ),
                                          type: ToastificationType.error,
                                          primaryColor: Colors.red,
                                        );
                                      }
                                      if (_storeData.imageList.isEmpty) {
                                        toastification.show(
                                          autoCloseDuration:
                                              const Duration(seconds: 5),
                                          style:
                                              ToastificationStyle.flatColored,
                                          context: context,
                                          title: Text(
                                            "${"store.processtimeline_screen.toasting.image".tr()}",
                                            style: Styles.red18(context),
                                          ),
                                          type: ToastificationType.error,
                                          primaryColor: Colors.red,
                                        );
                                      }

                                      // _processIndex = (_processIndex + 1) %
                                      //     _processes.length;

                                      setState(() {
                                        initialSelectedRoute =
                                            RouteStore(route: _storeData.route);
                                        initialSelectedShoptype = ShopType(
                                            id: _storeData.type,
                                            name: _storeData.typeName,
                                            descript: '',
                                            status: '');

                                        if (_storeData.name != "" &&
                                            _storeData.typeName != "" &&
                                            _storeData.tel != "" &&
                                            _storeData.route != "" &&
                                            _storeData.imageList.isNotEmpty) {
                                          _processIndex = (_processIndex + 1) %
                                              _processes.length;
                                        }
                                      });
                                    });
                                  }();
                                case 2:
                                  return () {
                                    _loadStoreFromStorage().then((_) {
                                      List<String> missingFields = [];

                                      // Check for missing fields
                                      if (_storeData.address.isEmpty) {
                                        missingFields.add(
                                            "store.processtimeline_screen.toasting.address"
                                                .tr());
                                      }
                                      if (_storeData.province.isEmpty) {
                                        missingFields.add(
                                            "store.processtimeline_screen.toasting.province"
                                                .tr());
                                      }
                                      if (_storeData.district.isEmpty) {
                                        missingFields.add(
                                            "store.processtimeline_screen.toasting.district"
                                                .tr());
                                      }
                                      if (_storeData.subDistrict.isEmpty) {
                                        missingFields.add(
                                            "store.processtimeline_screen.toasting.sub_district"
                                                .tr());
                                      }

                                      // If there are missing fields, show the toast
                                      if (missingFields.isNotEmpty) {
                                        toastification.show(
                                          autoCloseDuration:
                                              const Duration(seconds: 5),
                                          style:
                                              ToastificationStyle.flatColored,
                                          context: context,
                                          title: Text(
                                            '${"store.processtimeline_screen.toasting.message_selected".tr()} ${missingFields.join(', ')}',
                                            style: Styles.red18(context),
                                          ),
                                          type: ToastificationType.error,
                                          primaryColor: Colors.red,
                                        );
                                      }
                                      print(_storeData.address);
                                      print(_storeData.province);
                                      print(_storeData.district);
                                      print(_storeData.subDistrict);

                                      if (_storeData.address != "" &&
                                          _storeData.province != "" &&
                                          _storeData.district != "" &&
                                          _storeData.subDistrict != "") {
                                        _processIndex = (_processIndex + 1) %
                                            _processes.length;
                                      }
                                    });
                                  }();
                                case 3:
                                  return () {
                                    _loadStoreFromStorage().then((_) {});
                                    // postData();
                                  }();
                                default:
                                  return print('error');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.successButtonColor,
                              padding: EdgeInsets.symmetric(
                                  vertical: screenWidth / 80,
                                  horizontal: screenWidth / 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                                _processIndex == 3
                                    ? "store.processtimeline_screen.submit_button"
                                        .tr()
                                    : "store.processtimeline_screen.next_button"
                                        .tr(),
                                style: Styles.white18(context)),
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
    );
  }
}

/// hardcoded bezier painter
/// TODO: Bezier curve into package component
class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}
