import 'dart:io';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/button/ShowPhotoButton.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld2.dart';
import 'package:_12sale_app/core/components/table/ReusableTable.dart';
import 'package:_12sale_app/core/components/table/SaleReportTable.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/sendmoney/SendMoneyScreenTable.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/sendmoney/SaleReport.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/sockertService.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class SendMoneyScreen extends StatefulWidget {
  final String date;
  final DateTime dateTime;

  const SendMoneyScreen({
    super.key,
    required this.date,
    required this.dateTime,
  });

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  String storeImagePath = "";
  double sendMoney = 0;
  double different = 0;
  double money = 0;
  double summary = 0;
  double grandTotal = 0;

  // เก็บ summary จาก API (Map<String, dynamic>)
  Map<String, dynamic> summaryType = {
    'sale': {'count': 0, 'total': 0},
    'change': {'count': 0, 'total': 0},
    'refund': {'count': 0, 'total': 0},
  };

  // ---------- Helpers ปลอดภัยจาก null ----------
  int getCount(String key) {
    final m = summaryType[key] as Map<String, dynamic>?;
    final v = m?['count'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  double getTotal(String key) {
    final m = summaryType[key] as Map<String, dynamic>?;
    final v = m?['total'];
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0.0;
  }

  String status = "";
  late SocketService socketService;

  List<List<String>> rows = [];

  // String date =
  //     "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}${DateFormat('dd').format(DateTime.now())}";
  TextEditingController countController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getSendmoney();
    _getSaleReport();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    socketService = Provider.of<SocketService>(context, listen: false);
  }

  bool isDouble(String input) {
    return double.tryParse(input) != null;
  }

  Future<void> _getSaleReport() async {
    try {
      context.loaderOverlay.show();
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/order/saleReport?area=${User.area}&date=${widget.date}&type=sale',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        setState(() {
          final s = response.data['summary'] as Map<String, dynamic>?;

          summaryType = {
            'sale': (s?['sale'] as Map<String, dynamic>?) ??
                const {'count': 0, 'total': 0},
            'change': (s?['change'] as Map<String, dynamic>?) ??
                const {'count': 0, 'total': 0},
            'refund': (s?['refund'] as Map<String, dynamic>?) ??
                const {'count': 0, 'total': 0},
          };

          grandTotal = (response.data['grandTotal'] as num?)?.toDouble() ?? 0.0;
        });

        final fetchedStocks = (response.data['data'] as List)
            .map((item) => SaleReport.fromJson(item))
            .toList();

        // Map เป็น List<List<String>>
        final mappedRows = fetchedStocks
            .map((e) => [
                  e.orderId,
                  e.storeId,
                  e.storeName,
                  formatCurrency(e.total),
                  e.paymentMethod,
                  e.type,
                ])
            .toList();
        print(mappedRows);

        setState(() {
          rows = mappedRows;
        });
      }

      // final fetchedStocks = (response.data['data'] as List)
      //     .map((item) => SendmoneyTable.fromJson(item))
      //     .toList();

      // // Map เป็น List<List<String>>
      // final mappedRows = fetchedStocks
      //     .map((e) => [
      //           e.date,
      //           e.status,
      //           e.sendmoney.toString(),
      //           e.summary.toString(),
      //           e.good.toString(),
      //           e.damaged.toString(),
      //           e.change.toString(),
      //         ])
      //     .toList();

      // setState(() {
      //   filteredRows = mappedRows;
      // });
      context.loaderOverlay.hide();
    } catch (e) {
      print("Error _getSaleReport: $e");
      context.loaderOverlay.hide();
    }
  }

  String formatCurrency(num value,
      {String locale = 'th_TH', String symbol = '฿'}) {
    final formatter = NumberFormat.currency(locale: locale, symbol: symbol);
    return formatter.format(value);
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
          "date": "${widget.date}",
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
      // print(sendMoney);
      context.loaderOverlay.show();
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/sendmoney/addSendMoney',
        method: 'POST',
        body: {
          "area": "${User.area}",
          "date": "${widget.date}",
          "sendmoney": double.parse(sendMoney),
        },
      );
      if (response.statusCode == 200) {
        socketService.emitEvent('sendmoney/addSendMoney', {
          'message': 'Sendmoney added successfully',
        });
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
        context.loaderOverlay.hide();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SendMoneyScreenTable(),
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
        context.loaderOverlay.hide();
      }
    } catch (e) {
      print("Error _addSendMoney: $e");
      context.loaderOverlay.hide();
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
          "date": "${widget.date}",
        },
      );
      print("Response: $response");
      if (response.statusCode == 200) {
        setState(() {
          String fullPath = response.data['image'][0]['path'];
          sendMoney = response.data['sendmoney'].toDouble().abs();
          different = response.data['different'].toDouble().abs();
          money = response.data['different'].toDouble().abs();
          summary = response.data['summary'].toDouble().abs();
          status = response.data['status'];

          storeImagePath = fullPath.replaceFirst(
              '/var/www/12AppAPI/public', 'https://apps.onetwotrading.co.th');
          countController = TextEditingController(text: different.toString());
        });
      }
    } catch (e) {
      print("Error getSendmoney: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final columns = [
      'เลขออเดอร์',
      'รหัสร้าน',
      'ชื่อร้าน',
      'รวม',
      'ช่องทาง/REF',
      'ประเภท',
    ];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " ส่งเงิน",
          icon: Icons.payments_rounded,
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        "ยอดส่งเงินประจำวันที่ ${DateFormat('d MMMM yyyy', 'dashboard.lange'.tr()).format(widget.dateTime)}",
                        style: Styles.black24(context),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // padding: const EdgeInsets.all(8),
                          elevation: 0, // Disable shadow
                          shadowColor:
                              Colors.transparent, // Ensure no shadow color
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide.none),
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
                                "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(money)}",
                                style: Styles.headerGreen32(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ยอดที่ต้องส่ง",
                              style: Styles.headerRed24(context),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              '${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(different)} บาท',
                              style: Styles.headerRed24(context),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ยอดที่ส่งแล้ว",
                              style: Styles.headerGreen24(context),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              '${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(sendMoney)} บาท',
                              style: Styles.headerGreen24(context),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ยอดรวม",
                              style: Styles.headerGreen24(context),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              '${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(summary)} บาท',
                              style: Styles.headerGreen24(context),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "สถานะ : $status",
                        style: status == 'ส่งเงินแล้ว'
                            ? Styles.headerGreen24(context)
                            : Styles.headerRed24(context),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      storeImagePath != ""
                          ? ShowPhotoButton(
                              checkNetwork: true,
                              label: "ร้านค้า",
                              icon: Icons.image_not_supported_outlined,
                              imagePath: storeImagePath,
                            )
                          : IconButtonWithLabelOld2(
                              icon: Icons.photo_camera,
                              imagePath:
                                  storeImagePath != "" ? storeImagePath : null,
                              label: "ใบเงินฝาก",
                              onImageSelected: (String imagePath) async {
                                setState(() {
                                  storeImagePath = imagePath;
                                });
                              },
                            ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (status != "ส่งเงินแล้ว") {
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
                        // ignore: sort_child_properties_last
                        child: Text(
                          "กดเพื่อส่งเงิน",
                          style: status != "ส่งเงินแล้ว"
                              ? Styles.pirmary18(context)
                              : Styles.grey18(context),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: status != "ส่งเงินแล้ว"
                                  ? Styles.primaryColor
                                  : Colors.grey,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                          height: screenHeight * 0.5,
                          width: screenWidth,
                          child: SaleReportTable(
                            columns: columns,
                            rows: rows,
                            footer: [
                              'ขาย',
                              '${formatCurrency(summaryType['sale']['total'])}',
                              "เปลี่ยน",
                              '${formatCurrency(summaryType['change']['total'])}',
                              "คืน",
                              '${formatCurrency(summaryType['refund']['total'])}',
                            ],
                            footer2: ['รวม', '${formatCurrency(grandTotal)}'],
                          )),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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
      shape: const RoundedRectangleBorder(
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
                          const SizedBox(
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
                                        money = countD.toDouble();
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
