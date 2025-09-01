import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/button/MenuButton.dart';
import 'package:_12sale_app/core/components/button/ShowPhotoButton.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelFixed.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld.dart';
import 'package:_12sale_app/core/page/order/OrderDetail.dart';
import 'package:_12sale_app/core/page/refund/RefundDetailScreen.dart';
import 'package:_12sale_app/core/page/route/OrderDetailScreen.dart';
import 'package:_12sale_app/data/models/order/Promotion.dart';
import 'package:_12sale_app/data/models/refund/RefundCart.dart';
import 'package:_12sale_app/data/models/stock/StockMovement.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:_12sale_app/data/service/sockertService.dart';
import 'package:_12sale_app/main.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/button/Button.dart';
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
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import '../../../data/models/Shipping.dart';

class CreateRefundScreen extends StatefulWidget {
  final String? storeName;
  final String? storeId;
  final String? storeAddress;
  CreateRefundScreen({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
  });

  @override
  State<CreateRefundScreen> createState() => _CreateRefundScreenState();
}

class _CreateRefundScreenState extends State<CreateRefundScreen>
    with RouteAware {
  final ScrollController _outerController = ScrollController();
  final ScrollController _cartScrollController = ScrollController();
  final ScrollController _promotionScrollController = ScrollController();
  TextEditingController countController = TextEditingController();

  String isSelectCheckout = '';
  String qrImagePath = "";

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

  List<ListSaleProduct> listProduct = [];
  List<RefundItem> listRefund = [];

  List<RefundModel> refundList = [];
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  late TextEditingController noteController;
  late SocketService socketService;

  List<Shipping> shippingList = [];
  Shipping? selectedShipping;
  String isShippingId = '';
  String addressShipping = '';
  final ScrollController _shippingScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getCart();
    _getQRImage();
    _cartScrollController.addListener(_handleInnerScroll);
    _promotionScrollController.addListener(_handleInnerScroll2);
    _outerController.addListener(_onScroll);
    noteController = TextEditingController();
    _shippingScrollController.dispose();
    _getShipping();
  }

  Future<void> _getShipping() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
          endpoint: 'api/cash/store/getShipping',
          method: 'POST',
          body: {
            "storeId": "${widget.storeId}",
          });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        print(data);
        setState(() {
          shippingList = data.map((item) => Shipping.fromJson(item)).toList();
          selectedShipping = shippingList[0];
        });

        print(shippingList);
      }
    } catch (e) {
      print("Error _getShipping $e");
    }
  }

  bool isInteger(String input) {
    return int.tryParse(input) != null;
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
    socketService = Provider.of<SocketService>(context, listen: false);
  }

  @override
  void didPopNext() {
    // setState(() {
    //   _loadingRouteVisit = true;
    // });
    // Called when the screen is popped back to
    _getCart();
    _getQRImage();
  }

  @override
  void dispose() {
    // Unsubscribe when the widget is disposed
    noteController.dispose();
    routeObserver.unsubscribe(this);
    _cartScrollController.dispose();
    _promotionScrollController.dispose();
    _outerController.dispose();
    _outerController.removeListener(_onScroll);
    _cartScrollController.removeListener(_handleInnerScroll);
    _promotionScrollController.removeListener(_handleInnerScroll2);
    super.dispose();
  }

  // List<ImageModel> imageList = [];
  String userQrCode = '';
  final Debouncer _debouncer = Debouncer();
  final Throttler _throttler = Throttler();

  String latitude = '';
  String longitude = '';
  final LocationService locationService = LocationService();

  Future<void> uploadImageSlip(String orderId) async {
    try {
      Dio dio = Dio();
      MultipartFile? imageFile;
      imageFile = await MultipartFile.fromFile(qrImagePath);
      var formData = FormData.fromMap(
        {
          'orderId': orderId,
          'type': 'slip',
          'image': imageFile,
        },
      );
      var response = await dio.post(
        '${ApiService.apiHost}/api/cash/order/addSlip',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            'x-channel': 'cash',
          },
        ),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "อัพโหลด สลิปสำเร็จ",
            style: Styles.green18(context),
          ),
        );
      }
    } catch (e) {
      print("Error $e");
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

  Future<void> _checkOutOrder() async {
    context.loaderOverlay.show();
    try {
      await fetchLocation();
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/refund/checkout',
        method: 'POST',
        body: {
          "type": "refund",
          "period": "$period",
          "area": User.area,
          "storeId": widget.storeId ?? "",
          "note": noteController.text.trim().isEmpty
              ? "-"
              : noteController.text.trim(),
          "latitude": latitude?.toString(),
          "longitude": longitude?.toString(),
          "shipping": selectedShipping,
          "payment": isSelectCheckout == "QR Payment" ? "qr" : 'cash'
        },
      );
      if (response.statusCode == 200) {
        socketService.emitEvent('refund/checkout', {
          'message': 'Refund added successfully',
        });
        if (isSelectCheckout == "QR Payment") {
          socketService.emitEvent('refund/checkout', {
            'message': 'Refund added successfully',
          });
          await uploadImageSlip(
              response.data['data']['changeOrder']['orderId']);
          toastification.show(
            autoCloseDuration: const Duration(seconds: 5),
            context: context,
            primaryColor: Colors.green,
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            title: Text(
              "ขออนุมัติสำเร็จ",
              style: Styles.green18(context),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => RefundDetailScreen(
                orderId: response.data['data']['refundOrder']['orderId'],
              ),
            ),
            (route) => route.isFirst, // Keeps only the first route
          );
        } else {
          toastification.show(
            autoCloseDuration: const Duration(seconds: 5),
            context: context,
            primaryColor: Colors.green,
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            title: Text(
              "ขออนุมัติสำเร็จ",
              style: Styles.green18(context),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => RefundDetailScreen(
                orderId: response.data['data']['refundOrder']['orderId'],
              ),
            ),
            (route) => route.isFirst, // Keeps only the first route
          );
        }
      }

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => OrderDetailScreen(
      //             orderId: response.data['data']['orderId'],
      //           )),
      // );
    } catch (e) {
      context.loaderOverlay.hide();
      print("Error $e");
    }
  }

  Future<void> _getQRImage() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/user/qrcode?area=${User.area}&type=qrcode',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        // print(response.data['data']['image']);
        // final List<dynamic> data = response.data['data']['image'];

        setState(() {
          userQrCode = response.data['data'];
        });
      }
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> _getCart() async {
    try {
      refundList.clear();
      listProduct.clear();
      listRefund.clear();
      print("Get Cart is Loading");
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/get?type=refund&area=${User.area}&storeId=${widget.storeId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        for (var element in data) {
          refundList.add(RefundModel.fromJson(element));
          for (var itemSale in element['listProduct']) {
            listProduct.add(ListSaleProduct.fromJson(itemSale));
          }
          for (var itemRefund in element['listRefund']) {
            listRefund.add(RefundItem.fromJson(itemRefund));
          }
        }
        // setState(() {
        //   cartListData["items"] = listProduct
        //       .map((item) => {
        //             "id": "${item.id}",
        //             "name": "${item.name}",
        //             "group": "${item.group}",
        //             "brand": "${item.brand}",
        //             "size": "${item.size}",
        //             "flavour": "${item.flavour}",
        //             "qty": int.parse(item.qty),
        //             "unit": "${item.unit}",
        //             "unitName": "${item.unitName}",
        //             "price": double.parse(item.price),
        //             "subtotal": double.parse(item.subtotal),
        //             "netTotal": double.parse(item.netTotal),
        //           })
        //       .toList();

        //   for (var item in listRefund) {
        //     cartListData["items"].add({
        //       "id": "${item.id}",
        //       "name": "${item.name}",
        //       "group": "${item.group}",
        //       "brand": "${item.brand}",
        //       "size": "${item.size}",
        //       "flavour": "${item.flavour}",
        //       "qty": int.parse(item.qty),
        //       "unit": "${item.unit}",
        //       "unitName": "${item.unitName}",
        //       "price": double.parse(item.price),
        //       "condition": "${item.condition}",
        //       "expireDate": "${item.expireDate}"
        //     });
        //   }
        //   // totalCart = response.data['data'][0]['total'].toDouble();
        //   // cartList = data.map((item) => CartList.fromJson(item)).toList();
        // });
        // print(cartListData["items"]);
        print(listRefund.length);
        print(listProduct.length);
      }
    } catch (e) {
      setState(() {
        // totalCart = 00.00;
        // cartList = [];
      });
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
          title: "ขออนุมัติคืนสินค้า",
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
                      if (isSelectCheckout == "QR Payment") {
                        AllAlert.customAlert(
                            context,
                            "store.processtimeline_screen.alert.title".tr(),
                            "คุณต้องการจะขอคืนสินค้าใช่หรือไม่ ?",
                            _checkOutOrder);
                      }
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
                                "${listProduct.length + listRefund.length}",
                                // "dawd",
                                style: _isCreateOrderEnabled
                                    ? Styles.headerPirmary18(context)
                                    : Styles.headergrey18(context),
                              ),
                            ),
                            Text(
                              " ขออนุมัติ",
                              style: Styles.headerWhite18(context),
                            ),
                          ],
                        ),
                        Text(
                          "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.parse(refundList.isNotEmpty ? refundList[0].totalNet : "0"))} บาท",
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
              height: screenHeight * 0.6,
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
                                  "${widget.storeName} ${widget.storeId}",
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
                                      onPressed: () {
                                        // _showAddressSheet(context);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      elevation: 0, // Disable shadow
                                      shadowColor: Colors
                                          .transparent, // Ensure no shadow color
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                          side: BorderSide.none),
                                    ),
                                    onPressed: () {
                                      _showNoteSheet(context);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            "หมายเหตุ :",
                                            style: Styles.black18(context),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            noteController.text != ''
                                                ? noteController.text
                                                : "กรุณาใส่หมายเหตุ...",
                                            style: Styles.grey18(context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
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
                      child: BoxShadowCustom(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: screenHeight * 0.4,
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
                                        "รายการคืน",
                                        style: Styles.black18(context),
                                      ),
                                      Text(
                                        "จำนวน ${listRefund.length} รายการ",
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
                                      itemCount: listRefund.length,
                                      itemBuilder: (context, index) {
                                        // int qty =
                                        //     int.parse(listRefund[index].qty);
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
                                                    '${ApiService.apiHost}/images/products/${listRefund[index].id}.webp',
                                                    width: screenWidth / 8,
                                                    height: screenWidth / 8,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        width: screenWidth / 8,
                                                        height: screenWidth / 8,
                                                        color: Colors.grey,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .hide_image,
                                                                color: Colors
                                                                    .white,
                                                                size: 30),
                                                            Text(
                                                              "ไม่มีภาพ",
                                                              style: Styles
                                                                  .white18(
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
                                                                listRefund[
                                                                        index]
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
                                                            Text(
                                                              ' ${DateFormat("dd-MM-yyyy").format(DateTime.parse(listRefund[index].expireDate))} คืน${listRefund[index].condition == "good" ? "ดี" : "เสีย"}',
                                                              style: Styles
                                                                  .black16(
                                                                      context),
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
                                                                      'รหัส : ${listRefund[index].id}',
                                                                      style: Styles
                                                                          .black16(
                                                                              context),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'จำนวน : ${listRefund[index].qty.toStringAsFixed(0)} ${listRefund[index].unitName}',
                                                                      style: Styles
                                                                          .black16(
                                                                              context),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'ราคา : ${listRefund[index].price}',
                                                                      style: Styles
                                                                          .black16(
                                                                              context),
                                                                    ),
                                                                  ],
                                                                ),
                                                                // Row(
                                                                //   children: [
                                                                //     Text(
                                                                //       'วันที่หมดอายุ :',
                                                                //       style: Styles
                                                                //           .black16(
                                                                //               context),
                                                                //     ),
                                                                //   ],
                                                                // ),
                                                              ],
                                                            ),

                                                            // Row(
                                                            //   mainAxisAlignment:
                                                            //       MainAxisAlignment
                                                            //           .end,
                                                            //   children: [
                                                            //     ElevatedButton(
                                                            //       onPressed:
                                                            //           () async {
                                                            //         setState(
                                                            //             () {
                                                            //           if (listRefund[index]
                                                            //                   .qty >
                                                            //               1) {
                                                            //             listRefund[index]
                                                            //                 .qty--;
                                                            //           }
                                                            //         });
                                                            //         await _reduceCartRefund(
                                                            //             listRefund[
                                                            //                 index]);
                                                            //       },
                                                            //       style: ElevatedButton
                                                            //           .styleFrom(
                                                            //         shape:
                                                            //             const CircleBorder(
                                                            //           side: BorderSide(
                                                            //               color: Colors
                                                            //                   .grey,
                                                            //               width:
                                                            //                   1),
                                                            //         ), // ✅ Makes the button circular
                                                            //         padding:
                                                            //             const EdgeInsets
                                                            //                 .all(
                                                            //                 8),
                                                            //         backgroundColor:
                                                            //             Colors
                                                            //                 .white, // Button color
                                                            //       ),
                                                            //       child:
                                                            //           const Icon(
                                                            //         Icons
                                                            //             .remove,
                                                            //         size: 24,
                                                            //         color: Colors
                                                            //             .grey,
                                                            //       ), // Example
                                                            //     ),
                                                            //     Container(
                                                            //       padding:
                                                            //           EdgeInsets
                                                            //               .all(
                                                            //                   4),
                                                            //       decoration:
                                                            //           BoxDecoration(
                                                            //         border:
                                                            //             Border
                                                            //                 .all(
                                                            //           color: Colors
                                                            //               .grey,
                                                            //           width: 1,
                                                            //         ),
                                                            //         borderRadius:
                                                            //             BorderRadius.circular(
                                                            //                 16),
                                                            //       ),
                                                            //       width: 75,
                                                            //       child: Text(
                                                            //         '${listRefund[index].qty.toStringAsFixed(0)}',
                                                            //         textAlign:
                                                            //             TextAlign
                                                            //                 .center,
                                                            //         style: Styles
                                                            //             .black18(
                                                            //           context,
                                                            //         ),
                                                            //       ),
                                                            //     ),
                                                            //     ElevatedButton(
                                                            //       onPressed:
                                                            //           () async {
                                                            //         await _reduceCartRefund(
                                                            //             listRefund[
                                                            //                 index]);

                                                            //         setState(
                                                            //             () {
                                                            //           listRefund[
                                                            //                   index]
                                                            //               .qty++;
                                                            //         });
                                                            //       },
                                                            //       style: ElevatedButton
                                                            //           .styleFrom(
                                                            //         shape:
                                                            //             const CircleBorder(
                                                            //           side: BorderSide(
                                                            //               color: Colors
                                                            //                   .grey,
                                                            //               width:
                                                            //                   1),
                                                            //         ), // ✅ Makes the button circular
                                                            //         padding:
                                                            //             const EdgeInsets
                                                            //                 .all(
                                                            //                 8),
                                                            //         backgroundColor:
                                                            //             Colors
                                                            //                 .white, // Button color
                                                            //       ),
                                                            //       child:
                                                            //           const Icon(
                                                            //         Icons.add,
                                                            //         size: 24,
                                                            //         color: Colors
                                                            //             .grey,
                                                            //       ), // Example
                                                            //     ),
                                                            //     ElevatedButton(
                                                            //       onPressed:
                                                            //           () async {
                                                            //         await _deleteChangeRefund(
                                                            //             listRefund[
                                                            //                 index]);

                                                            //         setState(
                                                            //           () {
                                                            //             listRefund.removeWhere((item) => (item.id == listRefund[index].id &&
                                                            //                 item.unit ==
                                                            //                     listRefund[index].unit &&
                                                            //                 item.condition == listRefund[index].condition &&
                                                            //                 item.expireDate == listRefund[index].expireDate));
                                                            //           },
                                                            //         );
                                                            //         // await _getTotalCart(setModalState);
                                                            //       },
                                                            //       style: ElevatedButton
                                                            //           .styleFrom(
                                                            //         shape:
                                                            //             const CircleBorder(
                                                            //           side: BorderSide(
                                                            //               color: Colors
                                                            //                   .red,
                                                            //               width:
                                                            //                   1),
                                                            //         ),
                                                            //         padding:
                                                            //             const EdgeInsets
                                                            //                 .all(
                                                            //                 8),
                                                            //         backgroundColor:
                                                            //             Colors
                                                            //                 .white, // Button color
                                                            //       ),
                                                            //       child:
                                                            //           const Icon(
                                                            //         Icons
                                                            //             .delete,
                                                            //         size: 24,
                                                            //         color: Colors
                                                            //             .red,
                                                            //       ), // Example
                                                            //     ),
                                                            //   ],
                                                            // ),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              // color: Colors.amber,
              height: screenHeight * 0.7,
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
                                      "รายการเปลี่ยน",
                                      style: Styles.black18(context),
                                    ),
                                    Text(
                                      "จำนวน ${listProduct.length} รายการ",
                                      style: Styles.black18(context),
                                    ),
                                  ],
                                ),

                                Expanded(
                                    child: Scrollbar(
                                  controller: _promotionScrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  thickness: 10,
                                  radius: Radius.circular(16),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    controller: _promotionScrollController,
                                    itemCount: listProduct.length,
                                    itemBuilder: (context, index) {
                                      // int qty =
                                      //     int.parse(listRefund[index].qty);
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
                                                  '${ApiService.apiHost}/images/products/${listProduct[index].id}.webp',
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
                                                              color:
                                                                  Colors.white,
                                                              size: 30),
                                                          Text(
                                                            "ไม่มีภาพ",
                                                            style:
                                                                Styles.white18(
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
                                                  padding: const EdgeInsets.all(
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
                                                              listProduct[index]
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
                                                          // Text(
                                                          //   ' ${DateFormat("dd-MM-yyyy").format(DateTime.parse(listProduct[index].expireDate))} คืน${listRefund[index].condition == "good" ? "ดี" : "เสีย"}',
                                                          //   style:
                                                          //       Styles.black16(
                                                          //           context),
                                                          // ),
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
                                                                    'รหัส : ${listProduct[index].id}',
                                                                    style: Styles
                                                                        .black16(
                                                                            context),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'จำนวน : ${listProduct[index].qty.toStringAsFixed(0)} ${listProduct[index].unitName}',
                                                                    style: Styles
                                                                        .black16(
                                                                            context),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'ราคา : ${listProduct[index].price}',
                                                                    style: Styles
                                                                        .black16(
                                                                            context),
                                                                  ),
                                                                ],
                                                              ),
                                                              // Row(
                                                              //   children: [
                                                              //     Text(
                                                              //       'วันที่หมดอายุ :',
                                                              //       style: Styles
                                                              //           .black16(
                                                              //               context),
                                                              //     ),
                                                              //   ],
                                                              // ),
                                                            ],
                                                          ),

                                                          // Row(
                                                          //   mainAxisAlignment:
                                                          //       MainAxisAlignment
                                                          //           .end,
                                                          //   children: [
                                                          //     ElevatedButton(
                                                          //       onPressed:
                                                          //           () async {
                                                          //         setState(() {
                                                          //           if (listProduct[index]
                                                          //                   .qty >
                                                          //               1) {
                                                          //             listProduct[
                                                          //                     index]
                                                          //                 .qty--;
                                                          //           }
                                                          //         });
                                                          //         // await _reduceCartChange(
                                                          //         //     listProduct[
                                                          //         //         index]);
                                                          //       },
                                                          //       style: ElevatedButton
                                                          //           .styleFrom(
                                                          //         shape:
                                                          //             const CircleBorder(
                                                          //           side: BorderSide(
                                                          //               color: Colors
                                                          //                   .grey,
                                                          //               width:
                                                          //                   1),
                                                          //         ), // ✅ Makes the button circular
                                                          //         padding:
                                                          //             const EdgeInsets
                                                          //                 .all(
                                                          //                 8),
                                                          //         backgroundColor:
                                                          //             Colors
                                                          //                 .white, // Button color
                                                          //       ),
                                                          //       child:
                                                          //           const Icon(
                                                          //         Icons.remove,
                                                          //         size: 24,
                                                          //         color: Colors
                                                          //             .grey,
                                                          //       ), // Example
                                                          //     ),
                                                          //     Container(
                                                          //       padding:
                                                          //           EdgeInsets
                                                          //               .all(4),
                                                          //       decoration:
                                                          //           BoxDecoration(
                                                          //         border: Border
                                                          //             .all(
                                                          //           color: Colors
                                                          //               .grey,
                                                          //           width: 1,
                                                          //         ),
                                                          //         borderRadius:
                                                          //             BorderRadius
                                                          //                 .circular(
                                                          //                     16),
                                                          //       ),
                                                          //       width: 75,
                                                          //       child: Text(
                                                          //         '${listProduct[index].qty.toStringAsFixed(0)}',
                                                          //         textAlign:
                                                          //             TextAlign
                                                          //                 .center,
                                                          //         style: Styles
                                                          //             .black18(
                                                          //           context,
                                                          //         ),
                                                          //       ),
                                                          //     ),
                                                          //     ElevatedButton(
                                                          //       onPressed:
                                                          //           () async {
                                                          //         // await _reduceCartRefund(
                                                          //         //     listProduct[
                                                          //         //         index]);

                                                          //         setState(() {
                                                          //           listProduct[
                                                          //                   index]
                                                          //               .qty++;
                                                          //         });
                                                          //       },
                                                          //       style: ElevatedButton
                                                          //           .styleFrom(
                                                          //         shape:
                                                          //             const CircleBorder(
                                                          //           side: BorderSide(
                                                          //               color: Colors
                                                          //                   .grey,
                                                          //               width:
                                                          //                   1),
                                                          //         ), // ✅ Makes the button circular
                                                          //         padding:
                                                          //             const EdgeInsets
                                                          //                 .all(
                                                          //                 8),
                                                          //         backgroundColor:
                                                          //             Colors
                                                          //                 .white, // Button color
                                                          //       ),
                                                          //       child:
                                                          //           const Icon(
                                                          //         Icons.add,
                                                          //         size: 24,
                                                          //         color: Colors
                                                          //             .grey,
                                                          //       ), // Example
                                                          //     ),
                                                          //     ElevatedButton(
                                                          //       onPressed:
                                                          //           () async {
                                                          //         // await _deleteChangeRefund(
                                                          //         //     listProduct[
                                                          //         //         index]);

                                                          //         // setState(
                                                          //         //   () {
                                                          //         //     listProduct.removeWhere((item) => (item.id == listRefund[index].id &&
                                                          //         //         item.unit ==
                                                          //         //             listProduct[index]
                                                          //         //                 .unit &&
                                                          //         //         item.condition ==
                                                          //         //             listProduct[index]
                                                          //         //                 .condition &&
                                                          //         //         item.expireDate ==
                                                          //         //             listProduct[index].expireDate));
                                                          //         //   },
                                                          //         // );
                                                          //         // await _getTotalCart(setModalState);
                                                          //       },
                                                          //       style: ElevatedButton
                                                          //           .styleFrom(
                                                          //         shape:
                                                          //             const CircleBorder(
                                                          //           side: BorderSide(
                                                          //               color: Colors
                                                          //                   .red,
                                                          //               width:
                                                          //                   1),
                                                          //         ),
                                                          //         padding:
                                                          //             const EdgeInsets
                                                          //                 .all(
                                                          //                 8),
                                                          //         backgroundColor:
                                                          //             Colors
                                                          //                 .white, // Button color
                                                          //       ),
                                                          //       child:
                                                          //           const Icon(
                                                          //         Icons.delete,
                                                          //         size: 24,
                                                          //         color: Colors
                                                          //             .red,
                                                          //       ), // Example
                                                          //     ),
                                                          //   ],
                                                          // ),
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

                                // Expanded(
                                //     child: Container(
                                //   height:
                                //       200, // Set a height to avoid rendering errors
                                //   child: Scrollbar(
                                //     controller: _promotionScrollController,
                                //     thumbVisibility: true,
                                //     trackVisibility: true,
                                //     radius: Radius.circular(16),
                                //     thickness: 10,
                                //     child: ListView.builder(
                                //         shrinkWrap: true,
                                //         physics: ClampingScrollPhysics(),
                                //         controller: _promotionScrollController,
                                //         itemCount: listProduct.length,
                                //         itemBuilder: (context, innerIndex) {
                                //           return Column(
                                //             children: [
                                //               Row(
                                //                 mainAxisAlignment:
                                //                     MainAxisAlignment.start,
                                //                 children: [
                                //                   ClipRRect(
                                //                     borderRadius:
                                //                         BorderRadius.circular(
                                //                             8),
                                //                     child: Image.network(
                                //                       '${ApiService.apiHost}/images/products/${widget.product.id}.webp',
                                //                       width: screenWidth / 8,
                                //                       height: screenWidth / 8,
                                //                       fit: BoxFit.cover,
                                //                       errorBuilder: (context,
                                //                           error, stackTrace) {
                                //                         return const Center(
                                //                           child: Icon(
                                //                             Icons.error,
                                //                             color: Colors.red,
                                //                             size: 50,
                                //                           ),
                                //                         );
                                //                       },
                                //                     ),
                                //                   ),
                                //                   Expanded(
                                //                     flex: 3,
                                //                     child: Padding(
                                //                       padding:
                                //                           const EdgeInsets.all(
                                //                               16.0),
                                //                       child: Column(
                                //                         crossAxisAlignment:
                                //                             CrossAxisAlignment
                                //                                 .start,
                                //                         children: [
                                //                           Row(
                                //                             children: [
                                //                               Expanded(
                                //                                 child: Text(
                                //                                   listProduct[
                                //                                           innerIndex]
                                //                                       .name,
                                //                                   style: Styles
                                //                                       .black16(
                                //                                           context),
                                //                                   softWrap:
                                //                                       true,
                                //                                   maxLines: 2,
                                //                                   overflow:
                                //                                       TextOverflow
                                //                                           .visible,
                                //                                 ),
                                //                               ),
                                //                             ],
                                //                           ),
                                //                           // Row(
                                //                           //   children: [
                                //                           //     Expanded(
                                //                           //       child: Text(
                                //                           //         listProduct[
                                //                           //                 innerIndex]
                                //                           //             .proName,
                                //                           //         style: Styles
                                //                           //             .black16(
                                //                           //                 context),
                                //                           //         softWrap: true,
                                //                           //         maxLines: 2,
                                //                           //         overflow:
                                //                           //             TextOverflow
                                //                           //                 .visible,
                                //                           //       ),
                                //                           //     ),
                                //                           //   ],
                                //                           // ),
                                //                           Row(
                                //                             mainAxisAlignment:
                                //                                 MainAxisAlignment
                                //                                     .spaceBetween,
                                //                             children: [
                                //                               Column(
                                //                                 crossAxisAlignment:
                                //                                     CrossAxisAlignment
                                //                                         .start,
                                //                                 children: [
                                //                                   Row(
                                //                                     children: [
                                //                                       Text(
                                //                                         'รหัส${listProduct[innerIndex].id}',
                                //                                         style: Styles.black16(
                                //                                             context),
                                //                                       ),
                                //                                     ],
                                //                                   ),
                                //                                   Row(
                                //                                     children: [
                                //                                       Text(
                                //                                         '${listProduct[innerIndex].group} รส${listProduct[innerIndex].flavour}',
                                //                                         style: Styles.black16(
                                //                                             context),
                                //                                       ),
                                //                                     ],
                                //                                   ),
                                //                                 ],
                                //                               ),
                                //                               Row(
                                //                                 mainAxisAlignment:
                                //                                     MainAxisAlignment
                                //                                         .end,
                                //                                 children: [
                                //                                   Container(
                                //                                     padding:
                                //                                         EdgeInsets
                                //                                             .all(4),
                                //                                     decoration:
                                //                                         BoxDecoration(
                                //                                       border:
                                //                                           Border
                                //                                               .all(
                                //                                         color: Colors
                                //                                             .grey,
                                //                                         width:
                                //                                             1,
                                //                                       ),
                                //                                       borderRadius:
                                //                                           BorderRadius.circular(
                                //                                               16),
                                //                                     ),
                                //                                     width: 75,
                                //                                     child: Text(
                                //                                       '${listProduct[innerIndex].qty.toStringAsFixed(0)} ${listProduct[innerIndex].unitName}',
                                //                                       textAlign:
                                //                                           TextAlign
                                //                                               .center,
                                //                                       style: Styles
                                //                                           .black18(
                                //                                         context,
                                //                                       ),
                                //                                     ),
                                //                                   ),
                                //                                 ],
                                //                               ),
                                //                             ],
                                //                           ),
                                //                         ],
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 ],
                                //               ),
                                //               Divider(
                                //                 color: Colors.grey[200],
                                //                 thickness: 1,
                                //                 indent: 16,
                                //                 endIndent: 16,
                                //               ),
                                //             ],
                                //           );
                                //         }),
                                //   ),
                                // ))
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
                                                color: Styles.primaryColorIcons,
                                                size: 40,
                                              ),
                                              SizedBox(width: 8),
                                              // ClipRRect(
                                              //   borderRadius:
                                              //       BorderRadius.circular(8),
                                              //   child: Image.network(
                                              //     '${ApiService.apiHost}/images/products/${widget.product.id}.webp',
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
                                  "รวมรับคืนสินค้า",
                                  style: Styles.grey18(context),
                                ),
                                Text(
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.parse(refundList.isNotEmpty ? refundList[0].totalRefund : "0.00"))} บาท",
                                  style: Styles.grey18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "รวมเปลี่ยนสินค้า",
                                  style: Styles.grey18(context),
                                ),
                                Text(
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.parse(refundList.isNotEmpty ? refundList[0].totalChange : "0.00"))} บาท",
                                  style: Styles.grey18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "รวมมูลค่าส่วนต่าง",
                                  style: Styles.grey18(context),
                                ),
                                Text(
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.parse(refundList.isNotEmpty ? refundList[0].totalExVat : "0.00"))} บาท",
                                  style: Styles.grey18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "VAT 7%",
                                  style: Styles.grey18(context),
                                ),
                                Text(
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.parse(refundList.isNotEmpty ? refundList[0].totalVat : "0.00"))} บาท",
                                  style: Styles.grey18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "รวมมูลค่าก่อนหัก VAT 7%",
                                  style: Styles.grey18(context),
                                ),
                                Text(
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.parse(refundList.isNotEmpty ? refundList[0].totalExVat : "0.00"))} บาท",
                                  style: Styles.grey18(context),
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
                                  "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.parse(refundList.isNotEmpty ? refundList[0].totalNet : "0.00"))} บาท",
                                  style: Styles.green24(context),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // isSelectCheckout == "QR Payment"
            //     ? Padding(
            //         padding: EdgeInsets.all(8),
            //         child: BoxShadowCustom(
            //           child: Padding(
            //             padding: EdgeInsets.all(8),
            //             child: Column(
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //                   children: [
            //                     ShowPhotoButton(
            //                       checkNetwork: true,
            //                       label: "QR Code",
            //                       icon: Icons.image_not_supported_outlined,
            //                       imagePath: userQrCode != '' ? userQrCode : '',
            //                     ),
            //                     IconButtonWithLabelOld(
            //                       icon: Icons.photo_camera,
            //                       imagePath:
            //                           qrImagePath != "" ? qrImagePath : null,
            //                       label: "ถ่ายภาพการโอน",
            //                       onImageSelected: (String imagePath) async {
            //                         setState(() {
            //                           qrImagePath = imagePath;
            //                         });
            //                         // await uploadFormDataWithDio(
            //                         //     imagePath, 'store', context);
            //                       },
            //                     ),
            //                   ],
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       )
            //     : SizedBox()
          ],
        ),
      ),
    );
  }

  void _showAddressSheet(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                                Icons.storefront_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              Text(' เลือกสถานที่จัดส่ง',
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
                        color: Colors.white,
                        child: Column(
                          children: [
                            Expanded(
                                child: Scrollbar(
                              controller: _shippingScrollController,
                              thickness: 10,
                              thumbVisibility: true,
                              trackVisibility: true,
                              radius: Radius.circular(16),
                              child: ListView.builder(
                                controller: _shippingScrollController,
                                itemCount: shippingList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.all(8),

                                                  elevation:
                                                      0, // Disable shadow
                                                  shadowColor: Colors
                                                      .transparent, // Ensure no shadow color
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.zero,
                                                      side: BorderSide.none),
                                                ),
                                                onPressed: () {
                                                  setModalState(() {
                                                    isShippingId =
                                                        shippingList[index]
                                                                .shippingId ??
                                                            "";
                                                  });
                                                  setState(() {
                                                    selectedShipping =
                                                        shippingList[index];
                                                    addressShipping =
                                                        "${shippingList[index].address} ${shippingList[index].district} ${shippingList[index].subDistrict} ${shippingList[index].province} ${shippingList[index].postCode}";
                                                  });
                                                },
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // Text(
                                                              //   shippingList[
                                                              //           index]
                                                              //       .shippingId,
                                                              //   style: Styles
                                                              //       .black18(
                                                              //           context),
                                                              // ),
                                                              shippingList[index]
                                                                          .address !=
                                                                      ""
                                                                  ? Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            "${shippingList[index].address} ${shippingList[index].district} ${shippingList[index].subDistrict}  ${shippingList[index].province} ${shippingList[index].postCode}",
                                                                            style:
                                                                                Styles.black18(context),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : SizedBox(),
                                                            ],
                                                          ),
                                                        ),
                                                        isShippingId ==
                                                                shippingList[
                                                                        index]
                                                                    .shippingId
                                                            ? Icon(
                                                                Icons
                                                                    .check_circle_outline_rounded,
                                                                color: Styles
                                                                    .success,
                                                                size: 25,
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .keyboard_arrow_right_sharp,
                                                                color:
                                                                    Colors.grey,
                                                                size: 25,
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
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ))
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

  void _showNoteSheet(BuildContext context) {
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
                              Text('หมายเหตุ', style: Styles.white24(context)),
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            autofocus: true,
                            style: Styles.black18(context),
                            controller: noteController,
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
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
                                    // _showNoteSheet(context);
                                    Navigator.pop(context);
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
                                          Navigator.of(context).pop();
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
                                                        color: Styles
                                                            .primaryColorIcons,
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
                                          Navigator.of(context).pop();
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
