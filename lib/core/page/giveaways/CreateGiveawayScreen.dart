import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/button/MenuButton.dart';
import 'package:_12sale_app/core/components/button/ShowPhotoButton.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelFixed.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld2.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld3.dart';
import 'package:_12sale_app/core/page/giveaways/GiveAwaysDetailScreen.dart';
import 'package:_12sale_app/core/page/order/OrderDetail.dart';
import 'package:_12sale_app/core/page/route/OrderDetailScreen.dart';
import 'package:_12sale_app/core/page/route/RouteScreen.dart';
import 'package:_12sale_app/data/models/Shipping.dart';
import 'package:_12sale_app/data/models/order/Promotion.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:_12sale_app/data/service/sockertService.dart';
import 'package:_12sale_app/main.dart';
import 'package:charset_converter/charset_converter.dart';
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

class CreateGiveawayScreen extends StatefulWidget {
  final String storeName;
  final String storeId;
  final String storeAddress;
  final String giveawayId;
  final String shippingId;
  CreateGiveawayScreen({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.giveawayId,
    required this.shippingId,
  });

  @override
  State<CreateGiveawayScreen> createState() => _CreateGiveawayScreenState();
}

class _CreateGiveawayScreenState extends State<CreateGiveawayScreen>
    with RouteAware {
  final ScrollController _outerController = ScrollController();
  final ScrollController _cartScrollController = ScrollController();
  final ScrollController _promotionScrollController = ScrollController();
  final ScrollController _shippingScrollController = ScrollController();

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

  late TextEditingController noteController;
  List<Shipping> shippingList = [];
  Shipping? selectedShipping;
  String addressShipping = '';
  String isShippingId = '';
  String storeImagePath = "";

  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  @override
  void initState() {
    super.initState();
    _getCart();
    _getQRImage();
    _getShipping();
    _shippingScrollController.dispose();
    _cartScrollController.addListener(_handleInnerScroll);
    _promotionScrollController.addListener(_handleInnerScroll2);
    _outerController.addListener(_onScroll);
    noteController = TextEditingController();
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
      _isCreateOrderEnabled = true; // Enable the checkbox
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
    routeObserver.unsubscribe(this);
    _cartScrollController.dispose();
    _promotionScrollController.dispose();
    _outerController.dispose();
    _outerController.removeListener(_onScroll);
    _cartScrollController.removeListener(_handleInnerScroll);
    _promotionScrollController.removeListener(_handleInnerScroll2);
    noteController.dispose();
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
  String userQrCode = '';
  late SocketService socketService;

  Future<void> uploadImageSlip(String orderId) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      MultipartFile? imageFile;
      imageFile = await MultipartFile.fromFile(storeImagePath);
      var formData = FormData.fromMap(
        {
          'orderId': orderId,
          'type': 'give',
          'image': imageFile,
        },
      );
      // var response = await dio.post(
      //   '${ApiService.apiHost}/api/cash/give/addimageGive',
      //   data: formData,
      //   options: Options(
      //     headers: {
      //       "Content-Type": "multipart/form-data",
      //       'x-channel': 'cash',
      //     },
      //   ),
      // );

      var response = await apiService.request2(
        endpoint: 'api/cash/give/addimageGive',
        method: 'POST',
        body: formData,
        headers: {
          'x-channel': 'cash',
          'Content-Type': 'multipart/form-data',
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "อัพโหลดรูปสำเร็จ",
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

  Future<void> _checkOutGiveAways() async {
    context.loaderOverlay.show();
    try {
      await fetchLocation();
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/give/checkout',
        method: 'POST',
        body: {
          "type": "give",
          "period": "${period}",
          "area": "${User.area}",
          "storeId": "${widget.storeId}",
          "giveId": "${widget.giveawayId}",
          "note": "${noteController.text}",
          "latitude": "$latitude",
          "longitude": "$longitude",
          "shipping": selectedShipping
        },
      );
      if (response.statusCode == 200) {
        socketService.emitEvent('give/checkout', {
          'message': 'GiveAways added successfully',
        });
        await uploadImageSlip(response.data['data']['orderId']);
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "แจกสินค้าสำเร็จ",
            style: Styles.green18(context),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => GiveAwaysDetailScreen(
              orderId: response.data['data']['orderId'],
            ),
          ),
          (route) => route.isFirst, // Keeps only the first route
        );
      }
    } catch (e) {
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
        setState(() {
          userQrCode = response.data['data'];
        });
      }
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> _getSummary() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/get?type=give&area=${User.area}&storeId=${widget.storeId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        vat = response.data['data'][0]['totalVat'].toDouble();
        totalExVat = response.data['data'][0]['totalExVat'].toDouble();
        total = response.data['data'][0]['total'].toDouble();
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

  Future<void> _getCart() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/get?type=give&area=${User.area}&storeId=${widget.storeId}&proId=${widget.giveawayId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'][0]['listProduct'];
        // final List<dynamic> data2 = response.data['data'][0]['listPromotion'];
        setState(() {
          if (cartList.length == 0) {
            cartList = data.map((item) => CartList.fromJson(item)).toList();
          }
          // promotionList =
          //     data2.map((item) => PromotionList.fromJson(item)).toList();
          // listPromotions.clear();
          // for (var promotion in promotionList) {
          //   for (var item in promotion.listPromotion) {
          //     listPromotions.add(item);
          //   }
          // }
          // subtotal = response.data['data'][0]['subtotal'].toDouble();
          // discount = response.data['data'][0]['discount'].toDouble();
          // discountProduct =
          //     response.data['data'][0]['discountProduct'].toDouble();
          vat = response.data['data'][0]['totalVat'].toDouble();
          totalExVat = response.data['data'][0]['totalExVat'].toDouble();
          total = response.data['data'][0]['total'].toDouble();
          print("vat = $vat");
        });
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
        });
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
          "type": "give",
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " แจกสินค้า",
          icon: Icons.card_giftcard,
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: _isCreateOrderEnabled
      //     ? null
      //     : FloatingActionButton(
      //         shape: const CircleBorder(),
      //         backgroundColor: Styles.primaryColor,
      //         child: const Icon(
      //           Icons.arrow_downward_rounded,
      //           color: Colors.white,
      //         ),
      //         onPressed: () {
      //           _onScrollDown();
      //         },
      //       ),
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: Styles.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (storeImagePath != "" && noteController.text != '') {
                      AllAlert.customAlert(
                          context,
                          "store.processtimeline_screen.alert.title".tr(),
                          "คุณต้องการจะแจกสินค้าใช่หรือไม่ ?",
                          _checkOutGiveAways);
                    } else {
                      toastification.show(
                        autoCloseDuration: const Duration(seconds: 5),
                        context: context,
                        primaryColor: Colors.red,
                        type: ToastificationType.error,
                        style: ToastificationStyle.flatColored,
                        title: Text(
                          "กรุณากรอกเหตุผลและถ่ายรูป",
                          style: Styles.red18(context),
                        ),
                      );
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
                              " แจกสินค้า",
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

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: BoxShadowCustom(
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "ที่อยู่การจัดส่ง",
                                        style: Styles.black18(context),
                                      ),
                                      // Text(
                                      //   "แก้ไขที่อยู่",
                                      //   style: Styles.pirmary18(context),
                                      // )
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
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        color: Colors.black,
                                                        size: 30,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          addressShipping == ''
                                                              ? '${widget.storeAddress}'
                                                              : '${addressShipping}',
                                                          style: Styles.grey18(
                                                              context),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
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
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.all(8),
                                              elevation: 0, // Disable shadow
                                              shadowColor: Colors
                                                  .transparent, // Ensure no shadow color
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.zero,
                                                  side: BorderSide.none),
                                            ),
                                            onPressed: () {
                                              _showNoteSheet(context);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "หมายเหตุ :",
                                                    style:
                                                        Styles.red18(context),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    noteController.text != ''
                                                        ? noteController.text
                                                        : "กรุณาใส่หมายเหตุ...",
                                                    style:
                                                        Styles.red18(context),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        IconButtonWithLabelOld3(
                          icon: Icons.photo_camera,
                          imagePath:
                              storeImagePath != "" ? storeImagePath : null,
                          label: "รูปการแจกสินค้า",
                          onImageSelected: (String imagePath) async {
                            setState(() {
                              storeImagePath = imagePath;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    BoxShadowCustom(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: screenHeight * 0.44,
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
                                                  '${ApiService.image}/images/products/${cartList[index].id}.webp',
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
                                                              size: 50),
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
                                                                    'จำนวน : ${cartList[index].qty.toStringAsFixed(0)} ${cartList[index].unitName}',
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
                                                                  await _deleteCart(
                                                                      cartList[
                                                                          index]);

                                                                  setState(
                                                                    () {
                                                                      cartList.removeWhere((item) => (item.id ==
                                                                              cartList[index]
                                                                                  .id &&
                                                                          item.unit ==
                                                                              cartList[index].unit));
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
                                                                  Icons.delete,
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
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BoxShadowCustom(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
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
              ],
            ),
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
}
