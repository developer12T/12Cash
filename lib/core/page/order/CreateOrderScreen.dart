import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabel.dart';
import 'package:_12sale_app/core/page/order/OrderDetail.dart';
import 'package:_12sale_app/core/page/route/OrderDetailScreen.dart';
import 'package:_12sale_app/data/models/order/Promotion.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:_12sale_app/main.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/page/order/CheckoutScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/Cart.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:print_bluetooth_thermal/post_code.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal_windows.dart';
import 'package:toastification/toastification.dart';

class CreateOrderScreen extends StatefulWidget {
  final String? storeName;
  final String? storeId;
  final String? storeAddress;
  CreateOrderScreen({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> with RouteAware {
  final ScrollController _outerController = ScrollController();
  final ScrollController _cartScrollController = ScrollController();
  final ScrollController _promotionScrollController = ScrollController();

  String isSelectCheckout = '';

  bool _loading = true;

  double subtotal = 0;
  double discount = 0;
  double discountProduct = 0;
  double vat = 0;
  double totalExVat = 0;
  double total = 0;

  bool _isInnerAtTop = true;
  bool _isInnerAtBottom = false;
  bool _isCreateOrderEnabled = false;

  @override
  void initState() {
    super.initState();
    _getCart();
    _cartScrollController.addListener(_handleInnerScroll);
    _promotionScrollController.addListener(_handleInnerScroll2);
    _outerController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_outerController.offset >= _outerController.position.maxScrollExtent &&
        !_outerController.position.outOfRange) {
      setState(() {
        _isCreateOrderEnabled = true; // Enable the checkbox
      });
    } else {
      setState(() {
        _isCreateOrderEnabled = false; // Enable the checkbox
      });
    }
  }

  void _onScrollDown() {
    _outerController.animateTo(
      _outerController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    setState(() {
      _isCreateOrderEnabled = false; // Enable the checkbox
    });
  }

  void _handleInnerScroll() {
    if (_cartScrollController.position.atEdge) {
      bool isTop = _cartScrollController.position.pixels == 0;
      bool isBottom = _cartScrollController.position.pixels ==
          _cartScrollController.position.maxScrollExtent;
      setState(() {
        _isInnerAtTop = isTop;
        _isInnerAtBottom = isBottom;
      });
    }
  }

  void _handleInnerScroll2() {
    if (_promotionScrollController.position.atEdge) {
      bool isTop = _promotionScrollController.position.pixels == 0;
      bool isBottom = _promotionScrollController.position.pixels ==
          _promotionScrollController.position.maxScrollExtent;
      setState(() {
        _isInnerAtTop = isTop;
        _isInnerAtBottom = isBottom;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register this screen as a route-aware widget
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Only subscribe if the route is a P ageRoute
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // setState(() {
    //   _loadingRouteVisit = true;
    // });
    // Called when the screen is popped back to
    _getCart();
  }

  @override
  void dispose() {
    // Unsubscribe when the widget is disposed

    routeObserver.unsubscribe(this);
    _cartScrollController.dispose();
    _promotionScrollController.dispose();
    _outerController.dispose();
    _outerController.removeListener(_onScroll);
    _cartScrollController.removeListener(_handleInnerScroll);
    _promotionScrollController.removeListener(_handleInnerScroll2);
    super.dispose();
  }

  List<CartList> cartList = [];
  List<PromotionList> promotionList = [];
  List<PromotionListItem> listPromotions = [];
  final Debouncer _debouncer = Debouncer();
  final Throttler _throttler = Throttler();

  String latitude = '';
  String longitude = '';
  final LocationService locationService = LocationService();

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

  Future<void> _checkOutOrder() async {
    context.loaderOverlay.show();
    try {
      await fetchLocation();
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/order/checkout',
        method: 'POST',
        body: {
          "type": "sale",
          "area": "${User.area}",
          "storeId": "${widget.storeId}",
          "note": "test",
          "latitude": "$latitude",
          "longitude": "$longitude",
          "shipping": "test",
          "payment": "cash"
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
            "สั่งซื้อสำเร็จ",
            style: Styles.green18(context),
          ),
        );
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailScreen(
            orderId: response.data['data']['orderId'],
          ),
        ),
        (route) => route.isFirst, // Keeps only the first route
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => OrderDetailScreen(
      //             orderId: response.data['data']['orderId'],
      //           )),
      // );
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> _getCart() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/get?type=sale&area=${User.area}&storeId=${widget.storeId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'][0]['listProduct'];
        final List<dynamic> data2 = response.data['data'][0]['listPromotion'];
        setState(() {
          if (cartList.length == 0) {
            cartList = data.map((item) => CartList.fromJson(item)).toList();
          }
          promotionList =
              data2.map((item) => PromotionList.fromJson(item)).toList();
          listPromotions.clear();
          for (var promotion in promotionList) {
            for (var item in promotion.listPromotion) {
              listPromotions.add(item);
            }
          }
          subtotal = response.data['data'][0]['subtotal'].toDouble();
          discount = response.data['data'][0]['discount'].toDouble();
          discountProduct =
              response.data['data'][0]['discountProduct'].toDouble();
          vat = response.data['data'][0]['vat'].toDouble();
          totalExVat = response.data['data'][0]['totalExVat'].toDouble();
          total = response.data['data'][0]['total'].toDouble();
        });
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
        });

        // Map cartList to receiptData["items"]
      }
    } catch (e) {
      setState(() {
        cartList = [];
        promotionList = [];
        vat = 0;
        subtotal = 0;
        discount = 0;
        discountProduct = 0;
        totalExVat = 0;
        total = 0;
      });
      print("Error $e");
    }
  }

  Future<void> _deleteCart(CartList cart) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/cart/delete',
        method: 'POST',
        body: {
          "type": "sale",
          "area": "${User.area}",
          "storeId": "${widget.storeId}",
          "id": "${cart.id}",
          "unit": "${cart.unit}"
        },
      );
      if (response.statusCode == 200) {
        await _getCart();

        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "ลบข้อมูลสำเร็จ",
            style: Styles.green18(context),
          ),
        );
      }
      if (cartList.length == 0) {
        Navigator.pop(context);
      }
    } catch (e) {}
  }

  Future<void> _reduceCart(CartList cart) async {
    const duration = Duration(seconds: 1);
    try {
      _debouncer.debounce(
        duration: duration,
        onDebounce: () async {
          ApiService apiService = ApiService();
          await apiService.init();
          var response = await apiService.request(
            endpoint: 'api/cash/cart/reduce',
            method: 'PATCH',
            body: {
              "type": "sale",
              "area": "${User.area}",
              "storeId": "${widget.storeId}",
              "id": "${cart.id}",
              "qty": cart.qty,
              "unit": "${cart.unit}"
            },
          );
          if (response.statusCode == 200) {
            await _getCart();
            toastification.show(
              autoCloseDuration: const Duration(seconds: 5),
              context: context,
              primaryColor: Colors.green,
              type: ToastificationType.success,
              style: ToastificationStyle.flatColored,
              title: Text(
                "แก้ไขข้อมูลสำเร็จ",
                style: Styles.green18(context),
              ),
            );
            // await _getTotalCart(setModalState);
          }
        },
      );
    } catch (e) {
      toastification.show(
        autoCloseDuration: const Duration(seconds: 5),
        context: context,
        primaryColor: Colors.red,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(
          "เกิดข้อผิดพลาด $e",
          style: Styles.red18(context),
        ),
      );
      print("Error $e");
    }
  }

  Future<void> _addCartDu(CartList cart) async {
    const duration = Duration(seconds: 1);
    try {
      _debouncer.debounce(
        duration: duration,
        onDebounce: () async {
          ApiService apiService = ApiService();
          await apiService.init();
          var response = await apiService.request(
            endpoint: 'api/cash/cart/add',
            method: 'POST',
            body: {
              "type": "sale",
              "area": "${User.area}",
              "storeId": "${widget.storeId}",
              "id": "${cart.id}",
              "qty": cart.qty,
              "unit": "${cart.unit}"
            },
          );

          if (response.statusCode == 200) {
            await _getCart();
            toastification.show(
              autoCloseDuration: const Duration(seconds: 5),
              context: context,
              primaryColor: Colors.green,
              type: ToastificationType.success,
              style: ToastificationStyle.flatColored,
              title: Text(
                "เพิ่มลงในตะกร้าสําเร็จ",
                style: Styles.green18(context),
              ),
            );
          }
        },
      );
    } catch (e) {
      print("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: "${widget.storeName}",
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isCreateOrderEnabled
          ? null
          : FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: Styles.primaryColor,
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                _onScrollDown();
              },
            ),
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: _isCreateOrderEnabled
                        ? Styles.primaryColor
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_isCreateOrderEnabled) {
                      AllAlert.customAlert(
                          context,
                          "store.processtimeline_screen.alert.title".tr(),
                          "คุณต้องการจะสั่งซื้อสินค้าใช่หรือไม่ ?",
                          _checkOutOrder);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white),
                              child: Text(
                                "${cartList.length}",
                                style: _isCreateOrderEnabled
                                    ? Styles.headerPirmary18(context)
                                    : Styles.headergrey18(context),
                              ),
                            ),
                            Text(
                              " สั่งซื้อ",
                              style: Styles.headerWhite18(context),
                            ),
                          ],
                        ),
                        Text(
                          "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(total)} บาท",
                          style: Styles.headerWhite18(context),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is OverscrollNotification) {
            if (_isInnerAtTop && notification.overscroll < 0) {
              _outerController
                  .jumpTo(_outerController.offset + notification.overscroll);
            } else if (_isInnerAtBottom && notification.overscroll > 0) {
              _outerController
                  .jumpTo(_outerController.offset + notification.overscroll);
            }
          }
          return false;
        },
        child: ListView(
          controller: _outerController,
          children: [
            Container(
              // color: Colors.amber,
              height: screenHeight * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    BoxShadowCustom(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${widget.storeId}",
                                  style: Styles.black24(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ที่อยู่การจัดส่ง",
                                  style: Styles.black18(context),
                                ),
                                Text(
                                  "แก้ไขที่อยู่",
                                  style: Styles.pirmary18(context),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                        elevation: 0, // Disable shadow
                                        shadowColor: Colors
                                            .transparent, // Ensure no shadow color
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .zero, // No rounded corners
                                          side:
                                              BorderSide.none, // Remove border
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  color: Colors.black,
                                                  size: 30,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    " ${widget.storeAddress}",
                                                    style:
                                                        Styles.grey18(context),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.black,
                                            size: 20,
                                          )
                                        ],
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      flex: 3,
                      child: BoxShadowCustom(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: screenHeight * 0.9,
                            // color: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 16.0,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "รายการที่สั่ง",
                                        style: Styles.black18(context),
                                      ),
                                      Text(
                                        "จำนวน ${cartList.length} รายการ",
                                        style: Styles.black18(context),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                      child: Scrollbar(
                                    controller: _cartScrollController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    thickness: 10,
                                    radius: Radius.circular(16),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      controller: _cartScrollController,
                                      itemCount: cartList.length,
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
                                                    'https://jobbkk.com/upload/employer/0D/53D/03153D/images/202045.webp',
                                                    width: screenWidth / 8,
                                                    height: screenWidth / 8,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Center(
                                                        child: Icon(
                                                          Icons.error,
                                                          color: Colors.red,
                                                          size: 50,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                cartList[index]
                                                                    .name,
                                                                style: Styles
                                                                    .black16(
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
                                                                      'id : ${cartList[index].id}',
                                                                      style: Styles
                                                                          .black16(
                                                                              context),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'จำนวน : ${cartList[index].qty.toStringAsFixed(0)} ${cartList[index].unit}',
                                                                      style: Styles
                                                                          .black16(
                                                                              context),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'ราคา : ${cartList[index].price}',
                                                                      style: Styles
                                                                          .black16(
                                                                              context),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      if (cartList[index]
                                                                              .qty >
                                                                          1) {
                                                                        cartList[index]
                                                                            .qty--;
                                                                      }
                                                                    });
                                                                    await _reduceCart(
                                                                        cartList[
                                                                            index]);
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    shape:
                                                                        const CircleBorder(
                                                                      side: BorderSide(
                                                                          color: Colors
                                                                              .grey,
                                                                          width:
                                                                              1),
                                                                    ), // ✅ Makes the button circular
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white, // Button color
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .remove,
                                                                    size: 24,
                                                                    color: Colors
                                                                        .grey,
                                                                  ), // Example
                                                                ),
                                                                Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16),
                                                                  ),
                                                                  width: 75,
                                                                  child: Text(
                                                                    '${cartList[index].qty.toStringAsFixed(0)}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: Styles
                                                                        .black18(
                                                                      context,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await _addCartDu(
                                                                        cartList[
                                                                            index]);

                                                                    setState(
                                                                        () {
                                                                      cartList[
                                                                              index]
                                                                          .qty++;
                                                                    });
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    shape:
                                                                        const CircleBorder(
                                                                      side: BorderSide(
                                                                          color: Colors
                                                                              .grey,
                                                                          width:
                                                                              1),
                                                                    ), // ✅ Makes the button circular
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white, // Button color
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons.add,
                                                                    size: 24,
                                                                    color: Colors
                                                                        .grey,
                                                                  ), // Example
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await _deleteCart(
                                                                        cartList[
                                                                            index]);

                                                                    setState(
                                                                      () {
                                                                        cartList.removeWhere((item) =>
                                                                            (item.id == cartList[index].id &&
                                                                                item.unit == cartList[index].unit));
                                                                      },
                                                                    );
                                                                    // await _getTotalCart(setModalState);
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    shape:
                                                                        const CircleBorder(
                                                                      side: BorderSide(
                                                                          color: Colors
                                                                              .red,
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white, // Button color
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .delete,
                                                                    size: 24,
                                                                    color: Colors
                                                                        .red,
                                                                  ), // Example
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Container(
                                                //   color: Colors.red,
                                                //   width: 50,
                                                //   height: 100,
                                                //   child: Center(
                                                //     child: Icon(
                                                //       Icons.delete,
                                                //       color: Colors.white,
                                                //       size: 25,
                                                //     ),
                                                //   ),
                                                // ),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              // color: Colors.amber,
              height: screenHeight * 0.9,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BoxShadowCustom(
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "รายการโปรโมชั่น",
                                      style: Styles.black18(context),
                                    ),
                                    Text(
                                      "จำนวน ${promotionList.length} รายการ",
                                      style: Styles.black18(context),
                                    ),
                                  ],
                                ),
                                Expanded(
                                    child: Container(
                                  height:
                                      200, // Set a height to avoid rendering errors
                                  child: Scrollbar(
                                    controller: _promotionScrollController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    radius: Radius.circular(16),
                                    thickness: 10,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(),
                                        controller: _promotionScrollController,
                                        itemCount: listPromotions.length,
                                        itemBuilder: (context, innerIndex) {
                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.network(
                                                      'https://jobbkk.com/upload/employer/0D/53D/03153D/images/202045.webp',
                                                      width: screenWidth / 8,
                                                      height: screenWidth / 8,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const Center(
                                                          child: Icon(
                                                            Icons.error,
                                                            color: Colors.red,
                                                            size: 50,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  listPromotions[
                                                                          innerIndex]
                                                                      .name,
                                                                  style: Styles
                                                                      .black16(
                                                                          context),
                                                                  softWrap:
                                                                      true,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          // Row(
                                                          //   children: [
                                                          //     Expanded(
                                                          //       child: Text(
                                                          //         listPromotions[
                                                          //                 innerIndex]
                                                          //             .proName,
                                                          //         style: Styles
                                                          //             .black16(
                                                          //                 context),
                                                          //         softWrap: true,
                                                          //         maxLines: 2,
                                                          //         overflow:
                                                          //             TextOverflow
                                                          //                 .visible,
                                                          //       ),
                                                          //     ),
                                                          //   ],
                                                          // ),
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
                                                                        '${listPromotions[innerIndex].id}',
                                                                        style: Styles.black16(
                                                                            context),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        '${listPromotions[innerIndex].group} รส${listPromotions[innerIndex].flavour}',
                                                                        style: Styles.black16(
                                                                            context),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Container(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(4),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            1,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16),
                                                                    ),
                                                                    width: 75,
                                                                    child: Text(
                                                                      '${listPromotions[innerIndex].qty.toStringAsFixed(0)} ${listPromotions[innerIndex].unit}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: Styles
                                                                          .black18(
                                                                        context,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      // _showCartSheet(context, cartList);
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      shape:
                                                                          CircleBorder(
                                                                        side: BorderSide(
                                                                            color:
                                                                                Styles.warning!,
                                                                            width: 1),
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white, // Button color
                                                                    ),
                                                                    child: Icon(
                                                                      FontAwesomeIcons
                                                                          .penToSquare,
                                                                      size: 24,
                                                                      color: Styles
                                                                          .warning!,
                                                                    ), // Example
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
                                        }),
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BoxShadowCustom(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "ชำระเงินโดย",
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                        elevation: 0, // Disable shadow
                                        shadowColor: Colors
                                            .transparent, // Ensure no shadow color
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .zero, // No rounded corners
                                          side:
                                              BorderSide.none, // Remove border
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.moneyBill,
                                                color: Styles.primaryColor,
                                                size: 40,
                                              ),
                                              SizedBox(width: 8),
                                              // ClipRRect(
                                              //   borderRadius:
                                              //       BorderRadius.circular(8),
                                              //   child: Image.network(
                                              //     'https://jobbkk.com/upload/employer/0D/53D/03153D/images/202045.webp',
                                              //     width: screenWidth / 15,
                                              //     height: screenWidth / 15,
                                              //     fit: BoxFit.cover,
                                              //     errorBuilder: (context, error,
                                              //         stackTrace) {
                                              //       return const Center(
                                              //         child: Icon(
                                              //           Icons.error,
                                              //           color: Colors.red,
                                              //           size: 50,
                                              //         ),
                                              //       );
                                              //     },
                                              //   ),
                                              // ),
                                              Text(
                                                isSelectCheckout != ""
                                                    ? isSelectCheckout
                                                    : "เงินสด",
                                                style: Styles.grey18(context),
                                              )
                                            ],
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.black,
                                            size: 20,
                                          )
                                        ],
                                      ),
                                      onPressed: () {
                                        _showCheckoutSheet(context);
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //         CheckOutScreen(),
                                        //   ),
                                        // );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "รวมมูลค่าสินค้า",
                                  style: Styles.grey18(context),
                                ),
                                Text(
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(subtotal)} บาท",
                                  style: Styles.grey18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ภาษีมูลค่าเพิ่ม 7% (VAT)",
                                  style: Styles.grey18(context),
                                ),
                                Text(
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(vat)} บาท",
                                  style: Styles.grey18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "รวมมูลค่าสินค้าก่อนหักภาษี",
                                  style: Styles.grey18(context),
                                ),
                                Text(
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(totalExVat)} บาท",
                                  style: Styles.grey18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ส่วนลดท้ายบิล",
                                  style: Styles.red18(context),
                                ),
                                Text(
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(discount)} บาท",
                                  style: Styles.red18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ส่วนลดสินค้า",
                                  style: Styles.red18(context),
                                ),
                                Text(
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(discountProduct)} บาท",
                                  style: Styles.red18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "จำนวนเงินรวมสุทธิ",
                                  style: Styles.green24(context),
                                ),
                                Text(
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(total)} บาท",
                                  style: Styles.green24(context),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  isSelectCheckout == "QR Payment"
                      ? Padding(
                          padding: EdgeInsets.all(8),
                          child: BoxShadowCustom(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButtonWithLabel(
                                        icon: Icons.photo_camera,
                                        // imagePath: storeImagePath != ""
                                        //     ? storeImagePath
                                        //     : null,
                                        label: "ถ่ายภาพการโอน",
                                        onImageSelected:
                                            (String imagePath) async {
                                          // await uploadFormDataWithDio(
                                          //     imagePath, 'store', context);
                                        },
                                      ),
                                      // IconButtonWithLabelFixed(
                                      //   icon: Icons.photo_camera,
                                      //   // imagePath: storeImagePath != ""
                                      //   //     ? storeImagePath
                                      //   //     : null,
                                      //   label: "ถ่ายภาพการโอน",
                                      //   onImageSelected:
                                      //       (String imagePath) async {
                                      //     // await uploadFormDataWithDio(
                                      //     //     imagePath, 'store', context);
                                      //   },
                                      // ),
                                      // IconButtonWithLabelFixed(
                                      //   icon: Icons.photo_camera,
                                      //   // imagePath: storeImagePath != ""
                                      //   //     ? storeImagePath
                                      //   //     : null,
                                      //   label: "ถ่ายภาพการโอน",
                                      //   onImageSelected:
                                      //       (String imagePath) async {
                                      //     // await uploadFormDataWithDio(
                                      //     //     imagePath, 'store', context);
                                      //   },
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartSheet(BuildContext context, List<CartList> cartlist) {
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
                              Text('เปลี่ยนรายการโปรโมชั่น',
                                  style: Styles.white24(context)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _getCart();
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
                                  child: ListView.builder(
                                itemCount: cartlist.length,
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
                                              'https://jobbkk.com/upload/employer/0D/53D/03153D/images/202045.webp',
                                              width: screenWidth / 8,
                                              height: screenWidth / 8,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 50,
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
                                                          cartlist[index].name,
                                                          style: Styles.black16(
                                                              context),
                                                          softWrap: true,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
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
                                                                'id : ${cartlist[index].id}',
                                                                style: Styles
                                                                    .black16(
                                                                        context),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'จำนวน : ${cartlist[index].qty.toStringAsFixed(0)} ${cartlist[index].unit}',
                                                                style: Styles
                                                                    .black16(
                                                                        context),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'ราคา : ${cartlist[index].price}',
                                                                style: Styles
                                                                    .black16(
                                                                        context),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              // setModalState(() {
                                                              //   if (cartlist[
                                                              //               index]
                                                              //           .qty >
                                                              //       1) {
                                                              //     cartlist[
                                                              //             index]
                                                              //         .qty--;
                                                              //   }
                                                              // });
                                                              // await _reduceCart(
                                                              //     cartlist[
                                                              //         index],
                                                              //     setModalState);
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              shape:
                                                                  const CircleBorder(
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                              ), // ✅ Makes the button circular
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              backgroundColor:
                                                                  Colors
                                                                      .white, // Button color
                                                            ),
                                                            child: const Icon(
                                                              Icons.remove,
                                                              size: 24,
                                                              color:
                                                                  Colors.grey,
                                                            ), // Example
                                                          ),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 1,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                            ),
                                                            width: 75,
                                                            child: Text(
                                                              '${cartlist[index].qty.toStringAsFixed(0)}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: Styles
                                                                  .black18(
                                                                context,
                                                              ),
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              // await _addCartDu(
                                                              //     cartlist[
                                                              //         index],
                                                              //     setModalState);

                                                              // setModalState(() {
                                                              //   cartlist[index]
                                                              //       .qty++;
                                                              // });
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              shape:
                                                                  const CircleBorder(
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                              ), // ✅ Makes the button circular
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              backgroundColor:
                                                                  Colors
                                                                      .white, // Button color
                                                            ),
                                                            child: const Icon(
                                                              Icons.add,
                                                              size: 24,
                                                              color:
                                                                  Colors.grey,
                                                            ), // Example
                                                          ),
                                                          ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              // await _deleteCart(
                                                              //     cartlist[
                                                              //         index],
                                                              //     setModalState);

                                                              // setModalState(
                                                              //   () {
                                                              //     cartList.removeWhere((item) => (item
                                                              //                 .id ==
                                                              //             cartlist[index]
                                                              //                 .id &&
                                                              //         item.unit ==
                                                              //             cartlist[index]
                                                              //                 .unit));
                                                              //   },
                                                              // );
                                                              // await _getTotalCart(
                                                              //     setModalState);

                                                              // if (cartList
                                                              //         .length ==
                                                              //     0) {
                                                              //   Navigator.pop(
                                                              //       context);
                                                              // }
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              shape:
                                                                  const CircleBorder(
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red,
                                                                    width: 1),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              backgroundColor:
                                                                  Colors
                                                                      .white, // Button color
                                                            ),
                                                            child: const Icon(
                                                              Icons.delete,
                                                              size: 24,
                                                              color: Colors.red,
                                                            ), // Example
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Container(
                                          //   color: Colors.red,
                                          //   width: 50,
                                          //   height: 100,
                                          //   child: Center(
                                          //     child: Icon(
                                          //       Icons.delete,
                                          //       color: Colors.white,
                                          //       size: 25,
                                          //     ),
                                          //   ),
                                          // ),
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
                                "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(100)} บาท",
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

  void _showCheckoutSheet(BuildContext context) {
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
                              Text('เปลี่ยนวิธีชําระ',
                                  style: Styles.white24(context)),
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
                    Expanded(
                      child: Container(
                        height: screenHeight * 0.9,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(0),
                                          elevation: 0, // Disable shadow
                                          shadowColor: Colors
                                              .transparent, // Ensure no shadow color
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius
                                                .zero, // No rounded corners
                                            side: BorderSide
                                                .none, // Remove border
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    children: [
                                                      ClipRRect(
                                                        child: Image.network(
                                                          "https://www.designil.com/wp-content/uploads/2022/02/prompt-pay-logo.jpg",
                                                          width:
                                                              screenWidth / 5,
                                                          height:
                                                              screenWidth / 15,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return const Center(
                                                              child: Icon(
                                                                Icons.error,
                                                                color:
                                                                    Colors.red,
                                                                size: 50,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "QR Payment",
                                                        style: Styles.grey18(
                                                            context),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      (isSelectCheckout ==
                                                              "QR Payment")
                                                          ? Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                              child: Icon(
                                                                Icons.check,
                                                                size: 25,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            )
                                                          : SizedBox(
                                                              width: 25,
                                                            ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.grey[200],
                                              thickness: 1,
                                              indent: 16,
                                              endIndent: 16,
                                            ),
                                          ],
                                        ),
                                        onPressed: () {
                                          setModalState(() {
                                            isSelectCheckout = "QR Payment";
                                          });
                                          // setState(() {
                                          //   // isSelect = title;
                                          // });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(0),
                                          elevation: 0, // Disable shadow
                                          shadowColor: Colors
                                              .transparent, // Ensure no shadow color
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius
                                                .zero, // No rounded corners
                                            side: BorderSide
                                                .none, // Remove border
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .handHoldingDollar,
                                                        color:
                                                            Styles.primaryColor,
                                                        size: 40,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "เงินสด",
                                                        style: Styles.grey18(
                                                            context),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      (isSelectCheckout ==
                                                              "เงินสด")
                                                          ? Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                              child: Icon(
                                                                Icons.check,
                                                                size: 25,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            )
                                                          : SizedBox(
                                                              width: 25,
                                                            ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.grey[200],
                                              thickness: 1,
                                              indent: 16,
                                              endIndent: 16,
                                            ),
                                          ],
                                        ),
                                        onPressed: () {
                                          setModalState(() {
                                            isSelectCheckout = "เงินสด";
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Container(
                    //   color: Styles.primaryColor,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(16.0),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Text("ยอดรวม", style: Styles.white24(context)),
                    //         Text(
                    //             "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(100)} บาท",
                    //             style: Styles.white24(context)),
                    //       ],
                    //     ),
                    //   ),
                    // )
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
