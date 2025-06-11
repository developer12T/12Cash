import 'dart:io';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld2.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  String storeImagePath = "";
  double sendMoney = 0;
  double totalMoney = 0;
  String status = "";
  String date =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}${DateFormat('dd').format(DateTime.now())}";
  TextEditingController countController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getSendmoney();
  }

  bool isDouble(String input) {
    return double.tryParse(input) != null;
  }

  Future<void> uploadImageSendmoney() async {
    try {
      Dio dio = Dio();
      final MultipartFile imageFile =
          await MultipartFile.fromFile(storeImagePath);
      var formData = FormData.fromMap(
        {
          'sendmoneyImage': imageFile,
          'area': "${User.area}",
          "date": "${date}"
        },
      );

      var response = await dio.post(
        '${ApiService.apiHost}/api/cash/sendmoney/addSendMoneyImage',
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
      }
    } catch (e) {
      print("Error uploadImageSendmoney: $e");
    }
  }

  Future<void> _addSendMoney(sendMoney) async {
    try {
      print(sendMoney);
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/sendmoney/addSendMoney',
        method: 'POST',
        body: {
          "area": "${User.area}",
          "date": "${date}",
          "sendmoney": double.parse(sendMoney),
        },
      );
      if (response.statusCode == 200) {
        await _getSendmoney();
        await uploadImageSendmoney();
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "ส่งเงินสําเร็จ",
            style: Styles.green18(context),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              index: 0,
            ),
          ),
          (route) => route.isFirst,
        );
      } else {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.red,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: Text(
            "เกิดข้อผิดพลาด",
            style: Styles.green18(context),
          ),
        );
      }
    } catch (e) {
      print("Error _addSendMoney: $e");
    }
  }

  Future<void> _getSendmoney() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/sendmoney/getSendMoney',
        method: 'POST',
        body: {
          "area": "${User.area}",
          "date": "${date}",
        },
      );
      print("Response: $response");
      if (response.statusCode == 200) {
        setState(() {
          sendMoney = response.data['sendmoney'].toDouble();
          totalMoney = response.data['sendmoney'].toDouble();
          status = response.data['status'];
          countController = TextEditingController(text: sendMoney.toString());
        });
      }
    } catch (e) {
      print("Error getSendmoney: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " ส่งเงิน",
          icon: Icons.payments_rounded,
        ),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ยอดส่งเงินประจำวันที่ ${DateFormat('d MMMM yyyy', 'dashboard.lange'.tr()).format(DateTime.now())}",
              style: Styles.black24(context),
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // padding: const EdgeInsets.all(8),
                elevation: 0, // Disable shadow
                shadowColor: Colors.transparent, // Ensure no shadow color
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, side: BorderSide.none),
              ),
              onPressed: () {
                setState(() {
                  // count = 1;
                });
                _showCountSheet(
                  context,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                width: 200,
                height: 75,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(totalMoney)}",
                      style: Styles.headerGreen32(context),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(sendMoney)}",
              style: Styles.headerGreen32(context),
              textAlign: TextAlign.end,
            ),
            Text(
              "สถานะ : $status",
              style: status == 'ส่งเงินครบ'
                  ? Styles.headerGreen24(context)
                  : Styles.headerRed24(context),
              textAlign: TextAlign.end,
            ),
            SizedBox(
              height: 16,
            ),
            IconButtonWithLabelOld2(
              icon: Icons.photo_camera,
              imagePath: storeImagePath != "" ? storeImagePath : null,
              label: "ใบเงินฝาก",
              onImageSelected: (String imagePath) async {
                setState(() {
                  storeImagePath = imagePath;
                });
              },
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                if (status != "ส่งเงินครบ") {
                  if (storeImagePath != '') {
                    _addSendMoney(countController.text);
                  } else {
                    toastification.show(
                      autoCloseDuration: const Duration(seconds: 5),
                      context: context,
                      primaryColor: Colors.red,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flatColored,
                      title: Text(
                        "กรุณาถ่ายรูปการส่งเงิน",
                        style: Styles.red18(context),
                      ),
                    );
                  }
                }
              },
              child: Text(
                "กดเพื่อส่งเงิน",
                style: status != "ส่งเงินครบ"
                    ? Styles.pirmary18(context)
                    : Styles.grey18(context),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: status != "ส่งเงินครบ"
                        ? Styles.primaryColor
                        : Colors.grey,
                    width: 1,
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  void _showCountSheet(
    BuildContext context,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height and scrolling
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            expand: false, // Allows dragging but does not expand fully
            initialChildSize: 0.6, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                width: screenWidth * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Styles.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('ใส่จำนวน', style: Styles.white24(context)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            autofocus: true,
                            style: Styles.black18(context),
                            controller: countController,
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(8),
                                    elevation: 0, // Disable shadow
                                    shadowColor: Colors
                                        .transparent, // Ensure no shadow color
                                    backgroundColor: Styles.primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide.none),
                                  ),
                                  onPressed: () {
                                    if (isDouble(countController.text)) {
                                      // if(countController.text.toDouble())
                                      setState(() {
                                        double countD =
                                            countController.text.toDouble();
                                        totalMoney = countD.toDouble();
                                      });
                                      Navigator.pop(context);
                                    } else {
                                      toastification.show(
                                        autoCloseDuration:
                                            const Duration(seconds: 5),
                                        context: context,
                                        primaryColor: Colors.red,
                                        type: ToastificationType.error,
                                        style: ToastificationStyle.flatColored,
                                        title: Text(
                                          "กรุณาใส่จำนวนให้ถูกต้อง",
                                          style: Styles.red18(context),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "ตกลง",
                                    style: Styles.white18(context),
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
              );
            },
          );
        });
      },
    );
  }
}
