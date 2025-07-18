import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:_12sale_app/core/components/Dropdown.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/button/MenuButton.dart';
import 'package:_12sale_app/core/components/button/ShowPhotoButton.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelFixed.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld.dart';
import 'package:_12sale_app/core/page/order/OrderDetail.dart';
import 'package:_12sale_app/core/page/route/OrderDetailScreen.dart';
import 'package:_12sale_app/core/page/route/RouteScreen.dart';
import 'package:_12sale_app/data/models/order/ChangePromotion.dart';
import 'package:_12sale_app/data/models/order/Promotion.dart';
import 'package:_12sale_app/data/models/order/PromotionList.dart';
import 'package:_12sale_app/data/models/stock/StockMovement.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:_12sale_app/data/service/sockertService.dart';
import 'package:_12sale_app/main.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
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

class CreateOrderScreen extends StatefulWidget {
  final String? routeId;
  final String? storeName;
  final String? storeId;
  final String? storeAddress;

  CreateOrderScreen({
    super.key,
    required this.routeId,
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

  late SocketService socketService;

  // FocusNode _focusNode = FocusNode();

  String isSelectCheckout = '';
  String qrImagePath = "";

  bool _loading = true;

  double subtotal = 0;
  double discount = 0;
  double discountProduct = 0;
  double vat = 0;
  double totalExVat = 0;
  double total = 0;

  int count = 1;

  bool _isInnerAtTop = true;
  bool _isInnerAtBottom = false;
  bool _isCreateOrderEnabled = false;

  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    _getCart();
    _getQRImage();
    _cartScrollController.addListener(_handleInnerScroll);
    _promotionScrollController.addListener(_handleInnerScroll2);
    _outerController.addListener(_onScroll);
    noteController = TextEditingController();
    // _focusNode.requestFocus();
    // RawKeyboard.instance.addListener(_handleKey);
  }

  // void _handleKey(RawKeyEvent event) {
  //   if (event is RawKeyUpEvent) {
  //     if (event.logicalKey == LogicalKeyboardKey.escape ||
  //         event.logicalKey == LogicalKeyboardKey.goBack ||
  //         event.logicalKey == LogicalKeyboardKey.backspace) {
  //       // Log or handle KEYCODE_BACK equivalent
  //       print("Back key released (KeyUp)");
  //       context.loaderOverlay.show();
  //       _getCart();
  //       // Optionally: Prevent pop or trigger some action
  //     }
  //   }
  // }

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

  // Future<List<GroupPromotion>> getRoutesDropdown(String filter) async {
  //   try {
  //     // Load the JSON file for districts
  //     ApiService apiService = ApiService();
  //     await apiService.init();
  //     var response = await apiService.request(
  //       endpoint: 'api/cash/manage/option/get?module=route&type=notSell',
  //       method: 'GET',
  //     );
  //     // Filter and map JSON data to District model based on selected province and filter
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final List<dynamic> data = response.data['data'];
  //       setState(() {
  //         causes = data.map((item) => Cause.fromJson(item)).toList();
  //       });
  //     }
  //     // Group districts by amphoe
  //     return causes;
  //   } catch (e) {
  //     print("Error occurred: $e");
  //     return [];
  //   }
  // }

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
    // RawKeyboard.instance.removeListener(_handleKey);
    // _focusNode.dispose();
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
  List<ProductMoveMent> productMoveMent = [];
  List<PromotionList> promotionList = [];

  List<PromotionList> promotionListChange = [];

  int promotionListChangeStatus = 0;

  String qrImage = '';

  List<PromotionListItem> listPromotions = [];

  String unitPromotion = '';
  String unitPromotionText = '';

  List<ProductGroup> listChangePromotions = [];
  List<ItemProductChange> itemProductChange = [];

  List<TotalProductChang> totalChangeList = [];
  // int totalChangePr = 0;
  // int totalPromotionqty = 0;

  List<GroupPromotion> groupPromotion = [];

  List<ImageModel> imageList = [];
  final Debouncer _debouncer = Debouncer();
  final Throttler _throttler = Throttler();

  String latitude = '';
  String longitude = '';
  List<String?> proIdList = [];

  List<PromotionChangeList> proChangeLsit = [];
  final LocationService locationService = LocationService();

  // List<int> itemQuantities = []; // Store item quantities for each item

  Future<List<GroupPromotion>> getGroupDropdown(String filter) async {
    try {
      // Group districts by amphoe
      return groupPromotion;
    } catch (e) {
      print("Error occurred: $e");
      return [];
    }
  }

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

  Future<void> _changeTotalProduct() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      print("proIdList $proIdList");
      for (var proId in proIdList) {
        var response = await apiService.request(
          endpoint: 'api/cash/promotion/changeProduct',
          method: 'POST',
          body: {
            "type": "sale",
            "storeId": "${widget.storeId}",
            "proId": "${proId}"
          },
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = response.data['data'];
          // print(response.data['data']);

          setState(() {
            totalChangeList.add(TotalProductChang.fromJson(data));
          });
          // totalChangeList = TotalProductChang.fromJson(data);
          print(totalChangeList);

          itemProductChange.clear();
          for (var changePromotion in listChangePromotions) {
            groupPromotion.add(
              GroupPromotion(
                  group: changePromotion.group, size: changePromotion.size),
            );
            for (var itemChange in changePromotion.product) {
              itemProductChange.add(itemChange);
            }
          }
        }
      }
      // setState(() {
      //   itemQuantities = List.filled(
      //       itemProductChange.length, 1); // Initialize quantities to 1
      // });

      print("Change Promtion Product $itemProductChange");
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> _changeProduct2(String? proId) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      // print("proIdList $proIdList");
      var response = await apiService.request(
        endpoint: 'api/cash/promotion/changeProduct',
        method: 'POST',
        body: {
          "type": "sale",
          "storeId": "${widget.storeId}",
          "proId": "${proId}"
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['listProduct'];

        print(data);
        print(proId);
        listChangePromotions =
            data.map((item) => ProductGroup.fromJson(item)).toList();

        itemProductChange.clear();
        for (var changePromotion in listChangePromotions) {
          groupPromotion.add(
            GroupPromotion(
                group: changePromotion.group, size: changePromotion.size),
          );
          for (var itemChange in changePromotion.product) {
            itemProductChange.add(itemChange);
          }
        }
      }
      print("Change Promtion Product $itemProductChange");
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

  Future<void> _addStockMovement(String orderId) async {
    try {
      for (var cart in cartList) {
        productMoveMent.add(
          ProductMoveMent(
              productId: cart.id,
              lot: cart.lot,
              qty: cart.qty.toInt(),
              unit: cart.unit),
        );
      }
      ApiService apiService = ApiService();
      await apiService.init();

      // print(User.saleCode);
      // print(productMoveMent[0].id);
      var response = await apiService.request(
        endpoint: 'api/cash/stock/addStockMovement',
        method: 'POST',
        body: {
          "orderId": orderId,
          "area": "${User.area}",
          "saleCode": "${User.saleCode}",
          "period": "${period}",
          "warehouse": "${User.warehouse}",
          "action": "checkout",
          "status": "pending",
          "product": productMoveMent,
        },
      );
      if (response.statusCode == 200) {}
    } catch (e) {
      print("Error _addStockMovement $e");
    }
  }

  Future<void> _checkOutOrder() async {
    context.loaderOverlay.show();
    try {
      await fetchLocation();

      for (var proList in proChangeLsit) {
        promotionListChange.add(
          PromotionList(
            proId: proList.proId,
            proName: proList.proName,
            proCode: proList.proCode,
            proType: proList.proType,
            proQty: proList.proQty,
            discount: discount,
            listProduct: listPromotions
                .where((item) => item.proId == proList.proId)
                .toList(),
          ),
        );
        // print("promotionListChange $promotionListChange");
      }

      ApiService apiService = ApiService();
      // print(
      //     "promotionListChange: ${promotionListChange.map((e) => e.toJson()).toList()}");
      // for (var e in promotionListChange) {
      //   print('PromotionList: ${e.toJson()}');
      //   // หรือถ้าชอบ format json ให้ import 'dart:convert';
      //   // print('PromotionList: ${jsonEncode(e.toJson())}');
      // }
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/order/checkout',
        method: 'POST',
        body: {
          "type": "sale",
          "area": "${User.area}",
          "period": "${period}",
          "storeId": "${widget.storeId}",
          "routeId": "${widget.routeId}",
          "note": "${noteController.text}",
          "latitude": "$latitude",
          "longitude": "$longitude",
          "shipping": "${widget.storeAddress}",
          "payment": isSelectCheckout == "QR Payment" ? "qr" : "cash",
          "changePromotionStatus": promotionListChangeStatus,
          "listPromotion": promotionListChange,
        },
      );
      if (response.statusCode == 200) {
        socketService.emitEvent('order/checkout', {
          'message': 'Order added successfully',
        });
        // await _addStockMovement(response.data['data']['orderId']);
        if (isSelectCheckout == "QR Payment") {
          socketService.emitEvent('order/checkout', {
            'message': 'Order added successfully',
          });
          await uploadImageSlip(response.data['data']['orderId']);
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
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(
                orderId: response.data['data']['orderId'],
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
              "สั่งซื้อสำเร็จ",
              style: Styles.green18(context),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(
                orderId: response.data['data']['orderId'],
              ),
            ),
            (route) => route.isFirst, // Keeps only the first route
          );
        }
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
        endpoint: 'api/cash/user/qrcode?area=${User.area}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        print("getQRImage ${response.data['data']}");
        setState(() {
          qrImage = response.data['data'];
        });
        // final List<dynamic> data = response.data['data']['data'];
        // setState(() {
        //   imageList = data.map((item) => ImageModel.fromJson(item)).toList();
        // });
      }
    } catch (e) {
      print("Error _getQRImage $e");
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
        print("data2 $data2");
        setState(() {
          if (cartList.length == 0) {
            cartList = data.map((item) => CartList.fromJson(item)).toList();
          }

          promotionList =
              data2.map((item) => PromotionList.fromJson(item)).toList();

          listPromotions.clear();

          for (var promotion in promotionList) {
            proIdList.add(promotion.proId);
            for (var item in promotion.listProduct) {
              unitPromotion = item.unit;
              unitPromotionText = item.unitName;
              // listPromotions.add(item);
              listPromotions.add(PromotionListItem(
                brand: item.brand,
                flavour: item.flavour,
                group: item.group,
                proId: promotion.proId,
                proName: promotion.proName,
                proType: promotion.proType,
                id: item.id,
                name: item.name,
                qty: item.qty,
                size: item.size,
                unit: item.unit,
                unitName: item.unitName,
              ));
            }

            proChangeLsit.add(
              PromotionChangeList(
                  proId: promotion.proId,
                  proName: promotion.proName,
                  proCode: promotion.proCode,
                  proType: promotion.proType,
                  proQty: promotion.proQty,
                  promotionListItem: listPromotions),
            );
          }
          print("Get Cart is Loading");

          // proId = response.data['data'][0]['listPromotion']['proId'];

          subtotal = response.data['data'][0]['subtotal'].toDouble();
          discount = response.data['data'][0]['discount'].toDouble();
          discountProduct =
              response.data['data'][0]['discountProduct'].toDouble();
          vat = response.data['data'][0]['vat'].toDouble();
          totalExVat = response.data['data'][0]['totalExVat'].toDouble();
          total = response.data['data'][0]['total'].toDouble();

          // listPromotionsMock = List.from(listPromotions);
        });
        // listPromotionsMock = List.from(listPromotions);
        await _changeTotalProduct();

        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
          context.loaderOverlay.hide();
        });

