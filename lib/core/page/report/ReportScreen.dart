import 'dart:async';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/card/order/InvoiceCard.dart';
import 'package:_12sale_app/core/components/refund/RefundCard.dart';
import 'package:_12sale_app/core/page/order/OrderDetail.dart';
import 'package:_12sale_app/core/page/refund/RefundDetailScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/RefundFilter.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/OrderDetail.dart';
import 'package:_12sale_app/data/models/order/Orders.dart';
import 'package:_12sale_app/data/models/refund/RefundOrder.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Orders> orders = [];
  List<RefundOrder> refundOrders = [];
  bool _loadingStore = true;
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";
  // String period = "202502";
  Future<void> _getRefundOrder() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/refund/all?type=refund&area=${User.area}&period=${period}', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      print("Data ${response.data['data']}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        Timer(Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              refundOrders =
                  data.map((item) => RefundOrder.fromJson(item)).toList();
            });
          }
        });
      }
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> _getOrder() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/order/all?type=sale&area=${User.area}&period=${period}', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      print("Data ${response.data['data']}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loadingStore = false;
              orders = data.map((item) => Orders.fromJson(item)).toList();
            });
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // _loadStoreData();
    _getOrder();
    _getRefundOrder();

    // _pagingController.addPageRequestListener((pageKey) {
    //   _fetchPage(pageKey);
    // });
    // requestLocation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelect = Provider.of<RefundfilterLocal>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
          Colors.transparent, // set scaffold background color to transparent
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: EdgeInsets.only(top: 20),
          // child: Container(
          //   padding: const EdgeInsets.all(8),
          //   margin: EdgeInsets.all(screenWidth / 45),
          //   width: screenWidth,
          //   // color: Colors.red,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Text(
          //         "ยังไม่เปิดให้บริการ ",
          //         style: Styles.black32(context),
          //       ),
          //     ],
          //   ),
          // ),
          child: isSelect.isSelect == 1
              ? orders.isNotEmpty
                  ? Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 10,
                      radius: Radius.circular(16),
                      child: LoadingSkeletonizer(
                        loading: _loadingStore,
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
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ไม่พบข้อมูล",
                          style: Styles.grey18(context),
                        ),
                      ],
                    )
              : refundOrders.isNotEmpty
                  ? ListView.builder(
                      // controller: _scrollController,
                      itemCount: refundOrders.length,
                      itemBuilder: (context, index) {
                        return RefundCard(
                          item: refundOrders[index],
                          onDetailsPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RefundDetailScreen(
                                    orderId: refundOrders[index].orderId),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ไม่พบข้อมูล",
                          style: Styles.grey18(context),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class ReportHeader extends StatefulWidget {
  const ReportHeader({super.key});

  @override
  State<ReportHeader> createState() => _ReportHeaderState();
}

class _ReportHeaderState extends State<ReportHeader> {
  @override
  Widget build(BuildContext context) {
    final isSelect = Provider.of<RefundfilterLocal>(context);
    print("isSelect.isSelect :${isSelect.isSelect}");
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  // color: Colors.red,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/12TradingLogo.png'),
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                fit: FlexFit.loose,
                child: Center(
                  // margin: EdgeInsets.only(top: 10),

                  child: Column(
                    // mainAxisSize: MainAxisSize.max,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          // color: Colors.blue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.receipt_long_rounded,
                                      size: screenWidth / 15,
                                      color: Colors.white),
                                  Text(
                                    ' รายงานขาย',
                                    style: Styles.headerWhite24(context),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Flexible(
                      //   fit: FlexFit.loose,
                      //   child: Container(
                      //     // width: screenWidth / 3,
                      //     child: const CustomerDropdownSearch(),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Flexible(
          child: CustomSlidingSegmentedControl<int>(
            initialValue: isSelect.isSelect,
            isStretch: true,
            children: {
              1: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.solidFileLines,
                    color: isSelect.isSelect == 1
                        ? Styles.primaryColorIcons
                        : Styles.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'ขาย',
                    style: isSelect.isSelect == 1
                        ? Styles.headerPirmary24(context)
                        : Styles.headerWhite24(context),
                  )
                ],
              ),
              2: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.change_circle_outlined,
                    color: isSelect.isSelect == 2
                        ? Styles.primaryColorIcons
                        : Styles.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'คืน',
                    style: isSelect.isSelect == 2
                        ? Styles.headerPirmary24(context)
                        : Styles.headerWhite24(context),
                  ),
                ],
              )
            },
            onValueChanged: (v) async {
              isSelect.updateValue(v);
              // setState(() {
              //   isSelect.updateValue(v);
              // });
              print(isSelect.isSelect);
              if (v == 1) {
                // await _getDetail(status: "pending");
              } else {
                // await _getDetail(status: "history");
              }
            },
            decoration: BoxDecoration(
              color: Styles.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            thumbDecoration: BoxDecoration(
              color: Styles.white,
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
      ],
    );
  }
}
