import 'dart:convert';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/button/IconButtonWithLabel.dart';
import 'package:_12sale_app/core/components/button/ShowPhotoButton.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchCustom.dart';
import 'package:_12sale_app/core/page/store/ProcessTimelineScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _editStore() async {
    Dio dio = Dio();
    final String apiUrl = Uri.https(
      'f8c3-171-103-242-50.ngrok-free.app',
      '/api/cash/store/editStore/${widget.store.storeId}',
    ).toString();

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
        // setState(() {
        //   widget.store.name = storeNameController.text;
        // });
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

  Future<void> _loadImage() async {}

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
      appBar: const PreferredSize(
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    // border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.store,
                                  size: 40,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "ข้อมูลร้านค้า",
                                  style: Styles.black24(context),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: BoxShadowCustom(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Styles.successButtonColor),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.login,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "เช็คอิน",
                                            style: Styles.white18(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth / 40,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      onEdit =
                                          !onEdit; // Toggle the value of onEdit
                                    });
                                    if (onEdit) {
                                      _editStore();
                                    }
                                  },
                                  child: BoxShadowCustom(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: onEdit
                                              ? Styles.primaryColor
                                              : Styles.successButtonColor),
                                      child: Row(
                                        children: [
                                          Icon(
                                            onEdit
                                                ? Icons.edit
                                                : Icons.save_outlined,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            onEdit ? "แก้ไข" : "บันทึก",
                                            style: Styles.white18(context),
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
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Container(
                                  color:
                                      onEdit ? Colors.grey[200] : Colors.white,
                                  child: DropdownSearchCustom<RouteStore>(
                                    enabled: onEdit,
                                    initialSelectedValue:
                                        widget.initialSelectedRoute.route == ''
                                            ? null
                                            : widget.initialSelectedRoute,
                                    label: "รูท",
                                    titleText: "รูท",
                                    icon: Icon(Icons.route_outlined),
                                    fetchItems: (filter) => getRoutes(filter),
                                    onChanged: (RouteStore? selected) async {
                                      if (selected != null) {
                                        setState(() {
                                          widget.initialSelectedRoute =
                                              RouteStore(route: selected.route);
                                          selectedRoute = selected.route;
                                        });
                                      }
                                    },
                                    itemAsString: (RouteStore data) =>
                                        data.route,
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
                            '${widget.store.address} ${widget.store.province != 'กรุงเทพมหานคร' ? 'ต.' : 'แขวง'}${widget.store.subDistrict} ${widget.store.province != 'กรุงเทพมหานคร' ? 'อ.' : 'เขต'}${widget.store.district} ${widget.store.province != 'กรุงเทพมหานคร' ? 'จ.' : ''}${widget.store.province} ${widget.store.postcode}',
                            Icons.location_on_rounded,
                            storeAddressController),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            onEdit
                                ? ShowPhotoButton(
                                    checkNetwork: true,
                                    label: "ร้านค้า",
                                    icon: Icons.image_not_supported_outlined,
                                    imagePath: widget.store.imageList.isNotEmpty
                                        ? (widget.store.imageList
                                                .where((image) =>
                                                    image.type == "store")
                                                .isNotEmpty
                                            ? widget.store.imageList
                                                .where((image) =>
                                                    image.type == "store")
                                                .last
                                                .path
                                            : null)
                                        : null,
                                  )
                                : IconButtonWithLabel(
                                    label: "ร้านค้า",
                                    icon: Icons.photo_camera,
                                    imagePath: widget.store.imageList.isNotEmpty
                                        ? (widget.store.imageList
                                                .where((image) =>
                                                    image.type == "store")
                                                .isNotEmpty
                                            ? widget.store.imageList
                                                .where((image) =>
                                                    image.type == "store")
                                                .last
                                                .path
                                            : null)
                                        : null,
                                    onImageSelected: (String imagePath) async {
                                      final newImage = ImageItem(
                                          name: imagePath,
                                          path: imagePath,
                                          type: "store");
                                      widget.store.imageList.add(newImage);
                                    },
                                  ),
                            onEdit
                                ? ShowPhotoButton(
                                    checkNetwork: true,
                                    label: "ร้านค้า",
                                    icon: Icons.image_not_supported_outlined,
                                    imagePath: widget.store.imageList.isNotEmpty
                                        ? (widget.store.imageList
                                                .where((image) =>
                                                    image.type == "tax")
                                                .isNotEmpty
                                            ? widget.store.imageList
                                                .where((image) =>
                                                    image.type == "tax")
                                                .last
                                                .path
                                            : null)
                                        : null,
                                  )
                                : IconButtonWithLabel(
                                    label: "ภ.พ.20",
                                    icon: Icons.photo_camera,
                                    imagePath: widget.store.imageList.isNotEmpty
                                        ? (widget.store.imageList
                                                .where((image) =>
                                                    image.type == "tax")
                                                .isNotEmpty
                                            ? widget.store.imageList
                                                .where((image) =>
                                                    image.type == "tax")
                                                .last
                                                .path
                                            : null)
                                        : null,
                                    onImageSelected: (String imagePath) async {
                                      final newImage = ImageItem(
                                          name: imagePath,
                                          path: imagePath,
                                          type: "tax");

                                      widget.store.imageList.add(newImage);
                                    },
                                  ),
                            onEdit
                                ? ShowPhotoButton(
                                    checkNetwork: true,
                                    label: "สำเนาบัตรปปช.",
                                    icon: Icons.image_not_supported_outlined,
                                    imagePath: widget.store.imageList.isNotEmpty
                                        ? (widget.store.imageList
                                                .where((image) =>
                                                    image.type == "person")
                                                .isNotEmpty
                                            ? widget.store.imageList
                                                .where((image) =>
                                                    image.type == "person")
                                                .last
                                                .path
                                            : null)
                                        : null,
                                  )
                                : IconButtonWithLabel(
                                    label: "สำเนาบัตรปปช.",
                                    icon: Icons.photo_camera,
                                    imagePath: widget.store.imageList.isNotEmpty
                                        ? (widget.store.imageList
                                                .where((image) =>
                                                    image.type == "person")
                                                .isNotEmpty
                                            ? widget.store.imageList
                                                .where((image) =>
                                                    image.type == "person")
                                                .last
                                                .path
                                            : null)
                                        : null,
                                    onImageSelected: (String imagePath) async {
                                      final newImage = ImageItem(
                                          name: imagePath,
                                          path: imagePath,
                                          type: "person");
                                      widget.store.imageList.add(newImage);
                                    },
                                  ),
                          ],
                        )
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
