import 'dart:convert';

import 'package:_12sale_app/core/components/alert/Alert.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/PrivacyPolicy.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:location/location.dart';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isChecked = false;
  bool _isCheckboxEnabled = false;
  bool _isCheckboxChecked = false;
  // List<Store> _store = [];
  Store? _storeData;
  String latitude = '';
  String longitude = '';
  PrivacyPolicy? policy; // Use a nullable type

  List<Map<String, dynamic>> bodyPolicy = [];
  final LocationService locationService = LocationService();
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLocation();
    _loadPrivacyPolicy();
    _scrollController.addListener(_onScroll);
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
      CustomAlertDialog.showCommonAlert(context, "แจ้งเตือน !",
          "กรุณาเปิดการใช้งานโลเคชั่นเพื่อทำการเพื่มร้านค้า");
    }
  }

  // void showCommonAlert(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           "แจ้งเตือน !",
  //           style: Styles.headerBlack24(context),
  //         ),
  //         content: Text(
  //           "กรุณาเปิดการใช้งานโลเคชั่นเพื่อทำการเพื่มร้านค้า",
  //           style: Styles.black18(context),
  //         ),
  //         actions: [
  //           TextButton(
  //             child: Text("ตกลง", style: Styles.black18(context)),
  //             onPressed: () async {
  //               Location location = Location();
  //               await location.requestService();
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _loadPrivacyPolicy() async {
    try {
      final String response = await rootBundle.loadString('data/policy.json');
      final Map<String, dynamic> data = json.decode(response);
      setState(() {
        policy = PrivacyPolicy.fromJson(data);
        isLoading = false;
      });

      for (var body in policy!.body) {
        // Add main section number and title as bold
        bodyPolicy.add({
          "text": "${body.number}. ${body.title}",
          "isBold": true,
        });
        // Add main section text with indentation
        bodyPolicy.add({
          "text": "    ${body.text}",
          "isBold": false,
        });

        for (var list in body.list) {
          bodyPolicy.add({
            "text": "    ${list.number} ${list.text}",
            "isBold": false,
          });
          for (var bullet in list.bullet) {
            bodyPolicy.add({
              "text": "          ${bullet}",
              "isBold": false,
            });
          }
        }
      }
      bodyPolicy.add({
        "text": "    ${policy?.footer}",
        "isBold": false,
      });
    } catch (e) {
      print("Error loading privacy policy: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchLocation() async {
    while (true) {
      try {
        // Initialize the location service
        await locationService.initialize();

        // Get latitude and longitude
        double? lat = await locationService.getLatitude();
        double? lon = await locationService.getLongitude();
        if (!mounted) return;
        setState(() {
          latitude = lat.toString();
          longitude = lon.toString();
        });
        print("${latitude}, ${longitude}");
        break; // ได้ค่าแล้ว ออกจาก loop
      } catch (e) {
        // if (mounted) {
        //   setState(() {
        //     latitude = "Error fetching latitude";
        //     longitude = "Error fetching longitude";
        //   });
        // }
        print("⚠️ Error: $e");
        // รอ 1 วินาทีแล้วลองใหม่
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  // double? latitude;
  // double? longitude;

  // Future<void> fetchLocation() async {
  //   try {
  //     // Initialize the location service
  //     await locationService.initialize();

  //     // Get latitude and longitude
  //     double? lat = await locationService.getLatitude();
  //     double? lon = await locationService.getLongitude();

  //     if (!mounted) return;
  //     setState(() {}); // แค่รีเฟรช UI

  //     print("lat=$latitude, lon=$longitude");
  //   } catch (e) {
  //     // กรณี exception (เช่น user กดยกเลิก permission)
  //     rethrow; // ส่ง error กลับไป ไม่เซ็ตค่าเป็น string
  //   }
  // }

  late final TextEditingController _controller = TextEditingController(
      text: "${bodyPolicy.join("\n")} \n    ${policy?.footer}");
  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Check if the user has scrolled to the bottom
  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isCheckboxEnabled = true; // Enable the checkbox
      });
    }
  }

  Future<void> _saveStoreToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert Store object to JSON string
    String jsonStoreString = json.encode(_storeData!.toJson());

    // Save the JSON string list to SharedPreferences
    await prefs.setString('add_store', jsonStoreString);
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (policy == null) {
      return const Center(child: Text("Failed to load policy."));
    }

    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Text('store.store_policy.title', style: Styles.headerBlack24(context))
              .tr(),
          SizedBox(height: 8),
          Text(
            '${policy?.header}',
            style: Styles.black18(context),
          ),
          SizedBox(height: 16),
          // Store Information (scrollable container)

          // Scrollable TextField with Scrollbar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Styles.primaryColor,
                    width: 1,
                  )),
              child: Scrollbar(
                thumbVisibility: true, // Make scrollbar visible while scrolling
                controller: _scrollController, // Controller for scrolling
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: bodyPolicy.map((line) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8.0,
                            left: 8,
                            right: 8), // Add space between lines
                        child: Text(
                          line["text"],
                          style: line["isBold"]
                              ? Styles.black18(context)
                                  .copyWith(fontWeight: FontWeight.bold)
                              : Styles.black18(context),
                        ),
                      );
                    }).toList(),
                  ),

                  // TextField(
                  //   readOnly: true,
                  //   controller: _controller,
                  //   style: Styles.black18(context),
                  //   maxLines:
                  //       null, // Allows the text field to expand vertically
                  //   keyboardType: TextInputType.multiline,
                  //   decoration: const InputDecoration(
                  //     border: InputBorder.none,
                  //     contentPadding: EdgeInsets.all(16),
                  //   ),
                  // ),
                ),
              ),
            ),
          ),
          // Checkbox with label
          Row(
            children: [
              Checkbox(
                value: _isCheckboxChecked,
                onChanged: _isCheckboxEnabled
                    ? (value) async {
                        // print("${DateTime.now()}");
                        await fetchLocation();
                        if (await Permission
                            .locationWhenInUse.serviceStatus.isEnabled) {
                          setState(() {
                            _isCheckboxChecked = value ?? false;
                            _storeData ??= Store(
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
                              latitude: latitude,
                              longitude: longitude,
                              lineId: "",
                              note: "",
                              approve: Approve(
                                dateSend: "",
                                dateAction: "",
                                appPerson: "",
                              ),
                              status: "",
                              policyConsent:
                                  PolicyConsent(status: "", date: ""),
                              imageList: [],
                              shippingAddress: [],
                              createdDate: "",
                              updatedDate: "",
                            );

                            // Update only the policyConsent field using copyWith
                            _storeData = _storeData?.copyWith(
                              policyConsent: PolicyConsent(
                                status: 'Agree',
                                date: DateTime.now().toString(),
                              ),
                            );
                            print(" Save ${latitude}, ${longitude}");
                          });
                          _saveStoreToStorage();
                        } else {
                          CustomAlertDialog.showCommonAlert(
                              context,
                              "แจ้งเตือน !",
                              "กรุณาเปิดการใช้งานโลเคชั่นเพื่อทำการเพื่มร้านค้า");
                        }
                      }
                    : null,
              ),
              Text(
                'store.store_policy.verify_policy'.tr(),
                style: GoogleFonts.kanit(
                  textStyle: TextStyle(
                    fontSize: screenWidth / 35,
                    fontWeight: FontWeight.w600,
                    color: _isCheckboxEnabled ? Colors.black : Colors.grey,
                  ),
                ), //, // Disable the text as well
              ),
            ],
          ),
        ],
      ),
    );
  }
}
