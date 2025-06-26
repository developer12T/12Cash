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

  String promotionListChangeStatus = '0';

  String qrImage = '';

  List<PromotionListItem> listPromotions = [];
  List<PromotionListItem> listPromotionsMock = [];

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

          // itemProductChange.clear();
          // for (var changePromotion in listChangePromotions) {
          //   groupPromotion.add(
          //     GroupPromotion(
          //         group: changePromotion.group, size: changePromotion.size),
          //   );
          //   for (var itemChange in changePromotion.product) {
          //     itemProductChange.add(itemChange);
          //   }
          // }
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
            proType: proList.proType,
            proQty: proList.proQty,
            discount: discount,
            listPromotion: listPromotions
                .where((item) => item.proId == proList.proId)
                .toList(),
          ),
        );
      }

      ApiService apiService = ApiService();
      print("promotionListChange $promotionListChange");
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
          "shipping": "test",
          "payment": isSelectCheckout == "QR Payment" ? "qr" : "cash",
          "changePromotionStatus": promotionListChangeStatus,
          "listPromotion": promotionListChange,
        },
      );
      if (response.statusCode == 200) {
        // await _addStockMovement(response.data['data']['orderId']);
        if (isSelectCheckout == "QR Payment") {
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

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => OrderDetailScreen(
      //       orderId: response.data['data']['orderId'],
      //     ),
      //   ),
      // );
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
            for (var item in promotion.listPromotion) {
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

  Future<void> _updateStock2(CartList product, String type) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
          endpoint: 'api/cash/cart/updateStock',
          method: 'POST',
          body: {
            "area": "${User.area}",
            "period": "${period}",
            "unit": "${product.unit}",
            "productId": "${product.id}",
            "qty": "${product.qty.toInt()}",
            "type": type
          });

      if (response.statusCode == 200) {
        // setModalState(
        //   () {
        //     stockQty -= count.toInt();
        //   },
        // );
      }
      print(response.data['data']);
    } catch (e) {
      print("Error in _updateStock $e");
    }
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
            endpoint: 'api/cash/cart/adjust',
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
      body: Focus(
        // focusNode: _focusNode,
        autofocus: true,
        child: NotificationListener<ScrollNotification>(
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
                                            side: BorderSide
                                                .none, // Remove border
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
                                                      style: Styles.grey18(
                                                          context),
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
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.network(
                                                      '${ApiService.apiHost}/images/products/${cartList[index].id}.webp',
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
                                                                  cartList[
                                                                          index]
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
                                                                        style: Styles.black16(
                                                                            context),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'จำนวน : ${cartList[index].qty.toStringAsFixed(0)} ${cartList[index].unitName}',
                                                                        style: Styles.black16(
                                                                            context),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'ราคา : ${cartList[index].price}',
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
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        if (cartList[index].qty >
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
                                                                            color:
                                                                                Colors.grey,
                                                                            width: 1),
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
                                                                              index]);

                                                                      setState(
                                                                          () {
                                                                        cartList[index]
                                                                            .qty++;
                                                                      });
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      shape:
                                                                          const CircleBorder(
                                                                        side: BorderSide(
                                                                            color:
                                                                                Colors.grey,
                                                                            width: 1),
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
                                                                      await _updateStock2(
                                                                          cartList[
                                                                              index],
                                                                          "IN");
                                                                      await _deleteCart(
                                                                          cartList[
                                                                              index]);

                                                                      setState(
                                                                        () {
                                                                          cartList.removeWhere((item) =>
                                                                              (item.id == cartList[index].id && item.unit == cartList[index].unit));
                                                                        },
                                                                      );
                                                                      // await _getTotalCart(setModalState);
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      shape:
                                                                          const CircleBorder(
                                                                        side: BorderSide(
                                                                            color:
                                                                                Colors.red,
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
                                          controller:
                                              _promotionScrollController,
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
                                                            const EdgeInsets
                                                                .all(16.0),
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
                                                                          style:
                                                                              Styles.black16(context),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    // Row(
                                                                    //   children: [
                                                                    //     Text(
                                                                    //       '${listPromotions[innerIndex].group} รส${listPromotions[innerIndex].flavour}',
                                                                    //       style: Styles.black16(
                                                                    //           context),
                                                                    //     ),
                                                                    //   ],
                                                                    // ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
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
                                                                          width:
                                                                              1,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(16),
                                                                      ),
                                                                      width: 75,
                                                                      child:
                                                                          Text(
                                                                        '${listPromotions[innerIndex].qty.toStringAsFixed(0)} ${unitPromotionText}',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: Styles
                                                                            .black18(
                                                                          context,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        // setState(
                                                                        //   () {
                                                                        //     itemQuantities = List.filled(
                                                                        //         itemProductChange.length,
                                                                        //         1);
                                                                        //   },
                                                                        // );

                                                                        // await _changeTotalProduct();

                                                                        await _changeProduct2(
                                                                            listPromotions[innerIndex].proId);
                                                                        _showChangePromotionSheet(
                                                                          context,
                                                                          itemProductChange,
                                                                          listPromotions[innerIndex]
                                                                              .proId,
                                                                          listPromotions[innerIndex]
                                                                              .proName,
                                                                          listPromotions[innerIndex]
                                                                              .proType,
                                                                        );
                                                                        listPromotions.removeWhere((item) =>
                                                                            item.proId ==
                                                                            listPromotions[innerIndex].proId);
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        shape:
                                                                            CircleBorder(
                                                                          side: BorderSide(
                                                                              color: Styles.warning!,
                                                                              width: 1),
                                                                        ),
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                        backgroundColor:
                                                                            Colors.white, // Button color
                                                                      ),
                                                                      child:
                                                                          Icon(
                                                                        FontAwesomeIcons
                                                                            .penToSquare,
                                                                        size:
                                                                            24,
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
                                            side: BorderSide
                                                .none, // Remove border
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
                                                  color:
                                                      Styles.primaryColorIcons,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          icon: Icons
                                              .image_not_supported_outlined,
                                          imagePath:
                                              qrImage != "" ? qrImage : '',
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
                                            // await uploadFormDataWithDio(
                                            //     imagePath, 'store', context);
                                          },
                                        ),
                                        // MenuButton(
                                        //   color: Styles.success!,
                                        //   icon: Icons.upload,
                                        //   label: "อัพโหลด",
                                        //   onPressed: () {},
                                        // )
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
      ),
    );
  }

  void _showChangePromotionSheet(
      BuildContext context,
      List<ItemProductChange> cartlist,
      String? proId,
      String? proName,
      String? proType) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    List<ItemProductChange> filteredPromotion = List.from(cartlist);
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
            initialChildSize: 1, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return GestureDetector(
                onVerticalDragUpdate: (_) {}, // Disable vertical drag
                child: Container(
                  width: screenWidth,
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
                                // Text('เปลี่ยนโปรโมชั่น $proName',
                                //     style: Styles.white24(context)),
                                Text('$proId', style: Styles.white24(context)),
                              ],
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                if (totalChangeList
                                        .firstWhere(
                                            (item) => item.proId == proId)
                                        .total ==
                                    0) {
                                  Navigator.of(context).pop();
                                } else {
                                  toastification.show(
                                    autoCloseDuration:
                                        const Duration(seconds: 5),
                                    context: context,
                                    primaryColor: Colors.red,
                                    type: ToastificationType.error,
                                    style: ToastificationStyle.flatColored,
                                    title: Text(
                                      "กรุณาเลือกสินค้าโปรโมทชั่นให้ครบ",
                                      style: Styles.red18(context),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
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
                                    // ElevatedButton(
                                    //   onPressed: () {
                                    //     // setModalState(() {
                                    //     //   listPromotions.clear();
                                    //     // });
                                    //     // _getCart();
                                    //   },
                                    //   child: Text(
                                    //     'เลือกใหม่',
                                    //     style: Styles.black18(context),
                                    //   ),
                                    // ),
                                    // Clear Product Button
                                    // IconButton(
                                    //   onPressed: () {
                                    //     setModalState(() {
                                    //       if (listPromotionsMock.isNotEmpty) {
                                    //         listPromotionsMock.removeWhere(
                                    //             (item) =>
                                    //                 item.id ==
                                    //                 cartlist[index].id);
                                    //         listPromotions =
                                    //             List.from(listPromotionsMock);
                                    //       }
                                    //     });
                                    //   },
                                  ],
                                ),
                                Divider(
                                  color: Colors.black,
                                  indent: 1,
                                ),
                                Expanded(
                                    child: ListView.builder(
                                  itemCount: listPromotionsMock
                                      .where((item) => item.proId == proId)
                                      .length,
                                  itemBuilder: (context, index) {
                                    var filteredItems = listPromotionsMock
                                        .where((item) => item.proId == proId)
                                        .toList(); // Convert to a list after filtering
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
                                                '${ApiService.apiHost}/images/products/${listPromotionsMock[index].id}.webp',
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
                                                            filteredItems[index]
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
                                                                  'id : ${filteredItems[index].id}',
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
                                                                setModalState(
                                                                    () {
                                                                  if (totalChangeList
                                                                              .firstWhere((item) =>
                                                                                  item.proId ==
                                                                                  proId)
                                                                              .total +
                                                                          1 <
                                                                      totalChangeList
                                                                          .firstWhere((item) =>
                                                                              item.proId ==
                                                                              proId)
                                                                          .totalShow) {
                                                                    filteredItems[
                                                                            index]
                                                                        .qty--;

                                                                    totalChangeList
                                                                        .firstWhere((item) =>
                                                                            item.proId ==
                                                                            proId)
                                                                        .total += 1;
                                                                  }
                                                                });
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
                                                                  EdgeInsets
                                                                      .all(4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                              ),
                                                              width: 75,
                                                              child: Text(
                                                                '${filteredItems[index].qty} ${unitPromotionText}',
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
                                                                setModalState(
                                                                    () {
                                                                  if (totalChangeList
                                                                          .firstWhere((item) =>
                                                                              item.proId ==
                                                                              proId)
                                                                          .total >
                                                                      0) {
                                                                    filteredItems[
                                                                            index]
                                                                        .qty++;

                                                                    totalChangeList
                                                                        .firstWhere((item) =>
                                                                            item.proId ==
                                                                            proId)
                                                                        .total -= 1;
                                                                  }
                                                                });
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
                                                            IconButton(
                                                              onPressed: () {
                                                                setModalState(
                                                                  () {
                                                                    if (filteredItems
                                                                        .isNotEmpty) {
                                                                      if (filteredItems
                                                                              .length >
                                                                          1) {
                                                                        totalChangeList
                                                                            .firstWhere((item) =>
                                                                                item.proId ==
                                                                                proId)
                                                                            .total += filteredItems[
                                                                                index]
                                                                            .qty;
                                                                        listPromotionsMock.removeWhere((item) =>
                                                                            item.id == filteredItems[index].id &&
                                                                            item.proId ==
                                                                                filteredItems[index].proId);
                                                                      } else {
                                                                        toastification
                                                                            .show(
                                                                          autoCloseDuration:
                                                                              const Duration(seconds: 5),
                                                                          context:
                                                                              context,
                                                                          primaryColor:
                                                                              Colors.red,
                                                                          type:
                                                                              ToastificationType.error,
                                                                          style:
                                                                              ToastificationStyle.flatColored,
                                                                          title:
                                                                              Text(
                                                                            "มีเพียงรายการเดียวไม่สมารถลบได้",
                                                                            style:
                                                                                Styles.red18(context),
                                                                          ),
                                                                        );
                                                                      }
                                                                    }
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                FontAwesomeIcons
                                                                    .trash,
                                                                color:
                                                                    Colors.red,
                                                                size: 24,
                                                              ),
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
                                )),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "รายการโปรโมชั่นที่สามารถเปลี่ยนได้",
                                      style: Styles.black18(context),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: DropdownSearch<GroupPromotion>(
                                        dropdownButtonProps:
                                            DropdownButtonProps(
                                          color: Colors.white,
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            size: screenWidth / 20,
                                            color: Colors.black54,
                                          ),
                                        ),

                                        itemAsString: (item) =>
                                            "${item.group} ${item.size}",
                                        asyncItems: (filter) =>
                                            getGroupDropdown(filter),
                                        // items:(filter, infiniteScrollProps) =>
                                        dropdownDecoratorProps:
                                            DropDownDecoratorProps(
                                          baseStyle: Styles.black18(context),
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            // fillColor: Colors.white,
                                            // prefixIcon: widget.icon,
                                            labelText:
                                                "เลือกกลุ่มของโปรโมทชั่น",
                                            labelStyle: Styles.grey18(context),
                                            hintText: "เลือกกลุ่มของโปรโมทชั่น",
                                            hintStyle: Styles.grey18(context),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 1.5),
                                            ),
                                          ),
                                        ),
                                        onChanged: (GroupPromotion? data) {
                                          setModalState(() {
                                            filteredPromotion = cartlist
                                                .where((store) =>
                                                    // store.name
                                                    //     .contains(value!.group) &&
                                                    store.name.contains(
                                                        data!.group) &&
                                                    store.name.contains(data!
                                                        .size
                                                        .replaceAll(" ", "")
                                                        .toLowerCase()))
                                                .toList();
                                          });
                                        },
                                        popupProps:
                                            PopupPropsMultiSelection.dialog(
                                          constraints: BoxConstraints(
                                            maxHeight: screenWidth * 0.7,
                                            maxWidth: screenWidth,
                                            minHeight: screenWidth * 0.7,
                                            minWidth: screenWidth,
                                          ),
                                          title: Container(
                                            decoration: const BoxDecoration(
                                              color: Styles.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Text(
                                              "เลือกกลุ่มของโปรโมทชั่น",
                                              style: Styles.white18(context),
                                            ),
                                          ),

                                          // showSearchBox: widget.showSearchBox,
                                          itemBuilder:
                                              (context, item, isSelected) {
                                            return Column(
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    "${item.group} ${item.size}",
                                                    style:
                                                        Styles.black18(context),
                                                  ),
                                                  selected: isSelected,
                                                ),
                                                Divider(
                                                  color: Colors.grey[
                                                      200], // Color of the divider line
                                                  thickness:
                                                      1, // Thickness of the line
                                                  indent:
                                                      16, // Left padding for the divider line
                                                  endIndent:
                                                      16, // Right padding for the divider line
                                                ),
                                              ],
                                            );
                                          },
                                          searchFieldProps: TextFieldProps(
                                            style: Styles.black18(context),
                                            autofocus: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.black,
                                  indent: 1,
                                ),
                                Expanded(
                                    child: ListView.builder(
                                  itemCount: filteredPromotion.length,
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
                                                '${ApiService.apiHost}/images/products/${filteredPromotion[index].id}.webp',
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
                                                            filteredPromotion[
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
                                                                  'id : ${filteredPromotion[index].id}',
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
                                                                setModalState(
                                                                    () {
                                                                  if (cartlist[
                                                                              index]
                                                                          .qty >
                                                                      1) {
                                                                    cartlist[
                                                                            index]
                                                                        .qty--;
                                                                  }
                                                                });
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
                                                                  EdgeInsets
                                                                      .all(4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                              ),
                                                              width: 75,
                                                              child: Text(
                                                                '${cartlist[index].qty}',
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
                                                                if (cartlist[
                                                                            index]
                                                                        .qty <
                                                                    totalChangeList
                                                                        .firstWhere((item) =>
                                                                            item.proId ==
                                                                            proId)
                                                                        .total) {
                                                                  setModalState(
                                                                      () {
                                                                    cartlist[
                                                                            index]
                                                                        .qty++;
                                                                  });
                                                                }
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
                                                                setModalState(
                                                                  () {
                                                                    setState(
                                                                        () {
                                                                      promotionListChangeStatus =
                                                                          '1';
                                                                    });
                                                                    print(
                                                                        "promotionListChangeStatus $promotionListChangeStatus");
                                                                    print(
                                                                        "proId $proId");
                                                                    print(
                                                                        "total $total");
                                                                    print(
                                                                        "totalChangeList ${totalChangeList.firstWhere((item) => item.proId == proId).total}");

                                                                    if (totalChangeList
                                                                            .firstWhere((item) =>
                                                                                item.proId ==
                                                                                proId)
                                                                            .total >=
                                                                        cartlist[index]
                                                                            .qty) {
                                                                      totalChangeList
                                                                          .firstWhere((item) =>
                                                                              item.proId ==
                                                                              proId)
                                                                          .total -= cartlist[
                                                                              index]
                                                                          .qty;

                                                                      print(
                                                                          "cartlist[index] ${cartlist[index].qty}");

                                                                      if (listPromotionsMock
                                                                          .isNotEmpty) {
                                                                        if (listPromotionsMock.any((item) =>
                                                                            item.id ==
                                                                            cartlist[index].id)) {
                                                                          listPromotionsMock
                                                                              .firstWhere((item) => item.id == cartlist[index].id)
                                                                              .qty += cartlist[index].qty;

                                                                          listPromotions
                                                                              .firstWhere((item) => item.id == cartlist[index].id)
                                                                              .qty += cartlist[index].qty;
                                                                        } else {
                                                                          listPromotionsMock
                                                                              .add(
                                                                            PromotionListItem(
                                                                              proId: proId,
                                                                              proName: proName,
                                                                              id: cartlist[index].id,
                                                                              name: cartlist[index].name,
                                                                              unit: listPromotions.isNotEmpty ? listPromotions[0].unit : '',
                                                                              brand: cartlist[index].brand,
                                                                              flavour: cartlist[index].flavour,
                                                                              group: cartlist[index].group,
                                                                              qty: cartlist[index].qty,
                                                                              size: cartlist[index].size,
                                                                              unitName: listPromotions.isNotEmpty ? listPromotions[0].unitName : '',
                                                                            ),
                                                                          );
                                                                          listPromotions
                                                                              .add(
                                                                            PromotionListItem(
                                                                              proId: proId,
                                                                              proName: proName,
                                                                              id: cartlist[index].id,
                                                                              name: cartlist[index].name,
                                                                              unit: listPromotions.isNotEmpty ? listPromotions[0].unit : '',
                                                                              brand: cartlist[index].brand,
                                                                              flavour: cartlist[index].flavour,
                                                                              group: cartlist[index].group,
                                                                              qty: cartlist[index].qty,
                                                                              size: cartlist[index].size,
                                                                              unitName: listPromotions.isNotEmpty ? listPromotions[0].unitName : '',
                                                                            ),
                                                                          );
                                                                        }
                                                                      } else {
                                                                        listPromotionsMock
                                                                            .add(
                                                                          PromotionListItem(
                                                                            proId:
                                                                                proId,
                                                                            proName:
                                                                                proName,
                                                                            id: cartlist[index].id,
                                                                            name:
                                                                                cartlist[index].name,
                                                                            unit: listPromotions.isNotEmpty
                                                                                ? listPromotions[0].unit
                                                                                : '',
                                                                            brand:
                                                                                cartlist[index].brand,
                                                                            flavour:
                                                                                cartlist[index].flavour,
                                                                            group:
                                                                                cartlist[index].group,
                                                                            qty:
                                                                                cartlist[index].qty,
                                                                            size:
                                                                                cartlist[index].size,
                                                                            unitName: listPromotions.isNotEmpty
                                                                                ? listPromotions[0].unitName
                                                                                : '',
                                                                          ),
                                                                        );
                                                                        listPromotions
                                                                            .add(
                                                                          PromotionListItem(
                                                                            proId:
                                                                                proId,
                                                                            proName:
                                                                                proName,
                                                                            id: cartlist[index].id,
                                                                            name:
                                                                                cartlist[index].name,
                                                                            unit: listPromotions.isNotEmpty
                                                                                ? listPromotions[0].unit
                                                                                : '',
                                                                            brand:
                                                                                cartlist[index].brand,
                                                                            flavour:
                                                                                cartlist[index].flavour,
                                                                            group:
                                                                                cartlist[index].group,
                                                                            qty:
                                                                                cartlist[index].qty,
                                                                            size:
                                                                                cartlist[index].size,
                                                                            unitName: listPromotions.isNotEmpty
                                                                                ? listPromotions[0].unitName
                                                                                : '',
                                                                          ),
                                                                        );
                                                                      }
                                                                    }
                                                                  },
                                                                );
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                shape:
                                                                    CircleBorder(
                                                                  side: BorderSide(
                                                                      color: Styles
                                                                          .warning!,
                                                                      width: 1),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(8),
                                                                backgroundColor:
                                                                    Colors
                                                                        .white, // Button color
                                                              ),
                                                              child: Icon(
                                                                FontAwesomeIcons
                                                                    .penToSquare,
                                                                size: 24,
                                                                color: Styles
                                                                    .warning,
                                                              ),
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
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Styles.primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("จำนวนที่เหลือ",
                                      style: Styles.white24(context)),
                                  Text(
                                      "${totalChangeList.firstWhere((item) => item.proId == proId).total} ${unitPromotionText}",
                                      style: Styles.white24(context)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("จำนวนที่เลือกได้",
                                      style: Styles.white24(context)),
                                  Text(
                                      "${totalChangeList.firstWhere((item) => item.proId == proId).totalShow} ${unitPromotionText}",
                                      style: Styles.white24(context)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
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
