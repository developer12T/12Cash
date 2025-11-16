import 'dart:async';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/filter/BadageFilter.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListCard.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListVerticalCard.dart';
import 'package:_12sale_app/core/components/search/ProductSearch.dart';
import 'package:_12sale_app/core/components/search/StoreSearch.dart';
import 'package:_12sale_app/core/components/service/ProductService.dart';
import 'package:_12sale_app/core/page/order/CreateOrderScreen.dart';
import 'package:_12sale_app/core/page/order/CreateOrderScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/Cart.dart';
import 'package:_12sale_app/data/models/order/Product.dart';
import 'package:_12sale_app/data/models/route/DetailStoreVisit.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/main.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dartx/dartx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';

class OrderINRouteScreen extends StatefulWidget {
  final DetailStoreVisit? storeDetail;
  final String? routeId;

  const OrderINRouteScreen({
    super.key,
    required this.storeDetail,
    required this.routeId,
  });

  @override
  State<OrderINRouteScreen> createState() => _OrderINRouteScreenState();
}

class _OrderINRouteScreenState extends State<OrderINRouteScreen>
    with RouteAware {
  final Debouncer _debouncer = Debouncer();
  final Throttler _throttler = Throttler();

  List<Product> productList = [];
  List<Product> filteredProductList = [];
  List<CartList> cartList = [];

  bool _loadingProduct = true;

  List<String> groupList = [];
  List<String> selectedGroups = [];

  List<String> brandList = [];
  List<String> selectedBrands = [];

  List<String> sizeList = [];
  List<String> selectedSizes = [];

  List<String> flavourList = [];
  List<String> selectedFlavours = [];

  bool _isGridView = false;
  int _isSelectedGridView = 1;

  int count = 1;
  double price = 0;
  double total = 0.00;
  String selectedSize = "";
  String selectedUnit = "";
  double totalCart = 0.00;

  int stockQty = 0;
  // String lotStock = "";

  String selectedStore = "กรุณาเลือกร้านค้า";
  String selectedStoreId = "";
  String selectedStoreAddress = "";
  String selectedStoreTel = "";
  String selectedStoreShopType = "";

  final ScrollController _cartScrollController = ScrollController();
  final ScrollController _productScrollController = ScrollController();
  final ScrollController _productListScrollController = ScrollController();
  TextEditingController countController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  bool _isLoading = false;
  int _page = 1;
  bool _hasMore = true;
  List<Product> _product = [];
  final ScrollController _productGridController = ScrollController();
  final ScrollController _listController2 = ScrollController();
  bool _isPaginating = false;

  @override
  void initState() {
    super.initState();
    _getFliter();
    // _getProduct(true);
    _loadProduct();
    _getFliterSize();
    _getCart();
    _listController2.addListener(_onScroll);
    _productGridController.addListener(_onScrollGird);
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
  void dispose() {
    // Unsubscribe when the widget is disposed
    routeObserver.unsubscribe(this);
    _cartScrollController.dispose();
    _productScrollController.dispose();
    _productListScrollController.dispose();
    super.dispose();
  }

  bool isInteger(String input) {
    return int.tryParse(input) != null;
  }

  void _onScroll() {
    if (!_listController2.hasClients || _isPaginating || !_hasMore) return;

    // เหลือคอนเทนต์ข้างหน้า < 200px ค่อยโหลดเพิ่ม
    if (_listController2.position.extentAfter < 200) {
      _paginate();
    }
  }

  void _onScrollGird() {
    if (!_productGridController.hasClients || _isPaginating || !_hasMore)
      return;

    // เหลือคอนเทนต์ข้างหน้า < 200px ค่อยโหลดเพิ่ม
    if (_productGridController.position.extentAfter < 200) {
      _paginate();
    }
  }

  Future<void> _paginate() async {
    _isPaginating = true;
    try {
      await _loadProduct(); // ดึงหน้าถัดไป และทำ setState ภายใน
    } finally {
      _isPaginating = false;
    }
  }

  Future<void> _deleteCart(CartList cart, StateSetter setModalState) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/cart/delete',
        method: 'POST',
        body: {
          "type": "sale",
          "area": "${User.area}",
          "storeId": "${widget.storeDetail?.listStore[0].storeInfo.storeId}",
          "id": "${cart.id}",
          "unit": "${cart.unit}"
        },
      );
      if (response.statusCode == 200) {
        await _getTotalCart(setModalState);
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
    } catch (e) {
      print("Error _deleteCart: $e");
    }
  }

  Future<void> _getQty(Product product, StateSetter setModalState) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/stock/get',
        method: 'POST',
        body: {
          "area": "${User.area}",
          "period": "${period}",
          "unit": "${selectedUnit}",
          "productId": "${product.id}",
        },
      );

      if (response.statusCode == 200) {
        print(response.data['data']);
        setModalState(
          () {
            stockQty = response.data['data']['qty'].toInt();
            // lotStock = response.data['data']['lot'];
          },
        );
        setState(() {
          stockQty = response.data['data']['qty'].toInt();
          // lotStock = response.data['data']['lot'];
        });
      }
    } catch (e) {
      print({
        "area": "${User.area}",
        "period": "${period}",
        "unit": "${selectedUnit}",
        "id": "${product.id}",
      });

      print("Error in _getQty $e");
    }
  }

  Future<void> _reduceCart(
      CartList cart, StateSetter setModalState, String stockType) async {
    const duration = Duration(seconds: 1);

    _debouncer.debounce(
      duration: duration,
      onDebounce: () async {
        try {
          ApiService apiService = ApiService();
          await apiService.init();
          var response = await apiService.request(
            endpoint: 'api/cash/cart/adjust',
            method: 'PATCH',
            body: {
              "type": "sale",
              "area": "${User.area}",
              "storeId":
                  "${widget.storeDetail?.listStore[0].storeInfo.storeId}",
              "id": "${cart.id}",
              "qty": cart.qty,
              "unit": "${cart.unit}",
              "stockType": stockType
            },
          );
          if (response.statusCode == 200) {
            await _getTotalCart(setModalState);
            _getProduct(true);
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
          } else {
            toastification.show(
              autoCloseDuration: const Duration(seconds: 5),
              context: context,
              primaryColor: Colors.red,
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              title: Text(
                "เกิดข้อผิดพลาด",
                style: Styles.red18(context),
              ),
            );
          }
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
          } else {
            toastification.show(
              autoCloseDuration: const Duration(seconds: 5),
              context: context,
              primaryColor: Colors.red,
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              title: Text(
                "เกิดข้อผิดพลาด: ${e.message}",
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
        }
      },
    );
  }

  Future<void> _getTotalCart(StateSetter setModalState) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/get?type=sale&area=${User.area}&storeId=${widget.storeDetail?.listStore[0].storeInfo.storeId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        setState(() {
          totalCart = response.data['data'][0]['total'].toDouble();
        });
        setModalState(
          () {
            totalCart = response.data['data'][0]['total'].toDouble();
          },
        );
      }
    } catch (e) {
      setState(() {
        totalCart = 00.00;
      });
      print("Error _getTotalCart: $e");
    }
  }

  Future<void> _getCart() async {
    try {
      print("Get Cart is Loading");
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/get?type=sale&area=${User.area}&storeId=${widget.storeDetail?.listStore[0].storeInfo.storeId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'][0]['listProduct'];
        setState(() {
          totalCart = response.data['data'][0]['total'].toDouble();
          cartList = data.map((item) => CartList.fromJson(item)).toList();
        });
      }
    } catch (e) {
      setState(() {
        totalCart = 00.00;
        cartList = [];
      });

      print("Error _getCart: $e");
    }
  }

  Future<void> _addCart(Product product) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      print(count);
      var response = await apiService.request(
        endpoint: 'api/cash/cart/add',
        method: 'POST',
        body: {
          "type": "sale",
          "area": "${User.area}",
          "storeId": "${widget.storeDetail?.listStore[0].storeInfo.storeId}",
          "id": "${product.id}",
          "qty": count,
          "unit": "${selectedUnit}",
          // "lot": "${lotStock}"
        },
      );
      print("Response add Cart: ${response.data['data']['listProduct']}");
      if (response.statusCode == 200) {
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

        final List<dynamic> data = response.data['data']['listProduct'];
        setState(() {
          cartList = data.map((item) => CartList.fromJson(item)).toList();
        });
      }
    } catch (e) {
      print("Error addCart: $e");
    }
  }

  Future<void> _getProduct(bool limit) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
        endpoint: 'api/cash/product/get',
        method: 'POST',
        body: {
          "type": "sale",
          "limit": limit,
          "period": "${period}",
          "area": "${User.area}",
          "group": selectedGroups,
          "brand": selectedBrands,
          "size": selectedSizes,
          "flavour": selectedFlavours
        },
      );
      print("Response: $response");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        if (mounted) {
          setState(() {
            productList = data.map((item) => Product.fromJson(item)).toList();
            filteredProductList = List.from(productList);
          });
          context.loaderOverlay.hide();
        }
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loadingProduct = false;
            });
          }
        });
      }
    } catch (e) {
      print("Error _getProduct: $e");
      print("Error _getProduct: $selectedGroups");
      print("Error _getProduct: $selectedBrands");
      print("Error _getProduct: $selectedSizes");
      print("Error _getProduct: $selectedFlavours");
    }
  }

  Future<void> _loadProduct({bool reset = false}) async {
    if (_isLoading || (!_hasMore && !reset)) return;

    // setState(() => _isLoading = true);
    if (reset) {
      _page = 1;
      _product.clear();
      _hasMore = true;
    }

    try {
      final fetched = await ProductService.fetchProduct(
        page: _page,
        selectedGroups: selectedGroups,
        selectedBrands: selectedBrands,
        selectedFlavours: selectedFlavours,
        selectedSizes: selectedSizes,
        q: searchController.text,
      );

      setState(() {
        _product.addAll(fetched);
        _isLoading = false;
        _hasMore = fetched.isNotEmpty;
        filteredProductList = List.from(_product);
        if (_hasMore) _page++;
      });

      print("_product ${fetched}");
      print(fetched);
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching _loadProduct: $e");
    }
  }

  Future<void> _getFliter() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
        endpoint: 'api/cash/product/filter',
        method: 'POST',
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataGroup = response.data['data']['group'];

        // print("_getFliter: ${response.data['data']['group']['group']}");
        if (mounted) {
          setState(() {
            groupList = List<String>.from(dataGroup);
          });
        }
        print("groupList: $groupList");
      }
    } catch (e) {
      print("Error getFliter: $e");
    }
  }

  Future<void> _getFliterGroup() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/product/filter',
        method: 'POST',
        body: {
          "group": selectedGroups,
          "brand": selectedBrands,
          "size": selectedSize,
          "flavour": selectedFlavours,
        },
      );
      setState(() {
        selectedBrands = [];
        selectedSizes = [];
        selectedFlavours = [];
        brandList = [];
        sizeList = [];
        flavourList = [];
      });
      if (response.statusCode == 200) {
        final List<dynamic> dataBrand = response.data['data']['brand'];
        final List<dynamic> dataSize = response.data['data']['size'];
        final List<dynamic> dataFlavour = response.data['data']['flavour'];

        setState(() {
          brandList = List<String>.from(dataBrand);
          sizeList = List<String>.from(dataSize);
          flavourList = List<String>.from(dataFlavour);
        });
      }
      if (selectedGroups.length == 0) {
        setState(() {
          selectedBrands = [];
          selectedSizes = [];
          selectedFlavours = [];
          brandList = [];
          sizeList = [];
          flavourList = [];
        });
      }
    } catch (e) {
      print("Error getFliterGroup: $e");
    }
  }

  Future<void> _getFliterBrand() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/product/filter',
        method: 'POST',
        body: {
          "group": selectedGroups,
          "brand": selectedBrands,
          "size": selectedSize,
          "flavour": selectedFlavours,
        },
      );
      setState(() {
        selectedSizes = [];
        selectedFlavours = [];
        sizeList = [];
        flavourList = [];
      });

      if (response.statusCode == 200) {
        final List<dynamic> dataSize = response.data['data']['size'];
        final List<dynamic> dataFlavour = response.data['data']['flavour'];
        if (mounted) {
          setState(() {
            sizeList = List<String>.from(dataSize);
            flavourList = List<String>.from(dataFlavour);
          });
        }
      }
    } catch (e) {
      print("Error _getFliterBrand: $e");
    }
  }

  Future<void> _getFliterSize() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/product/filter',
        method: 'POST',
        body: {
          "group": selectedGroups,
          "brand": selectedBrands,
          "size": selectedSize,
          "flavour": selectedFlavours,
        },
      );
      setState(() {
        selectedFlavours = [];
        flavourList = [];
      });

      if (response.statusCode == 200) {
        final List<dynamic> dataFlavour = response.data['data']['flavour'];
        if (mounted) {
          setState(() {
            flavourList = List<String>.from(dataFlavour);
          });
        }
      }
    } catch (e) {
      print("Error _getFliterSize: $e");
    }
  }

  Future<void> _clearFilter() async {
    setState(() {
      selectedBrands = [];
      selectedGroups = [];
      selectedSizes = [];
      selectedFlavours = [];
      brandList = [];
      sizeList = [];
      flavourList = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " สั่งซื้อสินค้า",
          icon: FontAwesomeIcons.clipboardList,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            // padding: const EdgeInsets.all(16.0),
            // margin: const EdgeInsets.all(8.0),
            child: LoadingSkeletonizer(
              loading: _isLoading,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    BoxShadowCustom(
                      child: Container(
                        margin: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.store,
                                  size: 40,
                                  color: Styles.primaryColorIcons,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  // flex: 2,
                                  child: Text(
                                    "${widget.storeDetail?.listStore[0].storeInfo.name}",
                                    style: Styles.black24(context),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "รหัสร้าน : ${widget.storeDetail?.listStore[0].storeInfo.storeId}",
                                        style: Styles.black18(context),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "เบอร์ติดต่อ : ${widget.storeDetail?.listStore[0].storeInfo.tel}",
                                        style: Styles.black18(context),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "ประเภท : ${widget.storeDetail?.listStore[0].storeInfo.typeName}",
                                    style: Styles.black18(context),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "ที่อยู่ : ${widget.storeDetail?.listStore[0].storeInfo.address}",
                                    style: Styles.black18(context),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: BoxShadowCustom(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              BadageFilter.showFilterSheet(
                                                context: context,
                                                title: 'เลือกกลุ่ม',
                                                title2: 'กลุ่ม',
                                                itemList: groupList,
                                                selectedItems: selectedGroups,
                                                onItemSelected:
                                                    (data, selected) {
                                                  if (selected) {
                                                    selectedGroups.add(data);
                                                  } else {
                                                    selectedGroups.remove(data);
                                                  }
                                                  _getFliterGroup();
                                                },
                                                onClear: () {
                                                  selectedGroups.clear();
                                                  selectedBrands.clear();
                                                  selectedSizes.clear();
                                                  selectedFlavours.clear();
                                                  brandList.clear();
                                                  sizeList.clear();
                                                  flavourList.clear();
                                                  context.loaderOverlay.show();
                                                  _loadProduct(reset: true)
                                                      .then((_) => Timer(
                                                              Duration(
                                                                  seconds: 3),
                                                              () {
                                                            context
                                                                .loaderOverlay
                                                                .hide();
                                                          }));
                                                },
                                                onSearch: () =>
                                                    _loadProduct(reset: true),
                                              );
                                            },
                                            child: badgeFilter(
                                              isSelected:
                                                  selectedGroups.isNotEmpty
                                                      ? true
                                                      : false,
                                              child: Text(
                                                selectedGroups.isEmpty
                                                    ? 'กลุ่ม'
                                                    : selectedGroups.join(', '),
                                                style: selectedGroups.isEmpty
                                                    ? Styles.black18(context)
                                                    : Styles.pirmary18(context),
                                                overflow: TextOverflow
                                                    .ellipsis, // Truncate if too long
                                                maxLines:
                                                    1, // Restrict to 1 line
                                                softWrap:
                                                    false, // Avoid wrapping
                                              ),
                                              width: selectedGroups.isEmpty
                                                  ? 85
                                                  : 120,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              BadageFilter.showFilterSheet(
                                                context: context,
                                                title: 'เลือกขนาด',
                                                title2: 'ขนาด',
                                                itemList: sizeList,
                                                selectedItems: selectedSizes,
                                                onItemSelected:
                                                    (data, selected) {
                                                  if (selected) {
                                                    selectedSizes.add(data);
                                                  } else {
                                                    selectedSizes.remove(data);
                                                  }
                                                  _getFliterSize();
                                                },
                                                onClear: () {
                                                  selectedSizes.clear();
                                                  selectedFlavours.clear();
                                                  brandList.clear();
                                                  sizeList.clear();
                                                  flavourList.clear();
                                                  context.loaderOverlay.show();
                                                  _loadProduct(reset: true)
                                                      .then((_) => Timer(
                                                              Duration(
                                                                  seconds: 3),
                                                              () {
                                                            context
                                                                .loaderOverlay
                                                                .hide();
                                                          }));
                                                },
                                                onSearch: () =>
                                                    _loadProduct(reset: true),
                                              );
                                            },
                                            child: badgeFilter(
                                              isSelected:
                                                  selectedSizes.isNotEmpty
                                                      ? true
                                                      : false,
                                              child: Text(
                                                selectedSizes.isEmpty
                                                    ? 'ขนาด'
                                                    : selectedSizes.join(', '),
                                                style: selectedSizes.isEmpty
                                                    ? Styles.black18(context)
                                                    : Styles.pirmary18(context),
                                                overflow: TextOverflow
                                                    .ellipsis, // Truncate if too long
                                                maxLines:
                                                    1, // Restrict to 1 line
                                                softWrap:
                                                    false, // Avoid wrapping
                                              ),
                                              width: selectedSizes.isEmpty
                                                  ? 120
                                                  : 120,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              BadageFilter.showFilterSheet(
                                                context: context,
                                                title: 'เลือกรสชาติ',
                                                title2: 'รสชาติ',
                                                itemList: flavourList,
                                                selectedItems: selectedFlavours,
                                                onItemSelected:
                                                    (data, selected) {
                                                  if (selected) {
                                                    selectedFlavours.add(data);
                                                  } else {
                                                    selectedFlavours
                                                        .remove(data);
                                                  }
                                                },
                                                onClear: () {
                                                  selectedFlavours.clear();
                                                  flavourList.clear();
                                                  context.loaderOverlay.show();
                                                  _loadProduct(reset: true)
                                                      .then((_) => Timer(
                                                              Duration(
                                                                  seconds: 3),
                                                              () {
                                                            context
                                                                .loaderOverlay
                                                                .hide();
                                                          }));
                                                },
                                                onSearch: () =>
                                                    _loadProduct(reset: true),
                                              );
                                            },
                                            child: badgeFilter(
                                              isSelected:
                                                  selectedFlavours.isNotEmpty
                                                      ? true
                                                      : false,
                                              child: Text(
                                                selectedFlavours.isEmpty
                                                    ? 'รสชาติ'
                                                    : selectedFlavours
                                                        .join(', '),
                                                style: selectedFlavours.isEmpty
                                                    ? Styles.black18(context)
                                                    : Styles.pirmary18(context),
                                                overflow: TextOverflow
                                                    .ellipsis, // Truncate if too long
                                                maxLines:
                                                    1, // Restrict to 1 line
                                                softWrap:
                                                    false, // Avoid wrapping
                                              ),
                                              width: selectedFlavours.isEmpty
                                                  ? 120
                                                  : 120,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _clearFilter();
                                              context.loaderOverlay.show();
                                              _loadProduct(reset: true).then(
                                                  (_) => Timer(
                                                          Duration(seconds: 3),
                                                          () {
                                                        context.loaderOverlay
                                                            .hide();
                                                      }));
                                            },
                                            child: badgeFilter(
                                              openIcon: false,
                                              child: Text(
                                                'ล้างตัวเลือก',
                                                style: Styles.grey18(context),
                                              ),
                                              width: 110,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        CustomSlidingSegmentedControl<int>(
                                          initialValue: 1,
                                          fixedWidth: 50,
                                          children: {
                                            1: Icon(
                                              FontAwesomeIcons.tableList,
                                              color: _isSelectedGridView == 1
                                                  ? Styles.primaryColor
                                                  : Styles.white,
                                            ),
                                            2: Icon(
                                              FontAwesomeIcons.tableCellsLarge,
                                              color: _isSelectedGridView == 2
                                                  ? Styles.primaryColor
                                                  : Styles.white,
                                            ),
                                          },
                                          onValueChanged: (v) {
                                            if (_isSelectedGridView != v) {
                                              if (!_isGridView) {
                                                setState(() {
                                                  _isGridView = true;
                                                });
                                              } else {
                                                setState(() {
                                                  _isGridView = false;
                                                });
                                              }
                                            }
                                            setState(() {
                                              _isSelectedGridView = v;
                                            });
                                          },
                                          decoration: BoxDecoration(
                                            color: Styles.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          thumbDecoration: BoxDecoration(
                                            color: Styles.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: TextField(
                                        autofocus: true,
                                        style: Styles.black18(context),
                                        controller: searchController,
                                        onChanged: (query) {
                                          if (query != "") {
                                            const duration =
                                                Duration(seconds: 1);
                                            _debouncer.debounce(
                                              duration: duration,
                                              onDebounce: () {
                                                _loadProduct(reset: true);
                                              },
                                            );
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: "ค้นหาสินค้า...",
                                          hintStyle: Styles.grey18(context),
                                          prefixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Expanded(
                                child: _isGridView
                                    ? ListView.builder(
                                        key: ValueKey(_isGridView),
                                        controller: _productGridController,
                                        itemCount: (_product.length / 2).ceil(),
                                        itemBuilder: (context, index) {
                                          final firstIndex = index * 2;
                                          final secondIndex = firstIndex + 1;
                                          return Row(
                                            children: [
                                              Expanded(
                                                child:
                                                    OrderMenuListVerticalCard(
                                                  item: _product[firstIndex],
                                                  onDetailsPressed: () async {
                                                    setState(() {
                                                      selectedUnit = '';
                                                      selectedSize = '';
                                                      price = 0.00;
                                                      count = 1;
                                                      total = 0.00;
                                                      // lotStock = '';
                                                      stockQty = 0;
                                                    });

                                                    _showProductSheet(context,
                                                        _product[firstIndex]);
                                                  },
                                                ),
                                              ),
                                              if (secondIndex < _product.length)
                                                Expanded(
                                                  child:
                                                      OrderMenuListVerticalCard(
                                                    item: _product[secondIndex],
                                                    onDetailsPressed: () {
                                                      setState(() {
                                                        selectedUnit = '';
                                                        selectedSize = '';
                                                        price = 0.00;
                                                        count = 1;
                                                        total = 0.00;
                                                        // lotStock = '';
                                                        stockQty = 0;
                                                      });
                                                      _showProductSheet(
                                                          context,
                                                          _product[
                                                              secondIndex]);
                                                    },
                                                  ),
                                                )
                                              else
                                                Expanded(
                                                  child:
                                                      SizedBox(), // Placeholder for spacing if no second card
                                                ),
                                            ],
                                          );
                                        },
                                      )
                                    : ListView.builder(
                                        key: ValueKey(_isGridView),
                                        itemCount: _product.length,
                                        controller: _listController2,
                                        itemBuilder: (context, index) {
                                          return OrderMenuListCard(
                                            product: _product[index],
                                            onTap: () {
                                              print(_product[index]);
                                              setState(() {
                                                selectedUnit = '';
                                                selectedSize = '';
                                                price = 0.00;
                                                count = 1;
                                                total = 0.00;
                                                stockQty = 0;
                                              });
                                              _showProductSheet(
                                                  context, _product[index]);
                                            },
                                          );
                                        },
                                      ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Stack(
                                      alignment: Alignment(1.3, -1.5),
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await _getCart();
                                            _showCartSheet(context, cartList);
                                          },
                                          child: Icon(
                                            Icons.shopping_bag_outlined,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.all(4),
                                            backgroundColor:
                                                Styles.primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        cartList.isNotEmpty
                                            ? Container(
                                                width:
                                                    25, // Set the width of the button
                                                height: 25,
                                                // constraints: BoxConstraints(minHeight: 32, minWidth: 32),
                                                decoration: BoxDecoration(
                                                  // This controls the shadow
                                                  boxShadow: [
                                                    BoxShadow(
                                                      spreadRadius: 1,
                                                      blurRadius: 5,
                                                      color: Colors.black
                                                          .withAlpha(50),
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          180),
                                                  color: Colors
                                                      .red, // This would be color of the Badge
                                                ),
                                                // This is your Badge
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "ยอดรวม ฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(totalCart)} บาท",
                                        style: Styles.black24(context),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      // Ensures text does not overflow the screen
                                      child: ButtonFullWidth(
                                        text: 'สั่งซื้อ',
                                        blackGroundColor: Styles.primaryColor,
                                        textStyle: Styles.white18(context),
                                        onPressed: () {
                                          if (totalCart > 0) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateOrderScreen(
                                                  routeId: widget.routeId,
                                                  storeId: widget
                                                      .storeDetail
                                                      ?.listStore[0]
                                                      .storeInfo
                                                      .storeId,
                                                  storeName: widget
                                                      .storeDetail
                                                      ?.listStore[0]
                                                      .storeInfo
                                                      .name,
                                                  storeAddress: widget
                                                      .storeDetail
                                                      ?.listStore[0]
                                                      .storeInfo
                                                      .address,
                                                ),
                                              ),
                                            );
                                          } else {
                                            toastification.show(
                                              autoCloseDuration:
                                                  const Duration(seconds: 5),
                                              context: context,
                                              primaryColor: Colors.red,
                                              type: ToastificationType.error,
                                              style: ToastificationStyle
                                                  .flatColored,
                                              title: Text(
                                                "กรุณาเลือกรายการสินค้า",
                                                style: Styles.red18(context),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showProductSheet(BuildContext context, Product product) {
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
                          Text('รายละเอียดสินค้า',
                              style: Styles.white24(context)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        child: Container(
                          height: screenHeight * 0.9,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        '${ApiService.image}/images/products/${product.id}.webp',
                                        width: screenWidth / 4,
                                        height: screenWidth / 4,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: screenWidth / 4,
                                            height: screenWidth / 4,
                                            color: Colors.grey,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.hide_image,
                                                    color: Colors.white,
                                                    size: 50),
                                                Text(
                                                  "ไม่มีภาพ",
                                                  style:
                                                      Styles.white18(context),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    product.name,
                                                    style:
                                                        Styles.black24(context),
                                                    softWrap: true,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'กลุ่ม : ${product.group}',
                                                  style:
                                                      Styles.black16(context),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'แบรนด์ : ${product.brand}',
                                                  style:
                                                      Styles.black16(context),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'ขนาด : ${product.size}',
                                                  style:
                                                      Styles.black16(context),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children:
                                              product.listUnit.map((data) {
                                            return Container(
                                              margin: EdgeInsets.all(8),
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  setModalState(() {
                                                    price = data.price;
                                                  });

                                                  setModalState(
                                                    () {
                                                      selectedSize = data.name;
                                                      selectedUnit = data.unit;
                                                      total = price * count;
                                                    },
                                                  );
                                                  setState(() {
                                                    price = data.price;
                                                    selectedSize = data.name;
                                                    selectedUnit = data.unit;
                                                    total = price * count;
                                                  });
                                                  context.loaderOverlay.show();
                                                  // print(selectedUnit);
                                                  // print(selectedSize);
                                                  await _getQty(
                                                      product, setModalState);
                                                  context.loaderOverlay.hide();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    side: BorderSide(
                                                      color: selectedSize ==
                                                              data.name
                                                          ? Styles.primaryColor
                                                          : Colors.grey,
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  data.name,
                                                  style: selectedSize ==
                                                          data.name
                                                      ? Styles.pirmary18(
                                                          context)
                                                      : Styles.grey18(context),
                                                ),
                                              ),
                                            );
                                          }).toList(), // ✅ Ensure .toList() is here
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                            'คงเหลือ ${stockQty} ${selectedSize}',
                                            style: Styles.black18(context)),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ราคา',
                                      style: Styles.black18(context),
                                    ),
                                    Text(
                                      "฿${product.listUnit.any((element) => element.name == selectedSize) ? product.listUnit.where((element) => element.name == selectedSize).first.price : '0.00'} บาท",
                                      style: Styles.black18(context),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'รวม',
                                      style: Styles.black18(context),
                                    ),
                                    Text(
                                      '฿${total.toStringAsFixed(2)} บาท',
                                      style: Styles.black18(context),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey[200],
                                  thickness: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              if (count > 1) {
                                                setModalState(() {
                                                  count--;
                                                  total = price * count;
                                                });
                                                setState(() {
                                                  count = count;
                                                  total = price * count;
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ), // ✅ Makes the button circular
                                              padding: const EdgeInsets.all(8),
                                              backgroundColor:
                                                  Colors.white, // Button color
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              size: 24,
                                              color: Colors.grey,
                                            ), // Example
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              // padding: const EdgeInsets.all(8),
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
                                              setState(() {
                                                count = 1;
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
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              width: 75,
                                              height: 40,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${count.toStringAsFixed(0)}',
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        Styles.black18(context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setModalState(() {
                                                count++;
                                                total = price * count;
                                              });
                                              setState(() {
                                                count = count;
                                                total = price * count;
                                              });

                                              print("total${total}");
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ), // ✅ Makes the button circular
                                              padding: const EdgeInsets.all(8),
                                              backgroundColor:
                                                  Colors.white, // Button color
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 24,
                                              color: Colors.grey,
                                            ), // Example
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ButtonFullWidth(
                                              text: 'ใส่ตะกร้า',
                                              blackGroundColor:
                                                  Styles.primaryColor,
                                              textStyle:
                                                  Styles.white18(context),
                                              onPressed: () async {
                                                print(
                                                    "selectedSize $selectedSize");
                                                if (selectedSize != "") {
                                                  if ((stockQty > 0) &&
                                                      (stockQty >= count)) {
                                                    context.loaderOverlay
                                                        .show();
                                                    await _addCart(product);
                                                    await _getProduct(true);
                                                    await _getCart();
                                                    setModalState(() {
                                                      stockQty -= count;
                                                    });
                                                    context.loaderOverlay
                                                        .hide();
                                                  } else {
                                                    toastification.show(
                                                      autoCloseDuration:
                                                          const Duration(
                                                              seconds: 5),
                                                      context: context,
                                                      primaryColor: Colors.red,
                                                      type: ToastificationType
                                                          .error,
                                                      style: ToastificationStyle
                                                          .flatColored,
                                                      title: Text(
                                                        "ไม่มีของในสต๊อกหรือมีไม่พอ",
                                                        style: Styles.red18(
                                                            context),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  toastification.show(
                                                    autoCloseDuration:
                                                        const Duration(
                                                            seconds: 5),
                                                    context: context,
                                                    primaryColor: Colors.red,
                                                    type: ToastificationType
                                                        .error,
                                                    style: ToastificationStyle
                                                        .flatColored,
                                                    title: Text(
                                                      "กรุณาเลือกขนาด",
                                                      style:
                                                          Styles.red18(context),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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
                              Text('ตะกร้าสินค้าที่เลือก',
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
                                  child: Scrollbar(
                                controller: _cartScrollController,
                                thickness: 10,
                                thumbVisibility: true,
                                trackVisibility: true,
                                radius: Radius.circular(16),
                                child: ListView.builder(
                                  controller: _cartScrollController,
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
                                                '${ApiService.image}/images/products/${cartlist[index].id}.webp',
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
                                                            cartlist[index]
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

                                                                await _reduceCart(
                                                                    cartlist[
                                                                        index],
                                                                    setModalState,
                                                                    "IN");
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
                                                                setModalState(
                                                                    () {
                                                                  cartlist[
                                                                          index]
                                                                      .qty++;
                                                                });
                                                                await _reduceCart(
                                                                    cartlist[
                                                                        index],
                                                                    setModalState,
                                                                    "OUT");
                                                                // await _getCart();
                                                                // await _getProduct();
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
                                                                await _deleteCart(
                                                                    cartlist[
                                                                        index],
                                                                    setModalState);

                                                                setModalState(
                                                                  () {
                                                                    cartList.removeWhere((item) => (item.id ==
                                                                            cartlist[index]
                                                                                .id &&
                                                                        item.unit ==
                                                                            cartlist[index].unit));
                                                                  },
                                                                );
                                                                await _getTotalCart(
                                                                    setModalState);

                                                                if (cartList
                                                                        .length ==
                                                                    0) {
                                                                  Navigator.pop(
                                                                      context);
                                                                }
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
                                                                color:
                                                                    Colors.red,
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
                    Container(
                      color: Styles.primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("ยอดรวม", style: Styles.white24(context)),
                            Text(
                                "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(totalCart)} บาท",
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
                              // Icon(
                              //   Icons.shopping_bag_outlined,
                              //   color: Colors.white,
                              //   size: 30,
                              // ),
                              Text('ใส่จำนวน', style: Styles.white24(context)),
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
                                    if (isInteger(countController.text)) {
                                      setState(() {
                                        double countD =
                                            countController.text.toDouble();
                                        count = countD.toInt();
                                        total = price * count;
                                      });
                                      setModalState(
                                        () {
                                          double countD =
                                              countController.text.toDouble();
                                          count = countD.toInt();
                                          total = price * count;
                                        },
                                      );
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
                                    // if (countController.text.isNotEmpty) {
                                    //   double countD =
                                    //       countController.text.toDouble();
                                    //   if (countD > 0) {

                                    //   } else {
                                    //     toastification.show(
                                    //       autoCloseDuration:
                                    //           const Duration(seconds: 5),
                                    //       context: context,
                                    //       primaryColor: Colors.red,
                                    //       type: ToastificationType.error,
                                    //       style:
                                    //           ToastificationStyle.flatColored,
                                    //       title: Text(
                                    //         "กรุณาใส่จำนวนให้ถูกต้อง",
                                    //         style: Styles.red18(context),
                                    //       ),
                                    //     );
                                    //   }
                                    // } else {
                                    //   Navigator.pop(context);
                                    // }
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
