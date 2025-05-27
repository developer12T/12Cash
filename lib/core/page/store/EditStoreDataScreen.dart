import 'dart:convert';
import 'dart:io';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/button/MenuButton.dart';
import 'package:_12sale_app/core/components/button/ShowPhotoButton.dart';
import 'package:_12sale_app/core/components/chart/CircularChart.dart';
import 'package:_12sale_app/core/components/chart/ItemSummarize.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchCustom.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/dashboard/DashboardScreen.dart';
import 'package:_12sale_app/core/page/store/DetailStoreScreen.dart';
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
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toastification/toastification.dart';

class EditStoreDataScreen extends StatefulWidget {
  String customerNo;
  String customerName;
  Store store;
  RouteStore initialSelectedRoute;

  EditStoreDataScreen({
    super.key,
    required this.customerNo,
    required this.customerName,
    required this.store,
    required this.initialSelectedRoute,
  });

  @override
  State<EditStoreDataScreen> createState() => _EditStoreDataScreenState();
}

class _EditStoreDataScreenState extends State<EditStoreDataScreen> {
  bool onEdit = false;
  late TextEditingController storeNameController;
  late TextEditingController storePhoneController;
  late TextEditingController storeLineIdController;
  late TextEditingController storeNoteController;
  late TextEditingController storeTaxConroller;
  late TextEditingController storeShoptypeController;
  late TextEditingController storeAddressController;

  List<ImageItem> imageList = [];
  List<ImageItem> imageUpload = [];

