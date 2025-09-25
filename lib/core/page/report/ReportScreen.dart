import 'dart:async';
import 'package:_12sale_app/core/components/DateFilterType.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/card/cart/CartCard.dart';
import 'package:_12sale_app/core/components/card/order/CartCard.dart';
import 'package:_12sale_app/core/components/card/order/InvoiceCard.dart';
import 'package:_12sale_app/core/components/refund/RefundCard.dart';
import 'package:_12sale_app/core/page/giveaways/GiveAwaysDetailScreen.dart';
import 'package:_12sale_app/core/page/order/OrderDetail.dart';
import 'package:_12sale_app/core/page/refund/RefundDetailScreen.dart';
import 'package:_12sale_app/core/page/withdraw/PrinterGiveAwaysScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/CartAll.dart';
import 'package:_12sale_app/data/models/RefundFilter.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/Cart.dart';
import 'package:_12sale_app/data/models/order/OrderDetail.dart';
import 'package:_12sale_app/data/models/order/Orders.dart';
import 'package:_12sale_app/data/models/refund/RefundOrder.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/sockertService.dart';
import 'package:_12sale_app/main.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import '../withdraw/PrintWithdraw.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with RouteAware {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();
  List<Orders> orders = [];
  List<RefundOrder> refundOrders = [];
  List<CartAll> cartList = [];
  bool _loadingOrder = true;
  bool _loadingRefund = true;
  bool _loadingCart = true;
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  final ScrollController _cartScrollController = ScrollController();
  String yyyymmdd(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
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
        refundOrders.clear();
        final List<dynamic> data = response.data['data'];
        Timer(Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loadingRefund = false;
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
        orders.clear();
        final List<dynamic> data = response.data['data'];
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loadingOrder = false;
              orders = data.map((item) => Orders.fromJson(item)).toList();
            });
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getRefundOrderDate(startDate, endDate) async {
    context.loaderOverlay.show();
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/refund/all?type=refund&area=${User.area}&start=${startDate}&end=${endDate}', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      print("Data ${response.data['data']}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        refundOrders.clear();
        final List<dynamic> data = response.data['data'];

        setState(() {
          _loadingRefund = false;
          refundOrders =
              data.map((item) => RefundOrder.fromJson(item)).toList();
        });
      }
      context.loaderOverlay.hide();
    } on ApiException catch (e) {
      refundOrders.clear();
      context.loaderOverlay.hide();
    } catch (e) {
      refundOrders.clear();
      context.loaderOverlay.hide();
      print("Error $e");
    }
  }

  Future<void> _getOrderDate(startDate, endDate) async {
    context.loaderOverlay.show();
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/order/all?type=sale&area=${User.area}&start=${startDate}&end=${endDate}', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      print("Data ${response.data['data']}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        orders.clear();
        final List<dynamic> data = response.data['data'];
        setState(() {
          _loadingOrder = false;
          orders = data.map((item) => Orders.fromJson(item)).toList();
        });
      }
      context.loaderOverlay.hide();
    } on ApiException catch (e) {
      orders.clear();
      context.loaderOverlay.hide();
    } catch (e) {
      orders.clear();
      context.loaderOverlay.hide();
      print(e);
    }
  }

  Future<void> _getCartAll() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/getAll?area=${User.area}', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      print("Data ${response.data['data']}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loadingCart = false;
              cartList = data.map((item) => CartAll.fromJson(item)).toList();
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
    _getOrder();
    _getRefundOrder();
    _getCartAll();
  }

  @override
  void didPopNext() {
    _getOrder();
    _getRefundOrder();
    _getCartAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final socketService = Provider.of<SocketService>(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (socketService.statusOrderUpdated != '0') {
          // _getOrder();
        }

        if (socketService.refundUpdate != '') {
          _getRefundOrder();
        }
      },
    );

    // Register this screen as a route-aware widget
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Only subscribe if the route is a P ageRoute
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    _cartScrollController.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelect = Provider.of<RefundfilterLocal>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DateFilter(
                  initialType: DateFilterType.day, // day | month | year
                  initialDate: DateTime.now(),
                  onRangeChanged: (range, type) async {
                    // ใช้ range.start และ range.end
                    // ตัวอย่าง: ส่งไป query backend

                    final startDate = yyyymmdd(DateTime(
                        range.start.year, range.start.month, range.start.day));

                    final endDate = yyyymmdd(DateTime(
                        range.end.year, range.end.month, range.end.day));

                    // context.loaderOverlay.show();
                    // await getTarget(startDate, endDate);
                    print('startDate ${startDate} endDate ${endDate}');
                    print('type=$type start=${range.start} end=${range.end}');
                    await _getOrderDate(startDate, endDate);
                    await _getRefundOrderDate(startDate, endDate);

                    // if (isSelect.isSelect == 1) {
                    // } else {}
                    // // context.loaderOverlay.hide();
                  },
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: isSelect.isSelect == 1
                    ? RefreshIndicator(
                        onRefresh: () => _getOrder(),
                        child: LoadingSkeletonizer(
                          loading: _loadingOrder,
                          child: ListView.builder(
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InvoiceCard(
                                  item: orders[index],
                                  onDetailsPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => OrderDetailScreen(
                                            orderId: orders[index].orderId),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : isSelect.isSelect == 2 && refundOrders.isNotEmpty
                        ? RefreshIndicator(
                            onRefresh: () => _getRefundOrder(),
                            child: LoadingSkeletonizer(
                              loading: _loadingRefund,
                              child: ListView.builder(
                                itemCount: refundOrders.length,
                                itemBuilder: (context, index) {
                                  return RefundCard(
                                    item: refundOrders[index],
                                    onDetailsPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RefundDetailScreen(
                                                  orderId: refundOrders[index]
                                                      .orderId),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          )
                        : isSelect.isSelect == 3
                            ? RefreshIndicator(
                                onRefresh: () => _getCartAll(),
                                child: LoadingSkeletonizer(
                                  loading: _loadingCart,
                                  child: ListView.builder(
                                    itemCount: cartList.length,
                                    itemBuilder: (context, index) {
                                      return CartCardCheck(
                                        item: cartList[index],
                                        onDetailsPressed: () {
                                          _showCartSheet(
                                              context, cartList[index]);
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
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartSheet(BuildContext context, CartAll cartlist) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                              Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              Text('ตะกร้าสินค้าที่เลือก',
                                  style: Styles.white24(context)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                              // _getCart();
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: screenHeight * 0.9,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Column(
                            children: [
                              Expanded(
                                  child: Scrollbar(
                                controller: _cartScrollController,
                                thickness: 10,
                                thumbVisibility: true,
                                trackVisibility: true,
                                radius: Radius.circular(16),
                                child: ListView.builder(
                                  controller: _cartScrollController,
                                  itemCount: cartlist.listProduct.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                '${ApiService.image}/images/products/${cartlist.listProduct[index].id}.webp',
                                                width: screenWidth / 8,
                                                height: screenWidth / 8,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    width: screenWidth / 8,
                                                    height: screenWidth / 8,
                                                    color: Colors.grey,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.hide_image,
                                                            color: Colors.white,
                                                            size: 30),
                                                        Text(
                                                          "ไม่มีภาพ",
                                                          style: Styles.white18(
                                                              context),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            cartlist
                                                                .listProduct[
                                                                    index]
                                                                .name,
                                                            style:
                                                                Styles.black16(
                                                                    context),
                                                            softWrap: true,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'id : ${cartlist.listProduct[index].id}',
                                                                  style: Styles
                                                                      .black16(
                                                                          context),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'จำนวน : ${cartlist.listProduct[index].qty.toStringAsFixed(0)} ${cartlist.listProduct[index].unit}',
                                                                  style: Styles
                                                                      .black16(
                                                                          context),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'ราคา : ${cartlist.listProduct[index].price}',
                                                                  style: Styles
                                                                      .black16(
                                                                          context),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.grey[200],
                                          thickness: 1,
                                          indent: 16,
                                          endIndent: 16,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ))
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: Styles.primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("ยอดรวม", style: Styles.white24(context)),
                            Text(
                                "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(cartlist.total)} บาท",
                                style: Styles.white24(context)),
                          ],
                        ),
                      ),
                    )
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
              ),
              3: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: isSelect.isSelect == 3
                        ? Styles.primaryColorIcons
                        : Styles.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'ตะกร้า',
                    style: isSelect.isSelect == 3
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