        // Map cartList to receiptData["items"]
        // print(proIdList);
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

  Future<void> _reduceCart(CartList cart, String stockType) async {
    const duration = Duration(seconds: 1);
    try {
      _debouncer.debounce(
        duration: duration,
        onDebounce: () async {
          ApiService apiService = ApiService();
          await apiService.init();
          var response = await apiService.request(
            endpoint: 'api/cash/cart/adjust',
            method: 'PATCH',
            body: {
              "type": "sale",
              "area": "${User.area}",
              "storeId": "${widget.storeId}",
              "id": "${cart.id}",
              "qty": cart.qty,
              "unit": "${cart.unit}",
              'stockType': stockType
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
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.orange,
          type: ToastificationType.warning,
          style: ToastificationStyle.flatColored,
          title: Text(
            "ของในสต๊อกไม่เพียงพอ",
            style: Styles.red18(context),
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: "สั่งซื้อสินค้า",
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
                        if (qrImagePath != "") {
                          AllAlert.customAlert(
                              context,
                              "store.processtimeline_screen.alert.title".tr(),
                              "คุณต้องการจะสั่งซื้อสินค้าใช่หรือไม่ ?",
                              _checkOutOrder);
                        } else {
                          toastification.show(
                            autoCloseDuration: const Duration(seconds: 5),
                            context: context,
                            primaryColor: Colors.red,
                            type: ToastificationType.error,
                            style: ToastificationStyle.flatColored,
                            title: Text(
                              "กรุณาอัพโหลดสลิป",
                              style: Styles.red18(context),
                            ),
                          );
                        }
                      } else {
                        AllAlert.customAlert(
                            context,
                            "store.processtimeline_screen.alert.title".tr(),
                            "คุณต้องการจะสั่งซื้อสินค้าใช่หรือไม่ ?",
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
      body: RefreshIndicator(
        edgeOffset: 0,
        color: Colors.white,
        backgroundColor: Styles.primaryColor,
        onRefresh: () async {
          await _getCart();
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
                                      onPressed: () {},
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
                                            flex: 3,
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
                                                    '${ApiService.apiHost}/images/products/${cartList[index].id}.webp',
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
                                                                            index],
                                                                        "IN");
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
                                                                    await _reduceCart(
                                                                        cartList[
                                                                            index],
                                                                        "OUT");

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
                                                      '${ApiService.apiHost}/images/products/${listPromotions[innerIndex].id}.webp',
                                                      width: screenWidth / 8,
                                                      height: screenWidth / 8,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          width:
                                                              screenWidth / 8,
                                                          height:
                                                              screenWidth / 8,
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
                                                                  '${listPromotions[innerIndex].proId ?? ""} ${listPromotions[innerIndex].proCode ?? ""}',
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
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  listPromotions[
                                                                              innerIndex]
                                                                          .proName ??
                                                                      "",
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
                                                                  Text(
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
                                                                  Text(
                                                                    '${listPromotions[innerIndex].id}',
                                                                    style: Styles
                                                                        .black16(
                                                                            context),
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
                                                                      '${listPromotions[innerIndex].qty.toStringAsFixed(0)} ${unitPromotionText}',
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
                                                                      await _changeProduct2(
                                                                          listPromotions[innerIndex]
                                                                              .proId);

                                                                      // 2. ใช้ itemProductChange (หรืออะไรก็ตามที่ _changeProduct2 ไป set ให้) เป็นแหล่งข้อมูล
                                                                      // filter จาก itemProductChange (เป็น ItemProductChange) ให้ได้ proId ที่ต้องการ
                                                                      List<PromotionListItem> itemsOfPro = itemProductChange
                                                                          // ถ้าอยาก filter เฉพาะสินค้าของ proId นี้ (ถ้ามี field proId ใน ItemProductChange ด้วย)
                                                                          // .where((e) => e.proId == listPromotions[innerIndex].proId)

                                                                          // หรือถ้าไม่มี field proId ใน ItemProductChange
                                                                          // (เช่น ถ้าของเปลี่ยนโปรนี้ทั้งหมดให้เลือกได้หมด ไม่ต้องกรอง)
                                                                          // ก็ map ได้เลยทุกตัว

                                                                          // --- map เป็น PromotionListItem ด้วย extension ---
                                                                          .map((e) => e.toPromotionListItem(
                                                                                proId: listPromotions[innerIndex].proId,
                                                                                proName: listPromotions[innerIndex].proName,
                                                                                // เพิ่ม unit/unitName ตาม context ของโปรฯ ที่ใช้อยู่
                                                                                unit: listPromotions[innerIndex].unit, // หรือใส่ค่าตามจริง
                                                                                unitName: listPromotions[innerIndex].unitName, // หรือใส่ค่าตามจริง
                                                                              ))
                                                                          .toList();

                                                                      // หาค่า totalShow หรือ total ของ proId นั้นๆ
                                                                      final tc =
                                                                          totalChangeList
                                                                              .firstWhere(
                                                                        (e) =>
                                                                            e.proId ==
                                                                            listPromotions[innerIndex].proId,
                                                                        orElse: () => TotalProductChang(
                                                                            proId: listPromotions[innerIndex].proId ??
                                                                                '',
                                                                            total:
                                                                                0,
                                                                            totalShow:
                                                                                0),
                                                                      );
                                                                      // ถ้าไม่มีข้อมูลเลย
                                                                      if (itemsOfPro
                                                                          .isEmpty) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                              content: Text('ไม่มีสินค้าเปลี่ยนโปรโมชั่น')),
                                                                        );
                                                                        return;
                                                                      }

                                                                      final int
                                                                          maxQty =
                                                                          tc.totalShow; // หรือ tc.total

                                                                      // 3. ระบุจำนวนสูงสุดที่สามารถเลือกได้
                                                                      // int maxQty = itemsOfPro.fold(
                                                                      //     0,
                                                                      //     (a, b) =>
                                                                      //         a +
                                                                      //         b.qty);

                                                                      // 4. เปิด Modal ให้เลือก
                                                                      final result =
                                                                          await _showChangePromotionSheet(
                                                                        context:
                                                                            context,
                                                                        productList:
                                                                            itemsOfPro,
                                                                        unitText: itemsOfPro
                                                                            .first
                                                                            .unitName,
                                                                        proId: itemsOfPro
                                                                            .first
                                                                            .proId,
                                                                        proName: itemsOfPro
                                                                            .first
                                                                            .proName,
                                                                        maxQty:
                                                                            maxQty,
                                                                      );

                                                                      // 5. รับค่าที่เปลี่ยนกลับมาแล้วแทนที่ listPromotions เดิม
                                                                      if (result !=
                                                                          null) {
                                                                        setState(
                                                                            () {
                                                                          promotionListChangeStatus =
                                                                              1;
                                                                          listPromotions.removeWhere((e) =>
                                                                              e.proId ==
                                                                              listPromotions[innerIndex].proId);
                                                                          listPromotions
                                                                              .addAll(result);
                                                                        });
                                                                      }
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
                                                color: Styles.primaryColorIcons,
                                                size: 40,
                                              ),
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
                                      ShowPhotoButton(
                                        checkNetwork: true,
                                        label: "QR Code",
                                        icon:
                                            Icons.image_not_supported_outlined,
                                        imagePath: qrImage != "" ? qrImage : '',
                                      ),
                                      IconButtonWithLabelOld(
                                        icon: Icons.photo_camera,
                                        imagePath: qrImagePath != ""
                                            ? qrImagePath
                                            : null,
                                        label: "ถ่ายภาพการโอน",
                                        onImageSelected:
                                            (String imagePath) async {
                                          setState(() {
                                            qrImagePath = imagePath;
                                          });
                                        },
                                      ),
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

  Future<List<PromotionListItem>?> _showChangePromotionSheet({
    required BuildContext context,
    required List<PromotionListItem> productList,
    required String unitText,
    String? proId,
    String? proName,
    int? maxQty,
  }) {
    // สร้าง deep copy เพื่อแก้ไขใน modal
    List<PromotionListItem> editingList =
        productList.map((e) => e.copyWith()).toList();
    List<PromotionListItem> originalList =
        listPromotions.map((e) => e.copyWith()).toList();

    return showModalBottomSheet<List<PromotionListItem>>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => _ChangePromotionSheetBody(
        editingList: editingList,
        originalList: originalList,
        unitText: unitText,
        proName: proName,
        maxQty: maxQty,
        proId: proId ?? "",
      ),
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

// ----- ตัว widget Modal sheet -----

class _ChangePromotionSheetBody extends StatefulWidget {
  final List<PromotionListItem> editingList;
  final List<PromotionListItem> originalList;
  final String unitText;
  final String? proName;
  final int? maxQty;
  final String proId;

  const _ChangePromotionSheetBody({
    super.key,
    required this.editingList,
    required this.originalList,
    required this.unitText,
    this.proName,
    this.maxQty,
    required this.proId,
  });

  @override
  State<_ChangePromotionSheetBody> createState() =>
      _ChangePromotionSheetBodyState();
}

class _ChangePromotionSheetBodyState extends State<_ChangePromotionSheetBody> {
  late List<PromotionListItem> list;

  int get totalQty => widget.originalList
      .where((el) => el.proId == widget.proId)
      .fold(0, (prev, el) => prev + (el.qty > 0 ? el.qty : 0));

  @override
  void initState() {
    super.initState();
    list = widget.editingList;
  }

  void _addQty(int idx) {
    setState(() {
      if ((widget.maxQty == null) || (totalQty < widget.maxQty!)) {
        final item = list[idx];
        final oriIdx = widget.originalList.indexWhere((e) => e.id == item.id);
        if (oriIdx != -1) {
          widget.originalList[oriIdx] = widget.originalList[oriIdx]
              .copyWith(qty: widget.originalList[oriIdx].qty + 1);
        } else {
          widget.originalList.add(item.copyWith(qty: 1));
        }
      }
      // ถ้า totalQty >= maxQty จะเพิ่มไม่ได้
    });
  }

  void _removeQty(int idx) {
    setState(() {
      final item = list[idx];
      final oriIdx = widget.originalList.indexWhere((e) => e.id == item.id);
      if (oriIdx != -1 && widget.originalList[oriIdx].qty > 0) {
        widget.originalList[oriIdx] = widget.originalList[oriIdx]
            .copyWith(qty: widget.originalList[oriIdx].qty - 1);
      }
      // ไม่ต้อง remove ออกจาก originalList ก็ได้ ให้ qty = 0 ไว้เฉยๆ
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Text(
                "เปลี่ยนโปรโมชั่น${widget.proName != null ? ' (${widget.proName})' : ''}",
                style: Styles.black18(context),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: list.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final item = list[idx];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          margin: EdgeInsets.only(right: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              '${ApiService.apiHost}/images/products/${item.id}.webp',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey,
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.white, size: 48),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: Styles.black18(context),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'id: ${item.id}  (${item.group} ${item.size})',
                                  style: Styles.black18(context),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: item.qty > 0
                                          ? () => _removeQty(idx)
                                          : null,
                                    ),
                                    Container(
                                      width: 36,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${widget.originalList.firstWhere(
                                              (promo) => promo.id == item.id,
                                              orElse: () =>
                                                  item.copyWith(qty: 0),
                                            ).qty}',
                                        style: Styles.black18(context),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () => _addQty(idx),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "รวมทั้งหมด: $totalQty/${widget.maxQty ?? '-'} ${widget.unitText}",
                    style: Styles.black18(context),
                  ),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        (totalQty == (widget.maxQty ?? 0))
                            ? Styles.success // เลือกครบ ใช้สีเขียว
                            : Colors.grey.shade400, // เลือกไม่ครบ ใช้สีเทาอ่อน
                      ),
                    ),
                    icon: Icon(Icons.check_circle_outline, color: Colors.white),
                    label: Text("บันทึก", style: Styles.white18(context)),
                    onPressed: (totalQty == (widget.maxQty ?? 0))
                        ? () {
                            Navigator.pop(
                              context,
                              widget.originalList
                                  .where((e) =>
                                      e.qty > 0 && e.proId == widget.proId)
                                  .toList(),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