  String selectedRoute = "";
  Store editStore = new Store(
      storeId: "",
      name: "",
      taxId: "",
      tel: "",
      route: "",
      type: "",
      typeName: "",
      address: "",
      district: "",
      subDistrict: "",
      province: "",
      provinceCode: "",
      postCode: "",
      zone: "",
      area: "",
      latitude: "",
      longitude: "",
      lineId: "",
      note: "",
      status: "",
      approve: Approve(dateSend: "", dateAction: "", appPerson: ""),
      policyConsent: PolicyConsent(status: "", date: ""),
      imageList: [],
      shippingAddress: [],
      createdDate: "",
      updatedDate: "");
  final LocationService locationService = LocationService();
  String latitude = '';
  String longitude = '';
  double completionPercentage = 220;
  String storeImagePath = "";
  String taxIdImagePath = "";
  String personalImagePath = "";

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
    _setStoreData();
  }

  Future<void> _setStoreData() async {
    setState(() {
      storeNameController.text = widget.store.name;
      storePhoneController.text = widget.store.tel;
      storeLineIdController.text = widget.store.lineId;
      storeNoteController.text = widget.store.note;
      imageList = List<ImageItem>.from(widget.store.imageList);
      for (var value in imageList) {
        if (value.type == "store") {
          setState(() {
            storeImagePath = value.path;
          });
        } else if (value.type == 'tax') {
          setState(() {
            taxIdImagePath = value.path;
          });
        } else {
          setState(() {
            personalImagePath = value.path;
          });
        }
      }
    });
  }

  Future<void> uploadFormDataWithDio(
      String imagePath, String typeImage, BuildContext context) async {
    try {
      final newImage = ImageItem(
        name: imagePath.split('/').last,
        path: imagePath,
        type: typeImage,
      );
      switch (typeImage) {
        case 'store':
          setState(() {
            storeImagePath = imagePath;
          });
          if (imageUpload.length > 0) {
            imageUpload.removeWhere((item) => item.type == 'store');
          }
          imageUpload.add(newImage);
          break;
        case 'tax':
          setState(() {
            taxIdImagePath = imagePath;
          });
          if (imageUpload.any((item) => item.type == 'tax')) {
            imageUpload.removeWhere((item) => item.type == 'tax');
          }
          imageUpload.add(newImage);
          break;
        case 'person':
          setState(() {
            personalImagePath = imagePath;
          });
          if (imageUpload.any((item) => item.type == 'person')) {
            imageUpload.removeWhere((item) => item.type == 'person');
          }
          imageUpload.add(newImage);
          break;
        default:
      }
      print(imageUpload.length);
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
      print('Unexpected error: $e');
    }
  }

  Future<void> _updateImage(BuildContext context) async {
    try {
      List<MultipartFile> imageListUpload = [];
      for (var value in imageUpload) {
        print("Checking path: ${value.path}");

        if (!await File(value.path).exists()) {
          print("❌ File not found: ${value.path}");
          continue; // ข้ามไฟล์ที่ไม่มี
        }

        imageListUpload.add(
          await MultipartFile.fromFile(value.path),
        );
      }
      Dio dio = Dio();
      String type = [
        if (imageUpload.any((item) => item.type == 'store')) 'store',
        if (imageUpload.any((item) => item.type == 'tax')) 'document',
        if (imageUpload.any((item) => item.type == 'person')) 'idCard',
      ].join(',');

      var formData = FormData.fromMap(
        {
          'storeImages': imageListUpload,
          'types': type,
          "storeId": widget.store.storeId
        },
      );
      // print(formData);
      // print(imageList);
      // print(type);
      // print(widget.store.storeId);
      var response = await dio.post(
        '${ApiService.apiHost}/api/cash/store/updateImage',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            'x-channel': 'cash',
          },
        ),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Image uploaded successfully ${response.data}");
        toastification.dismissAll();
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
      print(e);
    }
  }

  Future<void> _editStore(BuildContext context) async {
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
            'x-channel': 'cash',
          },
        ),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            editStore = Store.fromJson(response.data['data']);
          });
        }
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
      print("Error edit Store $e");
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
            title: " แก้ไขร้านค้า", icon: Icons.store_mall_directory_rounded),
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
                          // SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                              // border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.store,
                                            size: 40,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "แก้ไขข้อมูลร้านค้า",
                                            style: Styles.black24(context),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: screenWidth / 40,
                                          ),
                                          GestureDetector(
                                            onTap: () async {
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
                                                  descTextAlign:
                                                      TextAlign.start,
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
                                                    "คุณต้องการแก้ไขข้อมูลร้านค้าใช่หรือไม่ ?",
                                                buttons: [
                                                  DialogButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    color: Styles.failTextColor,
                                                    child: Text(
                                                      "store.processtimeline_screen.alert.cancel"
                                                          .tr(),
                                                      style: Styles.white18(
                                                          context),
                                                    ),
                                                  ),
                                                  DialogButton(
                                                    onPressed: () async {
                                                      await _editStore(context);
                                                      await _updateImage(
                                                          context);
                                                      // if (imageList.length >
                                                      //     0) {
                                                      //   await _updateImage(
                                                      //       context);
                                                      // }
                                                      Navigator
                                                          .pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              HomeScreen(
                                                            index: 2,
                                                          ),
                                                        ),
                                                        (route) => route
                                                            .isFirst, // Keeps only the first route
                                                      );
                                                    },
                                                    color: Styles
                                                        .successButtonColor,
                                                    child: Text(
                                                      "store.processtimeline_screen.alert.submit"
                                                          .tr(),
                                                      style: Styles.white18(
                                                          context),
                                                    ),
                                                  )
                                                ],
                                              ).show();
                                            },
                                            child: BoxShadowCustom(
                                              borderColor: Colors.transparent,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    color: Styles
                                                        .successButtonColor),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.save_outlined,
                                                      size: 40,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "บันทึก",
                                                      style: Styles.white18(
                                                          context),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: screenWidth / 37),
                                  _buildCustomFormField(
                                      'ชื่อร้านค้า',
                                      storeNameController.text,
                                      Icons.store,
                                      storeNameController,
                                      readOnly: onEdit),
                                  _buildCustomFormField(
                                      'เลขประจำตัวผู้เสียภาษี',
                                      '${widget.store.taxId}',
                                      Icons.person_outline,
                                      storeTaxConroller),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCustomFormField(
                                            max: 10,
                                            'โทรศัพท์',
                                            '${storePhoneController.text}',
                                            Icons.phone,
                                            storePhoneController,
                                            keypadType: TextInputType.number,
                                            readOnly: onEdit),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child: Container(
                                            color: true
                                                ? Colors.grey[200]
                                                : Colors.white,
                                            child: DropdownSearchCustom<
                                                RouteStore>(
                                              enabled: true,
                                              initialSelectedValue: widget
                                                          .initialSelectedRoute
                                                          .route ==
                                                      ''
                                                  ? null
                                                  : widget.initialSelectedRoute,
                                              label: "รูท",
                                              titleText: "รูท",
                                              icon: Icon(Icons.route_outlined),
                                              fetchItems: (filter) =>
                                                  getRoutes(filter),
                                              onChanged:
                                                  (RouteStore? selected) async {
                                                if (selected != null) {
                                                  setState(() {
                                                    widget.initialSelectedRoute =
                                                        RouteStore(
                                                            route:
                                                                selected.route);
                                                    selectedRoute =
                                                        selected.route;
                                                  });
                                                }
                                              },
                                              itemAsString: (RouteStore data) =>
                                                  data.route,
                                              itemBuilder:
                                                  (context, item, isSelected) {
                                                return Column(
                                                  children: [
                                                    ListTile(
                                                      title: Text(
                                                        " ${item.route}",
                                                        style: Styles.black18(
                                                            context),
                                                      ),
                                                      selected: isSelected,
                                                    ),
                                                    Divider(
                                                      color: Colors.grey[
                                                          200], // Color of the divider line
                                                      thickness:
                                                          1, // Thickness of the line
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
                                        ),
                                      ),
                                    ],
                                  ),
                                  _buildCustomFormField(
                                      'ไลน์',
                                      storeLineIdController.text,
                                      Icons.alternate_email,
                                      storeLineIdController,
                                      readOnly: onEdit),
                                  _buildCustomFormField(
                                      'ประเภทร้านค้า',
                                      '${widget.store.typeName}',
                                      Icons.store_mall_directory,
                                      storeShoptypeController),
                                  _buildCustomFormField(
                                      'หมายเหตุ',
                                      storeNoteController.text,
                                      Icons.note,
                                      storeNoteController,
                                      readOnly: onEdit),
                                  // SizedBox(height: screenWidth / 37),
                                  _buildCustomFormField(
                                      'ที่อยู่',
                                      '${widget.store.address} ${widget.store.province != 'กรุงเทพมหานคร' ? 'ต.' : 'แขวง'}${widget.store.subDistrict} ${widget.store.province != 'กรุงเทพมหานคร' ? 'อ.' : 'เขต'}${widget.store.district} ${widget.store.province != 'กรุงเทพมหานคร' ? 'จ.' : ''}${widget.store.province} ${widget.store.postCode}',
                                      Icons.location_on_rounded,
                                      storeAddressController),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      widget.store.imageList
                                              .where((image) =>
                                                  image.type == "store")
                                              .isNotEmpty
                                          ? ShowPhotoButton(
                                              checkNetwork: true,
                                              label: "ร้านค้า",
                                              icon: Icons
                                                  .image_not_supported_outlined,
                                              imagePath: widget.store.imageList
                                                      .isNotEmpty
                                                  ? (widget.store.imageList
                                                          .where((image) =>
                                                              image.type ==
                                                              "store")
                                                          .isNotEmpty
                                                      ? "${ApiService.apiHost}/images/${widget.store.imageList.where((image) => image.type == "store").last.path.split("images").last}"
                                                      : null)
                                                  : null,
                                            )
                                          : IconButtonWithLabelOld(
                                              icon: Icons.photo_camera,
                                              imagePath: storeImagePath != ""
                                                  ? storeImagePath
                                                  : null,
                                              label: "ร้านค้า",
                                              onImageSelected:
                                                  (String imagePath) async {
                                                await uploadFormDataWithDio(
                                                    imagePath,
                                                    'store',
                                                    context);
                                              },
                                            ),
                                      widget.store.imageList
                                              .where((image) =>
                                                  image.type == "document")
                                              .isNotEmpty
                                          ? ShowPhotoButton(
                                              checkNetwork: true,
                                              label: "ภ.พ.20",
                                              icon: Icons
                                                  .image_not_supported_outlined,
                                              imagePath: widget.store.imageList
                                                      .isNotEmpty
                                                  ? (widget.store.imageList
                                                          .where((image) =>
                                                              image.type ==
                                                              "document")
                                                          .isNotEmpty
                                                      ? "${ApiService.apiHost}/images/${widget.store.imageList.where((image) => image.type == "document").last.path.split("images").last}"
                                                      : null)
                                                  : null,
                                            )
                                          : IconButtonWithLabelOld(
                                              icon: Icons.photo_camera,
                                              imagePath: taxIdImagePath != ""
                                                  ? taxIdImagePath
                                                  : null,
                                              label: "ภ.พ.20",
                                              onImageSelected:
                                                  (String imagePath) async {
                                                await uploadFormDataWithDio(
                                                    imagePath, 'tax', context);
                                              },
                                            ),
                                      widget.store.imageList
                                              .where((image) =>
                                                  image.type == "idCard")
                                              .isNotEmpty
                                          ? ShowPhotoButton(
                                              checkNetwork: true,
                                              label: "สำเนาบัตรปปช.",
                                              icon: Icons
                                                  .image_not_supported_outlined,
                                              imagePath: widget.store.imageList
                                                      .isNotEmpty
                                                  ? (widget.store.imageList
                                                          .where((image) =>
                                                              image.type ==
                                                              "idCard")
                                                          .isNotEmpty
                                                      ? "${ApiService.apiHost}/images/${widget.store.imageList.where((image) => image.type == "idCard").last.path.split("images").last}"
                                                      : null)
                                                  : null,
                                            )
                                          : IconButtonWithLabelOld(
                                              icon: Icons.photo_camera,
                                              imagePath: personalImagePath != ""
                                                  ? personalImagePath
                                                  : null,
                                              label:
                                                  "store.store_data_screen.image_identify"
                                                      .tr(),
                                              onImageSelected:
                                                  (String imagePath) async {
                                                await uploadFormDataWithDio(
                                                    imagePath,
                                                    'person',
                                                    context);
                                              },
                                            ),
                                    ],
                                  )
                                ],
                              ),
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
