import 'dart:async';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/filter/BadageFilter.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListCard.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListVerticalCard.dart';
import 'package:_12sale_app/core/components/modal_sheet/ProductSheet.dart';
import 'package:_12sale_app/core/components/search/ProductSearch.dart';
import 'package:_12sale_app/core/components/search/StoreSearch.dart';
import 'package:_12sale_app/core/page/order/CreateOrderScreen.dart';
import 'package:_12sale_app/core/page/order/CreateOrderScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/Cart.dart';
import 'package:_12sale_app/data/models/order/Product.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/sockertService.dart';
import 'package:_12sale_app/main.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dartx/dartx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';

import '../../../data/models/Store.dart';

class OrderOutRouteScreen extends StatefulWidget {
  const OrderOutRouteScreen({super.key});

  @override
  State<OrderOutRouteScreen> createState() => _OrderOutRouteScreenState();
}

class _OrderOutRouteScreenState extends State<OrderOutRouteScreen>
    with RouteAware {
  final Debouncer _debouncer = Debouncer();

  final Throttler _throttler = Throttler();

  List<Product> productList = [];
  List<Product> filteredProductList = [];

  List<CartList> cartList = [];
  bool _loadingProduct = true;

  // Filter Set
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
  String selectedStore = "กรุณาเลือกร้านค้า";
  String selectedStoreId = "";
  String selectedStoreAddress = "";
  String selectedStoreTel = "";
  String selectedStoreShopType = "";
  String selectedSize = "";
  String selectedUnit = "";

  // ---------------------------------------------
  String latestMessage = '';
  double count = 1;
  double price = 0;
  double total = 0.00;
  double totalCart = 0.00;

  int stockQty = 0;
  String lotStock = "";

  List<Store> storeList = [];
  final ScrollController _cartScrollController = ScrollController();
  final ScrollController _productScrollController = ScrollController();
  final ScrollController _productListScrollController = ScrollController();
  final ScrollController _storeScrollController = ScrollController();
  TextEditingController countController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  @override
  void initState() {
    super.initState();
    _getFliter();
    _getProduct();
    _getStore();
  }

  @override
  void didPopNext() {
    _getCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // final socketService = Provider.of<SocketService>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (socketService.latestMessage != latestMessage) {
      //   context.loaderOverlay.show();
      //   _getProduct().then((_) {
      //     Timer(Duration(seconds: 3), () {
      //       context.loaderOverlay.hide();
      //     });
      //   });

      //   toastification.show(
      //     context: context,
      //     title: Text(
      //       socketService.latestMessage,
      //       style: Styles.green18(context),
      //     ),
      //     style: ToastificationStyle.flatColored,
      //     primaryColor: Colors.green,
      //     autoCloseDuration: Duration(seconds: 5),
      //   );
      //   setState(() {
      //     latestMessage = socketService.latestMessage;
      //   });
      // }
    });
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

  Future<void> _getStore() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/store/getStore?area=${User.area}',
        method: 'GET',
      );

      // print(response.data['data']['listAddress']);
      if (response.statusCode == 200) {
        print("getStore");
        final List<dynamic> data = response.data['data'];
        // print(response.data['data'][0]);
        if (mounted) {
          setState(() {
            storeList = data.map((item) => Store.fromJson(item)).toList();
          });
        }
      }
    } catch (e) {
      print("Error _getStore $e");
      if (mounted) {
        setState(() {
          storeList = [];
        });
      }
      print("Error $e");
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
          "storeId": "${selectedStoreId}",
          "id": "${cart.id}",
          "unit": "${cart.unit}"
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          totalCart = response.data['data']['total'].toDouble();
        });
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
    } catch (e) {}
  }

  Future<void> _reduceCart(CartList cart, StateSetter setModalState) async {
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
              "storeId": "${selectedStoreId}",
              "id": "${cart.id}",
              "qty": cart.qty,
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
                "แก้ไขข้อมูลสำเร็จ",
                style: Styles.green18(context),
              ),
            );
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

  Future<void> _getTotalCart(StateSetter setModalState) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/get?type=sale&area=${User.area}&storeId=${selectedStoreId}',
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
      print("Error $e");
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
          "productId": "${product.id}"
        },
      );

      if (response.statusCode == 200) {
        print(response.data['data']);
        setModalState(
          () {
            stockQty = response.data['data']['qty'].toInt();
            lotStock = response.data['data']['lot'];
          },
        );
        setState(() {
          stockQty = response.data['data']['qty'].toInt();
          lotStock = response.data['data']['lot'];
        });
      }
    } catch (e) {
      print("Error in _getQty $e");
    }
  }

  Future<void> _updateStock(
      Product product, StateSetter setModalState, String type) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
          endpoint: 'api/cash/cart/updateStock',
          method: 'POST',
          body: {
            "area": "${User.area}",
            "unit": "${selectedUnit}",
            "productId": "${product.id}",
            "qty": count,
            "type": type
          });

      if (response.statusCode == 200) {
        setModalState(
          () {
            stockQty -= count.toInt();
          },
        );
      }
      print(response.data['data']);
    } catch (e) {
      print("Error in _updateStock $e");
    }
  }

  Future<void> _updateStock2(
      CartList product, StateSetter setModalState, String type) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
          endpoint: 'api/cash/cart/updateStock',
          method: 'POST',
          body: {
            "area": "${User.area}",
            "unit": "${product.unit}",
            "productId": "${product.id}",
            "qty": "${product.qty.toInt()}",
            "type": type
          });

      if (response.statusCode == 200) {
        setModalState(
          () {
            stockQty -= count.toInt();
          },
        );
      }
      print(response.data['data']);
    } catch (e) {
      print("Error in _updateStock $e");
    }
  }

  Future<void> _getCart() async {
    try {
      print("Get Cart is Loading");
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/get?type=sale&area=${User.area}&storeId=${selectedStoreId}',
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
      print("Error _getCart $e");
    }
  }

  Future<void> _addCart(Product product) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/cart/add',
        method: 'POST',
        body: {
          "type": "sale",
          "area": "${User.area}",
          "storeId": "${selectedStoreId}",
          "id": "${product.id}",
          "qty": count,
          "unit": "${selectedUnit}",
          "lot": "${lotStock}"
        },
      );
      // print("Response add Cart: ${response.data['data']['listProduct']}");
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

        final List<dynamic> data = response.data['data'][0]['listProduct'];
        setState(() {
          totalCart = response.data['data'][0]['total'].toDouble();
          cartList = data.map((item) => CartList.fromJson(item)).toList();
        });
      }
    } catch (e) {}
  }

  Future<void> _getProduct() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
        endpoint: 'api/cash/product/get',
        method: 'POST',
        body: {
          "type": "sale",
          "period": "${period}",
          "area": "${User.area}",
          "group": selectedGroups,
          "brand": selectedBrands,
          "size": selectedSizes,
          "flavour": selectedFlavours
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        setState(() {
          productList = data.map((item) => Product.fromJson(item)).toList();
          filteredProductList = List.from(productList);
        });

        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loadingProduct = false;
            });
          }
        });
      }
    } catch (e) {
      print("Error occurred _getProduct: $e");
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
        // final List<dynamic> dataBrand = response.data['data'][0]['brand'];
        // final List<dynamic> dataSize = response.data['data'][0]['size'];
        // final List<dynamic> dataFlavour = response.data['data'][0]['flavour'];
        print("_getFliter: ${response.data['data']}");
        if (mounted) {
          setState(() {
            groupList = List<String>.from(dataGroup);
            // brandList = List<String>.from(dataBrand);
            // sizeList = List<String>.from(dataSize);
            // flavourList = List<String>.from(dataFlavour);
          });
        }
        // Timer(const Duration(milliseconds: 500), () {
        //   if (mounted) {
        //     setState(() {
        //       _loadingAllStore = false;
        //     });
        //   }
        // });
        print("groupList: $groupList");
        // print("listStore: ${data.length}");
      }
    } catch (e) {}
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
        if (mounted) {
          setState(() {
            brandList = List<String>.from(dataBrand);
            sizeList = List<String>.from(dataSize);
            flavourList = List<String>.from(dataFlavour);
          });
        }
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
    } catch (e) {}
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
      // _getProduct();
    } catch (e) {}
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
      // _getProduct();
    } catch (e) {}
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
          return LoadingSkeletonizer(
            loading: _loadingProduct,
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.store,
                                      color: Styles.primaryColor,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                          selectedStoreId != ""
                                              ? selectedStore
                                              : " กรุณาเลือกร้านค้า",
                                          style: Styles.black18(context)),
                                    )
                                  ],
                                ),
                              ),
                              Text("เลือกร้านค้า",
                                  style: Styles.grey18(context))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        side: BorderSide.none, // Remove border
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        selectedStoreId != ""
                                            ? Expanded(
                                                child: Text(
                                                    selectedStoreId != ""
                                                        ? "${selectedStoreId}  ${selectedStoreShopType} ${selectedStoreTel} ${selectedStoreAddress}"
                                                        : " ",
                                                    style: Styles.black18(
                                                        context)),
                                              )
                                            : SizedBox(),
                                        Icon(
                                          Icons.keyboard_arrow_right_sharp,
                                          color: Styles.grey,
                                          size: 30,
                                        ),
                                      ],
                                    ),
                                    onPressed: () {
                                      _showAddressSheet(context);
                                    },
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )),
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
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: TextField(
                                      autofocus: true,
                                      style: Styles.black18(context),
                                      controller: searchController,
                                      onChanged: (query) {
                                        if (query != "") {
                                          setState(() {
                                            filteredProductList = productList
                                                .where((item) =>
                                                    item.name
                                                        .toLowerCase()
                                                        .contains(query
                                                            .toLowerCase()) ||
                                                    item.brand.toLowerCase().contains(
                                                        query.toLowerCase()) ||
                                                    item.group
                                                        .toLowerCase()
                                                        .contains(query
                                                            .toLowerCase()) ||
                                                    item.flavour
                                                        .toLowerCase()
                                                        .contains(query
                                                            .toLowerCase()) ||
                                                    item.id.toLowerCase().contains(
                                                        query.toLowerCase()) ||
                                                    item.size
                                                        .toLowerCase()
                                                        .contains(
                                                            query.toLowerCase()))
                                                .toList();
                                          });
                                        } else {
                                          setState(() {
                                            filteredProductList = productList;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintText: "ค้นหาร้านค้า...",
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
                                Expanded(
                                  flex: 1,
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
                                              onItemSelected: (data, selected) {
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
                                                _getProduct().then((_) =>
                                                    Timer(Duration(seconds: 3),
                                                        () {
                                                      context.loaderOverlay
                                                          .hide();
                                                    }));
                                              },
                                              onSearch: _getProduct,
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
                                                  ? Styles.grey18(context)
                                                  : Styles.pirmary18(context),
                                              overflow: TextOverflow
                                                  .ellipsis, // Truncate if too long
                                              maxLines: 1, // Restrict to 1 line
                                              softWrap: false, // Avoid wrapping
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
                                              title: 'เลือกแบรนด์',
                                              title2: 'แบรนด์',
                                              itemList: brandList,
                                              selectedItems: selectedBrands,
                                              onItemSelected: (data, selected) {
                                                if (selected) {
                                                  selectedBrands.add(data);
                                                } else {
                                                  selectedBrands.remove(data);
                                                }
                                                _getFliterBrand();
                                              },
                                              onClear: () {
                                                selectedBrands.clear();
                                                selectedSizes.clear();
                                                selectedFlavours.clear();
                                                brandList.clear();
                                                sizeList.clear();
                                                flavourList.clear();
                                                context.loaderOverlay.show();
                                                _getProduct().then((_) =>
                                                    Timer(Duration(seconds: 3),
                                                        () {
                                                      context.loaderOverlay
                                                          .hide();
                                                    }));
                                              },
                                              onSearch: _getProduct,
                                            );
                                          },
                                          child: badgeFilter(
                                            isSelected:
                                                selectedBrands.isNotEmpty
                                                    ? true
                                                    : false,
                                            child: Text(
                                              selectedBrands.isEmpty
                                                  ? 'แบรนด์'
                                                  : selectedBrands.join(', '),
                                              style: selectedBrands.isEmpty
                                                  ? Styles.grey18(context)
                                                  : Styles.pirmary18(context),
                                              overflow: TextOverflow
                                                  .ellipsis, // Truncate if too long
                                              maxLines: 1, // Restrict to 1 line
                                              softWrap: false, // Avoid wrapping
                                            ),
                                            width: selectedBrands.isEmpty
                                                ? 120
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
                                              onItemSelected: (data, selected) {
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
                                                _getProduct().then((_) =>
                                                    Timer(Duration(seconds: 3),
                                                        () {
                                                      context.loaderOverlay
                                                          .hide();
                                                    }));
                                              },
                                              onSearch: _getProduct,
                                            );
                                          },
                                          child: badgeFilter(
                                            isSelected: selectedSizes.isNotEmpty
                                                ? true
                                                : false,
                                            child: Text(
                                              selectedSizes.isEmpty
                                                  ? 'ขนาด'
                                                  : selectedSizes.join(', '),
                                              style: selectedSizes.isEmpty
                                                  ? Styles.grey18(context)
                                                  : Styles.pirmary18(context),
                                              overflow: TextOverflow
                                                  .ellipsis, // Truncate if too long
                                              maxLines: 1, // Restrict to 1 line
                                              softWrap: false, // Avoid wrapping
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
                                              onItemSelected: (data, selected) {
                                                if (selected) {
                                                  selectedFlavours.add(data);
                                                } else {
                                                  selectedFlavours.remove(data);
                                                }
                                              },
                                              onClear: () {
                                                selectedFlavours.clear();
                                                flavourList.clear();
                                                context.loaderOverlay.show();
                                                _getProduct().then((_) =>
                                                    Timer(Duration(seconds: 3),
                                                        () {
                                                      context.loaderOverlay
                                                          .hide();
                                                    }));
                                              },
                                              onSearch: _getProduct,
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
                                                  : selectedFlavours.join(', '),
                                              style: selectedFlavours.isEmpty
                                                  ? Styles.grey18(context)
                                                  : Styles.pirmary18(context),
                                              overflow: TextOverflow
                                                  .ellipsis, // Truncate if too long
                                              maxLines: 1, // Restrict to 1 line
                                              softWrap: false, // Avoid wrapping
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
                                            _getProduct().then((_) =>
                                                Timer(Duration(seconds: 3), () {
                                                  context.loaderOverlay.hide();
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
                                        width: 10,
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
                            SizedBox(
                              height: 16,
                            ),
                            _isGridView
                                ? Expanded(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ListView.builder(
                                            // controller:
                                            //     _productScrollController,
                                            itemCount:
                                                (filteredProductList.length / 2)
                                                    .ceil(),
                                            itemBuilder: (context, index) {
                                              final firstIndex = index * 2;
                                              final secondIndex =
                                                  firstIndex + 1;
                                              return Row(
                                                children: [
                                                  Expanded(
                                                    child:
                                                        OrderMenuListVerticalCard(
                                                      item: filteredProductList[
                                                          firstIndex],
                                                      onDetailsPressed:
                                                          () async {
                                                        setState(() {
                                                          selectedUnit = '';
                                                          selectedSize = '';
                                                          price = 0.00;
                                                          count = 1;
                                                          total = 0.00;
                                                          lotStock = '';
                                                          stockQty = 0;
                                                        });

                                                        _showProductSheet(
                                                            context,
                                                            filteredProductList[
                                                                firstIndex]);
                                                      },
                                                    ),
                                                  ),
                                                  if (secondIndex <
                                                      filteredProductList
                                                          .length)
                                                    Expanded(
                                                      child:
                                                          OrderMenuListVerticalCard(
                                                        item:
                                                            filteredProductList[
                                                                secondIndex],
                                                        onDetailsPressed: () {
                                                          setState(() {
                                                            selectedUnit = '';
                                                            selectedSize = '';
                                                            price = 0.00;
                                                            count = 1;
                                                            total = 0.00;
                                                            lotStock = '';
                                                            stockQty = 0;
                                                          });
                                                          _showProductSheet(
                                                              context,
                                                              filteredProductList[
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
                                          ),
                                        )

                                        // Row(
                                        //   children: [
                                        //     Expanded(
                                        //       child: OrderMenuListVerticalCard(
                                        //         onDetailsPressed: () {},
                                        //       ),
                                        //     ),
                                        //     Expanded(
                                        //       child: OrderMenuListVerticalCard(
                                        //         onDetailsPressed: () {},
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  )
                                : Expanded(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount:
                                                filteredProductList.length,
                                            itemBuilder: (context, index) {
                                              return OrderMenuListCard(
                                                product:
                                                    filteredProductList[index],
                                                onTap: () {
                                                  print(filteredProductList[
                                                      index]);
                                                  setState(() {
                                                    selectedUnit = '';
                                                    selectedSize = '';
                                                    price = 0.00;
                                                    count = 1;
                                                    total = 0.00;
                                                    stockQty = 0;
                                                  });
                                                  _showProductSheet(
                                                      context,
                                                      filteredProductList[
                                                          index]);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
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
                                          backgroundColor: Styles.primaryColor,
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
                                                    BorderRadius.circular(180),
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
                                        if (cartList.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CreateOrderScreen(
                                                      routeId: '',
                                                      storeId: selectedStoreId,
                                                      storeName: selectedStore,
                                                      storeAddress:
                                                          selectedStoreAddress),
                                            ),
                                          );
                                        } else {
                                          toastification.show(
                                            autoCloseDuration:
                                                const Duration(seconds: 5),
                                            context: context,
                                            primaryColor: Colors.red,
                                            type: ToastificationType.error,
                                            style:
                                                ToastificationStyle.flatColored,
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
          );
        },
      ),
    );
  }

  void _showProductSheet2(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return ProductSheet(
          product: product,
          onAddToCart: (Product product, String selectedSize,
              String selectedUnit, int count, double total) async {
            // Handle the add-to-cart logic
            print(
                'Added to cart: $selectedSize, $selectedUnit, $count, $total');
          },
        );
      },
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
                                        'https://jobbkk.com/upload/employer/0D/53D/03153D/images/202045.webp',
                                        width: screenWidth / 4,
                                        height: screenWidth / 4,
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
                                            Row(
                                              children: [
                                                Text(
                                                  'รสชาติ : ${product.flavour}',
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
                                                    price = double.parse(
                                                        data.price);
                                                  });

                                                  setModalState(
                                                    () {
                                                      selectedSize = data.name;
                                                      selectedUnit = data.unit;
                                                      total = price * count;
                                                    },
                                                  );
                                                  setState(() {
                                                    price = double.parse(
                                                        data.price);
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
                                                if (stockQty > 0) {
                                                  setModalState(() {
                                                    count--;
                                                    total = price * count;
                                                  });
                                                  setState(() {
                                                    count = count;
                                                    total = price * count;
                                                  });
                                                }
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
                                              padding: EdgeInsets.all(4),
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
                                                if (selectedSize != "" &&
                                                    selectedStoreId != "") {
                                                  if ((stockQty > 0) &&
                                                      (stockQty >= count)) {
                                                    context.loaderOverlay
                                                        .show();
                                                    await _addCart(product);
                                                    await _getCart();
                                                    // await _updateStock(product,
                                                    //     setModalState, "OUT");
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
                                                      "กรุณาเลือกขนาดและร้านค้า",
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
                                                'https://jobbkk.com/upload/employer/0D/53D/03153D/images/202045.webp',
                                                width: screenWidth / 8,
                                                height: screenWidth / 8,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
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
                                                                    setModalState);
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
                                                                await _reduceCart(
                                                                    cartlist[
                                                                        index],
                                                                    setModalState);

                                                                setModalState(
                                                                    () {
                                                                  cartlist[
                                                                          index]
                                                                      .qty++;
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
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                await _deleteCart(
                                                                    cartlist[
                                                                        index],
                                                                    setModalState);
                                                                await _updateStock2(
                                                                    cartlist[
                                                                        index],
                                                                    setModalState,
                                                                    "IN");
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

  void _showAddressSheet(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<Store> filteredStores = List.from(storeList); // Copy of storeList
    double screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  width: screenWidth * 0.95,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                                  Icons.store,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text('เลือกร้านค้า',
                                    style: Styles.white24(context)),
                              ],
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          autofocus: true,
                          style: Styles.black18(context),
                          controller: searchController,
                          onChanged: (query) {
                            setModalState(() {
                              filteredStores = storeList
                                  .where((store) =>
                                      store.name
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      store.address
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      store.province
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      store.tel
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      store.typeName
                                          .toLowerCase()
                                          .contains(query.toLowerCase()))
                                  .toList();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "ค้นหาสินค้า...",
                            hintStyle: Styles.grey18(context),
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),

                      // Store List
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Expanded(
                                child: Scrollbar(
                                  controller: _storeScrollController,
                                  thickness: 10,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  radius: Radius.circular(16),
                                  child: ListView.builder(
                                    controller: _storeScrollController,
                                    itemCount: filteredStores.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      elevation: 0,
                                                      shadowColor:
                                                          Colors.transparent,
                                                      backgroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.zero,
                                                        side: BorderSide.none,
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      setModalState(() {
                                                        selectedStoreId =
                                                            filteredStores[
                                                                    index]
                                                                .storeId;
                                                      });
                                                      setState(() {
                                                        selectedStoreId =
                                                            filteredStores[
                                                                    index]
                                                                .storeId;
                                                        selectedStore =
                                                            filteredStores[
                                                                    index]
                                                                .name;

                                                        selectedStore =
                                                            filteredStores[
                                                                    index]
                                                                .name;
                                                        selectedStoreId =
                                                            filteredStores[
                                                                    index]
                                                                .storeId;

                                                        selectedStoreTel =
                                                            filteredStores[
                                                                    index]
                                                                .tel;
                                                        selectedStoreShopType =
                                                            filteredStores[
                                                                    index]
                                                                .typeName;
                                                        selectedStoreAddress =
                                                            "${filteredStores[index].address} ${filteredStores[index].district} ${filteredStores[index].subDistrict} ${filteredStores[index].province} ${filteredStores[index].postCode}";
                                                      });
                                                      // ฟไ _getCart();
                                                      await _getCart();
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
                                                                  Text(
                                                                    filteredStores[
                                                                            index]
                                                                        .typeName,
                                                                    style: Styles
                                                                        .black18(
                                                                            context),
                                                                  ),
                                                                  filteredStores[index]
                                                                              .name !=
                                                                          ''
                                                                      ? Text(
                                                                          filteredStores[index]
                                                                              .name,
                                                                          style:
                                                                              Styles.black18(context),
                                                                        )
                                                                      : SizedBox(),
                                                                  filteredStores[index]
                                                                              .tel !=
                                                                          ''
                                                                      ? Text(
                                                                          filteredStores[index]
                                                                              .tel,
                                                                          style:
                                                                              Styles.black18(context),
                                                                        )
                                                                      : SizedBox(),
                                                                  filteredStores[index]
                                                                              .address !=
                                                                          ""
                                                                      ? Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                "${filteredStores[index].address} ${filteredStores[index].district} ${filteredStores[index].subDistrict}  ${filteredStores[index].province} ${filteredStores[index].postCode}",
                                                                                style: Styles.black18(context),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : SizedBox(),
                                                                ],
                                                              ),
                                                            ),
                                                            selectedStoreId ==
                                                                    filteredStores[
                                                                            index]
                                                                        .storeId
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
                                                                    color: Colors
                                                                        .grey,
                                                                    size: 25,
                                                                  )
                                                          ],
                                                        ),
                                                        Divider(
                                                          color:
                                                              Colors.grey[200],
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
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showCountSheet(
    BuildContext context,
  ) {
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
                                    setState(() {
                                      count = countController.text.toDouble();
                                      total = price * count;
                                    });
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
