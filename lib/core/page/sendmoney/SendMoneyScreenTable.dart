import 'dart:io';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld2.dart';
import 'package:_12sale_app/core/components/table/ReusableTable.dart';
import 'package:_12sale_app/core/components/table/SendmoneyTable.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/sendmoney/SendmoneyTable.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

class SendMoneyScreenTable extends StatefulWidget {
  const SendMoneyScreenTable({super.key});

  @override
  State<SendMoneyScreenTable> createState() => _SendMoneyScreenTableState();
}

class _SendMoneyScreenTableState extends State<SendMoneyScreenTable> {
  String storeImagePath = "";
  double sendMoney = 0;
  double totalMoney = 0;
  String status = "";
  String date =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}${DateFormat('dd').format(DateTime.now())}";
  TextEditingController countController = TextEditingController();
  List<List<String>> filteredRows = [];
  List<List<String>> rows = [];
  List<String> footerTable = [];

  @override
  void initState() {
    super.initState();
    _getSendmoneyTable();
  }

  bool isDouble(String input) {
    return double.tryParse(input) != null;
  }

  Future<void> _getSendmoneyTable() async {
    try {
      context.loaderOverlay.show();
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/order/summaryDaily?area=${User.area}',
        method: 'GET',
      );
      print("Response: $response");
      if (response.statusCode == 200) {
        footerTable = [
          '',
          'รวมจำนวนเงิน',
          '${response.data['sumSendMoney']}',
          '${response.data['sumSummary']}',
          '${response.data['sumSummaryDif']}',
          '${response.data['sumGood']}',
          '${response.data['sumDamaged']}',
          '${response.data['sumChange']}',
        ];
        final fetchedStocks = (response.data['data'] as List)
            .map((item) => SendmoneyTable.fromJson(item))
            .toList();

        // Map เป็น List<List<String>>
        final mappedRows = fetchedStocks
            .map((e) => [
                  e.date,
                  e.status,
                  e.sendmoney.toString(),
                  e.summary.toString(),
                  e.diff.toString(),
                  e.good.toString(),
                  e.damaged.toString(),
                  e.change.toString(),
                ])
            .toList();

        setState(() {
          filteredRows = mappedRows;
        });
        context.loaderOverlay.hide();
      }
    } catch (e) {
      print("Error _getSendmoneyTable: $e");
      context.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = [
      'วันที่',
      'สถานะ',
      'ยอดส่งเงิน',
      'ยอดขาย',
      'ส่วนต่าง',
      'คืนดี',
      'คืนเสี่ย',
      'เปลี่ยน',
    ];
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
            Expanded(
              child: SendmoneyTableShow(
                columns: columns,
                rows: filteredRows,
                footer: footerTable,
              ),
            ),
          ],
        ),
      )),
    );
  }
}
