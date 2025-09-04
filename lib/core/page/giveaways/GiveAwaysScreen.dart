import 'dart:async';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListCard.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListVerticalCard.dart';
import 'package:_12sale_app/core/components/filter/BadageGiveAwaysFilter.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/page/giveaways/CreateGiveawayScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/giveaways/GiveType.dart';
import 'package:_12sale_app/data/models/order/Cart.dart';
import 'package:_12sale_app/data/models/order/Product.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/main.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dartx/dartx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

class GiveAwaysScreen extends StatefulWidget {
  const GiveAwaysScreen({super.key});

  @override
  State<GiveAwaysScreen> createState() => _GiveAwaysScreenState();
}

class _GiveAwaysScreenState extends State<GiveAwaysScreen> with RouteAware {
  List<Store> storeList = [];
  List<Product> productList = [];
  List<CartList> cartList = [];
  List<GiveType> giveTypesList = [];

  int count = 1;
  double price = 0;
  double total = 0.00;
  double totalCart = 0.00;

  String isStoreId = "";
  String nameStore = "";
  String addressStore = "";
  String isGiveTypeText = '';
  String isGiveTypeVal = '';

  bool _loadingProduct = true;

  List<String> groupList = [];
  List<String> selectedGroups = [];

  List<String> brandList = [];
  List<String> selectedBrands = [];

  List<String> sizeList = [];
  List<String> selectedSizes = [];

  List<String> flavourList = [];
  List<String> selectedFlavours = [];

  List<Product> filteredProductList = [];

  String selectedSize = "";
  String selectedUnit = "";

  bool _isGridView = false;
  int _isSelectedGridView = 1;

  int stockQty = 0;

  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  final ScrollController _cartScrollController = ScrollController();
  final ScrollController _storeScrollController = ScrollController();
  final ScrollController _giveTypeScrollController = ScrollController();
  TextEditingController countController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  final Debouncer _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    // _getStore();
    // _getFliterSize();
    _getGiveType();
  }

  @override
  void dispose() {
    // Unsubscribe when the widget is disposed
    _cartScrollController.dispose();
    _storeScrollController.dispose();
    _giveTypeScrollController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
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

  Future<void> _getProductFilter() async {
    try {
      context.loaderOverlay.show();
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
          endpoint: 'api/cash/give/getProductFilter',
          method: 'POST',
          body: {
            "area": "${User.area}",
            "giveId": isGiveTypeVal,
            "period": "${period}"
          });
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        print(data);

        setState(() {
          productList = data.map((item) => Product.fromJson(item)).toList();
          filteredProductList = List.from(productList);
        });
        // print("productList $productList");
        // context.loaderOverlay.hide();
      }
    } catch (e) {
      context.loaderOverlay.hide();
      print("Error  _getProductFilter $e");
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
          "type": "give",
          "area": "${User.area}",
          "storeId": "${isStoreId}",
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
    } catch (e) {
      setState(() {
        totalCart = 00.00;
        cartList = [];
      });
    }
  }

  Future<void> _getCart() async {
    try {
      print("Get Cart is Loading");
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/get?type=give&area=${User.area}&storeId=${isStoreId}',
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
      print("Error $e");
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
          "type": "give",
          "area": "${User.area}",
          "storeId": "${isStoreId}",
          "id": "${product.id}",
          "qty": count,
          "unit": "${selectedUnit}"
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
            "เพิ่มลงในรายการสําเร็จ",
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

  Future<void> _getGiveType() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/give/getGiveType',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        print("getStore");
        final List<dynamic> data = response.data['data'];
        if (mounted) {
          setState(() {
            giveTypesList =
                data.map((item) => GiveType.fromJson(item)).toList();
          });
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
      print("Error $e");
    }
  }

  Future<void> _getStore() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/give/getStoreFilter?area=${User.area}&giveId=${isGiveTypeVal}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        print("getStore");
        print("isGiveTypeVal: $isGiveTypeVal");
        final List<dynamic> data = response.data['data'];
        // print(response.data['data'][0]);
        setState(() {
          storeList = data.map((item) => Store.fromJson(item)).toList();
        });
      }
    } catch (e) {
      print("Error _getStore $e");
      if (mounted) {
        setState(() {
          storeList = [];
        });
      }
      print("Error _getStore $e");
    }
  }

  Future<void> _getTotalCart(StateSetter setModalState) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/get?type=give&area=${User.area}&storeId=${isStoreId}',
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

  Future<void> _reduceCart(
      CartList cart, StateSetter setModalState, String stockType) async {
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
              "type": "give",
              "area": "${User.area}",
              "storeId": "${isStoreId}",
              "id": "${cart.id}",
              "qty": cart.qty,
              "unit": "${cart.unit}",
              "stockType": stockType
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

  // Future<void> _getProduct(List<String> groups) async {
  //   try {
  //     ApiService apiService = ApiService();
  //     await apiService.init();

  //     var response = await apiService.request(
  //       endpoint: 'api/cash/product/get',
  //       method: 'POST',
  //       body: {
  //         "type": "sale",
  //         "period": "${period}",
  //         "area": "${User.area}",
  //         "group": groups,
  //         "brand": brandList,
  //         "size": sizeList,
  //         "flavour": flavourList
  //       },
  //     );
  //     print("Response: $response");
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = response.data['data'];
  //       if (mounted) {
  //         setState(() {
  //           productList = data.map((item) => Product.fromJson(item)).toList();
  //           filteredProductList = List.from(productList);
  //         });
  //         context.loaderOverlay.hide();
  //       }
  //       Timer(const Duration(milliseconds: 500), () {
  //         if (mounted) {
  //           setState(() {
  //             _loadingProduct = false;
  //           });
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     print("Error _getProduct: $e");
  //   }
  // }

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

        print("_getFliter: ${response.data['data']}");
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
    // _getProduct();
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

  bool isInteger(String input) {
    return int.tryParse(input) != null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " แจกสินค้า",
          icon: Icons.campaign_rounded,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return LoadingSkeletonizer(
            loading: _loadingProduct,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            elevation: 0, // Disable shadow
                            shadowColor:
                                Colors.transparent, // Ensure no shadow color
                            backgroundColor: Styles.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                  color: Colors.grey[300]!, width: 1),
                            ),
                          ),
                          onPressed: () {
                            _showGiveTypesSheet(context);
                          },
                          child: Text(
                            isGiveTypeText != ""
                                ? isGiveTypeText
                                : "กรุณาเลือกประเภทการแจก",
                            style: Styles.white18(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  BoxShadowCustom(
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
                                          isStoreId != ""
                                              ? "${nameStore} ${isStoreId}"
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        isStoreId != ""
                                            ? Expanded(
                                                child: Text(
                                                    isStoreId != ""
                                                        ? addressStore
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
                                      // _getStore();
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
                              // Expanded(
                              //   flex: 4,
                              //   child: SingleChildScrollView(
                              //     scrollDirection: Axis.horizontal,
                              //     child: Row(
                              //       children: [
                              //         GestureDetector(
                              //           onTap: () {
                              //             BadageGiveAwaysFilter.showFilterSheet(
                              //               context: context,
                              //               title: 'เลือกกลุ่ม',
                              //               title2: 'กลุ่ม',
                              //               itemList: groupList,
                              //               selectedItems: selectedGroups,
                              //               onItemSelected: (data, selected) {
                              //                 if (selected) {
                              //                   selectedGroups.add(data);
                              //                 } else {
                              //                   selectedGroups.remove(data);
                              //                 }
                              //                 _getFliterGroup();
                              //               },
                              //               onClear: () {
                              //                 selectedGroups.clear();
                              //                 selectedBrands.clear();
                              //                 selectedSizes.clear();
                              //                 selectedFlavours.clear();
                              //                 brandList.clear();
                              //                 sizeList.clear();
                              //                 flavourList.clear();
                              //                 context.loaderOverlay.show();
                              //                 _getProduct(groupList).then((_) =>
                              //                     Timer(Duration(seconds: 3),
                              //                         () {
                              //                       context.loaderOverlay
                              //                           .hide();
                              //                     }));
                              //               },
                              //               onSearch: _getProduct,
                              //             );
                              //           },
                              //           child: badgeFilter(
                              //             isSelected: selectedGroups.isNotEmpty
                              //                 ? true
                              //                 : false,
                              //             child: Text(
                              //               selectedGroups.isEmpty
                              //                   ? 'กลุ่ม'
                              //                   : selectedGroups.join(', '),
                              //               style: selectedGroups.isEmpty
                              //                   ? Styles.black18(context)
                              //                   : Styles.pirmary18(context),
                              //               overflow: TextOverflow
                              //                   .ellipsis, // Truncate if too long
                              //               maxLines: 1, // Restrict to 1 line
                              //               softWrap: false, // Avoid wrapping
                              //             ),
                              //             width:
                              //                 selectedGroups.isEmpty ? 85 : 120,
                              //           ),
                              //         ),
                              //         GestureDetector(
                              //           onTap: () {
                              //             BadageGiveAwaysFilter.showFilterSheet(
                              //               context: context,
                              //               title: 'เลือกแบรนด์',
                              //               title2: 'แบรนด์',
                              //               itemList: brandList,
                              //               selectedItems: selectedBrands,
                              //               onItemSelected: (data, selected) {
                              //                 if (selected) {
                              //                   selectedBrands.add(data);
                              //                 } else {
                              //                   selectedBrands.remove(data);
                              //                 }
                              //                 _getFliterBrand();
                              //               },
                              //               onClear: () {
                              //                 selectedBrands.clear();
                              //                 selectedSizes.clear();
                              //                 selectedFlavours.clear();
                              //                 brandList.clear();
                              //                 sizeList.clear();
                              //                 flavourList.clear();
                              //                 context.loaderOverlay.show();
                              //                 _getProduct(groupList).then((_) =>
                              //                     Timer(Duration(seconds: 3),
                              //                         () {
                              //                       context.loaderOverlay
                              //                           .hide();
                              //                     }));
                              //               },
                              //               onSearch: _getProduct,
                              //             );
                              //           },
                              //           child: badgeFilter(
                              //             isSelected: selectedBrands.isNotEmpty
                              //                 ? true
                              //                 : false,
                              //             child: Text(
                              //               selectedBrands.isEmpty
                              //                   ? 'แบรนด์'
                              //                   : selectedBrands.join(', '),
                              //               style: selectedBrands.isEmpty
                              //                   ? Styles.black18(context)
                              //                   : Styles.pirmary18(context),
                              //               overflow: TextOverflow
                              //                   .ellipsis, // Truncate if too long
                              //               maxLines: 1, // Restrict to 1 line
                              //               softWrap: false, // Avoid wrapping
                              //             ),
                              //             width: selectedBrands.isEmpty
                              //                 ? 120
                              //                 : 120,
                              //           ),
                              //         ),
                              //         GestureDetector(
                              //           onTap: () {
                              //             BadageGiveAwaysFilter.showFilterSheet(
                              //               context: context,
                              //               title: 'เลือกขนาด',
                              //               title2: 'ขนาด',
                              //               itemList: sizeList,
                              //               selectedItems: selectedSizes,
                              //               onItemSelected: (data, selected) {
                              //                 if (selected) {
                              //                   selectedSizes.add(data);
                              //                 } else {
                              //                   selectedSizes.remove(data);
                              //                 }
                              //                 _getFliterSize();
                              //               },
                              //               onClear: () {
                              //                 selectedSizes.clear();
                              //                 selectedFlavours.clear();
                              //                 brandList.clear();
                              //                 sizeList.clear();
                              //                 flavourList.clear();
                              //                 context.loaderOverlay.show();
                              //                 _getProduct(groupList).then((_) =>
                              //                     Timer(Duration(seconds: 3),
                              //                         () {
                              //                       context.loaderOverlay
                              //                           .hide();
                              //                     }));
                              //               },
                              //               onSearch: _getProduct,
                              //             );
                              //           },
                              //           child: badgeFilter(
                              //             isSelected: selectedSizes.isNotEmpty
                              //                 ? true
                              //                 : false,
                              //             child: Text(
                              //               selectedSizes.isEmpty
                              //                   ? 'ขนาด'
                              //                   : selectedSizes.join(', '),
                              //               style: selectedSizes.isEmpty
                              //                   ? Styles.black18(context)
                              //                   : Styles.pirmary18(context),
                              //               overflow: TextOverflow
                              //                   .ellipsis, // Truncate if too long
                              //               maxLines: 1, // Restrict to 1 line
                              //               softWrap: false, // Avoid wrapping
                              //             ),
                              //             width:
                              //                 selectedSizes.isEmpty ? 120 : 120,
                              //           ),
                              //         ),
                              //         GestureDetector(
                              //           onTap: () {
                              //             BadageGiveAwaysFilter.showFilterSheet(
                              //               context: context,
                              //               title: 'เลือกรสชาติ',
                              //               title2: 'รสชาติ',
                              //               itemList: flavourList,
                              //               selectedItems: selectedFlavours,
                              //               onItemSelected: (data, selected) {
                              //                 if (selected) {
                              //                   selectedFlavours.add(data);
                              //                 } else {
                              //                   selectedFlavours.remove(data);
                              //                 }
                              //               },
                              //               onClear: () {
                              //                 selectedFlavours.clear();
                              //                 flavourList.clear();
                              //                 context.loaderOverlay.show();
                              //                 _getProduct(groupList).then((_) =>
                              //                     Timer(Duration(seconds: 3),
                              //                         () {
                              //                       context.loaderOverlay
                              //                           .hide();
                              //                     }));
                              //               },
                              //               onSearch: _getProduct,
                              //             );
                              //           },
                              //           child: badgeFilter(
                              //             isSelected:
                              //                 selectedFlavours.isNotEmpty
                              //                     ? true
                              //                     : false,
                              //             child: Text(
                              //               selectedFlavours.isEmpty
                              //                   ? 'รสชาติ'
                              //                   : selectedFlavours.join(', '),
                              //               style: selectedFlavours.isEmpty
                              //                   ? Styles.black18(context)
                              //                   : Styles.pirmary18(context),
                              //               overflow: TextOverflow
                              //                   .ellipsis, // Truncate if too long
                              //               maxLines: 1, // Restrict to 1 line
                              //               softWrap: false, // Avoid wrapping
                              //             ),
                              //             width: selectedFlavours.isEmpty
                              //                 ? 120
                              //                 : 120,
                              //           ),
                              //         ),
                              //         GestureDetector(
                              //           onTap: () {
                              //             _clearFilter();
                              //             context.loaderOverlay.show();
                              //             _getProduct(groupList).then((_) =>
                              //                 Timer(Duration(seconds: 3), () {
                              //                   context.loaderOverlay.hide();
                              //                 }));
                              //           },
                              //           child: badgeFilter(
                              //             openIcon: false,
                              //             child: Text(
                              //               'ล้างตัวเลือก',
                              //               style: Styles.black18(context),
                              //             ),
                              //             width: 110,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              Expanded(
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
                                                  item.brand
                                                      .toLowerCase()
                                                      .contains(query
                                                          .toLowerCase()) ||
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      thumbDecoration: BoxDecoration(
                                        color: Styles.white,
                                        borderRadius: BorderRadius.circular(8),
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
                          productList.isNotEmpty
                              ? SizedBox()
                              : Expanded(
                                  child: Center(
                                  child: Text(
                                    "กรุณาเลือกประเภทการแจกก่อน",
                                    style: Styles.black18(context),
                                  ),
                                )),
                          _isGridView
                              ? Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount:
                                              (filteredProductList.length / 2)
                                                  .ceil(),
                                          itemBuilder: (context, index) {
                                            final firstIndex = index * 2;
                                            final secondIndex = firstIndex + 1;
                                            return Row(
                                              children: [
                                                Expanded(
                                                  child:
                                                      OrderMenuListVerticalCard(
                                                    item: filteredProductList[
                                                        firstIndex],
                                                    onDetailsPressed: () async {
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
                                                              firstIndex]);
                                                    },
                                                  ),
                                                ),
                                                if (secondIndex <
                                                    filteredProductList.length)
                                                  Expanded(
                                                    child:
                                                        OrderMenuListVerticalCard(
                                                      item: filteredProductList[
                                                          secondIndex],
                                                      onDetailsPressed: () {
                                                        setState(() {
                                                          selectedUnit = '';
                                                          selectedSize = '';
                                                          price = 0.00;
                                                          count = 1;
                                                          total = 0.00;
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
                                          itemCount: filteredProductList.length,
                                          itemBuilder: (context, index) {
                                            return OrderMenuListCard(
                                              product:
                                                  filteredProductList[index],
                                              onTap: () {
                                                print(
                                                    filteredProductList[index]);
                                                setState(() {
                                                  selectedUnit = '';
                                                  selectedSize = '';
                                                  price = 0.00;
                                                  count = 1;
                                                  total = 0.00;
                                                });
                                                _showProductSheet(context,
                                                    filteredProductList[index]);
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        Icons.wallet_giftcard_outlined,
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
                                    text: 'แจกสินค้า',
                                    blackGroundColor: Styles.primaryColor,
                                    textStyle: Styles.white18(context),
                                    onPressed: () {
                                      if (cartList.isNotEmpty &&
                                          isGiveTypeVal != "") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CreateGiveawayScreen(
                                              storeId: isStoreId,
                                              storeName: nameStore,
                                              storeAddress: addressStore,
                                              giveawayId: isGiveTypeVal,
                                              shippingId: "test",
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
                                          style:
                                              ToastificationStyle.flatColored,
                                          title: Text(
                                            "กรุณาเลือกประเภทและรายการ",
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
                  ))
                ],
              ),
            ),
          );
        },
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
                                Icons.card_giftcard_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Text('รายการสินค้าที่เลือก',
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
                                                '${ApiService.apiHost}/images/products/${cartlist[index].id}.webp',
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
                                                                  'จำนวน : ${cartlist[index].qty.toStringAsFixed(0)} ${cartlist[index].unitName}',
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
                                                                // await _getProduct(
                                                                //     groupList);
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
                                                                    setModalState,
                                                                    "OUT");

                                                                setModalState(
                                                                    () {
                                                                  cartlist[
                                                                          index]
                                                                      .qty++;
                                                                });
                                                                // await _getProduct(
                                                                //     groupList);
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
                                                                // await _getTotalCart(
                                                                //     setModalState);

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
                                        '${ApiService.apiHost}/images/products/${product.id}.webp',
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
                                                  setModalState(
                                                    () {
                                                      price = data.price;
                                                    },
                                                  );
                                                  print(data.unit);

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
                                              child: Text(
                                                '${count.toStringAsFixed(0)}',
                                                textAlign: TextAlign.center,
                                                style: Styles.black18(context),
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (count <=
                                                  product.listUnit
                                                      .firstWhere((element) =>
                                                          element.name ==
                                                          selectedSize)
                                                      .qtyPro!) {
                                                setModalState(() {
                                                  count++;
                                                  total = price * count;
                                                });
                                                setState(() {
                                                  count = count;
                                                  total = price * count;
                                                });
                                              }

                                              // print("total${total}");
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
                                              text: 'ใส่ลงในรายการ',
                                              blackGroundColor:
                                                  Styles.primaryColor,
                                              textStyle:
                                                  Styles.white18(context),
                                              onPressed: () async {
                                                print(
                                                    "selectedSize $selectedSize");
                                                if (selectedSize != "" &&
                                                    isStoreId != "" &&
                                                    stockQty > 0 &&
                                                    stockQty >= count) {
                                                  await _addCart(product);
                                                  await _getCart();
                                                  // await _getProduct(groupList);
                                                  setModalState(() {
                                                    stockQty -= count;
                                                  });
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
                                  FontAwesomeIcons.arrowsRotate,
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
                            SizedBox(
                              width: 8,
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
                            hintText: "ค้นหาร้านค้า...",
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
                                                        isStoreId =
                                                            filteredStores[
                                                                    index]
                                                                .storeId;
                                                      });
                                                      await _getCart();
                                                      setState(() {
                                                        nameStore =
                                                            filteredStores[
                                                                    index]
                                                                .name;
                                                        addressStore =
                                                            "${filteredStores[index].address} ${filteredStores[index].district} ${filteredStores[index].subDistrict} ${filteredStores[index].province} ${filteredStores[index].postCode}";
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
                                                                  Text(
                                                                    "${filteredStores[index].storeId} ${filteredStores[index].name}",
                                                                    style: Styles
                                                                        .black18(
                                                                            context),
                                                                  ),
                                                                  filteredStores[index]
                                                                              .tel !=
                                                                          ""
                                                                      ? Text(
                                                                          filteredStores[index]
                                                                              .tel,
                                                                          style:
                                                                              Styles.black18(context),
                                                                        )
                                                                      : SizedBox(),
                                                                  filteredStores[index]
                                                                              .taxId !=
                                                                          ""
                                                                      ? Text(
                                                                          filteredStores[index]
                                                                              .taxId,
                                                                          style:
                                                                              Styles.black18(context),
                                                                        )
                                                                      : SizedBox(),
                                                                  filteredStores[index]
                                                                              .typeName !=
                                                                          ""
                                                                      ? Text(
                                                                          filteredStores[index]
                                                                              .typeName,
                                                                          style:
                                                                              Styles.black18(context),
                                                                        )
                                                                      : SizedBox(),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          "${filteredStores[index].address} ${filteredStores[index].district} ${filteredStores[index].subDistrict}  ${filteredStores[index].province} ${filteredStores[index].postCode}",
                                                                          style:
                                                                              Styles.black18(context),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            isStoreId ==
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

  void _showGiveTypesSheet(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<GiveType> filter = List.from(giveTypesList); // Copy of storeList

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
                                  FontAwesomeIcons.gift,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text('เลือกประเภทการแจกสินค้า',
                                    style: Styles.white24(context)),
                              ],
                            ),
                            SizedBox(
                              width: 8,
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
                              filter = giveTypesList
                                  .where((item) => item.name
                                      .toLowerCase()
                                      .contains(query.toLowerCase()))
                                  .toList();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "ค้นหาประเภท...",
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
                                  controller: _giveTypeScrollController,
                                  thickness: 10,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  radius: Radius.circular(16),
                                  child: ListView.builder(
                                    controller: _giveTypeScrollController,
                                    itemCount: filter.length,
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
                                                        isGiveTypeVal =
                                                            filter[index]
                                                                .giveId;
                                                      });
                                                      // await _getCart();
                                                      await _getProductFilter();
                                                      setState(() {
                                                        isGiveTypeText =
                                                            filter[index].name;
                                                        isGiveTypeVal =
                                                            "${filter[index].giveId}";
                                                      });
                                                      context.loaderOverlay
                                                          .show();
                                                      await _getStore();
                                                      // await _getProductFilter();
                                                      print(
                                                          "groupList: $groupList");
                                                      // await _getProduct(
                                                      //     groupList);
                                                      context.loaderOverlay
                                                          .hide();
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
                                                                    filter[index]
                                                                        .name,
                                                                    style: Styles
                                                                        .black18(
                                                                            context),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            isGiveTypeVal ==
                                                                    filter[index]
                                                                        .giveId
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

  // Widget badgeFilter(Widget child, double width,
  //     {bool openIcon = true, bool isSelected = false}) {
  //   return GestureDetector(
  //     // onTap: () => onTap,
  //     child: Container(
  //       margin: const EdgeInsets.all(8.0),
  //       width: width,
  //       height: 50,
  //       decoration: BoxDecoration(
  //         // color: Styles.primaryColor,
  //         border: Border.all(
  //           color: isSelected ? Styles.primaryColor : Colors.grey,
  //           width: 1,
  //         ),
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               Expanded(
  //                 child: child,
  //               ),
  //               (openIcon)
  //                   ? Row(
  //                       children: [
  //                         const SizedBox(width: 8),
  //                         Icon(
  //                           Icons.arrow_drop_down_rounded,
  //                           color:
  //                               isSelected ? Styles.primaryColor : Colors.grey,
  //                         )
  //                       ],
  //                     )
  //                   : const SizedBox(),
  //             ],
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showFilterGroupSheet(BuildContext context) {
  //   double sreenWidth = MediaQuery.of(context).size.width;
  //   double sreenHeight = MediaQuery.of(context).size.height;
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // Allow full height and scrolling
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setModalState) {
  //         return DraggableScrollableSheet(
  //           expand: false, // Allows dragging but does not expand fully
  //           initialChildSize: 0.6, // 60% of screen height
  //           minChildSize: 0.4,
  //           maxChildSize: 0.6,
  //           builder: (context, scrollController) {
  //             return Container(
  //               width: sreenWidth * 0.95,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(16),
  //                   topRight: Radius.circular(16),
  //                 ),
  //               ),
  //               child: Column(
  //                 // mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Container(
  //                     decoration: const BoxDecoration(
  //                       color: Styles.primaryColor,
  //                       borderRadius: BorderRadius.only(
  //                         topLeft: Radius.circular(16),
  //                         topRight: Radius.circular(16),
  //                       ),
  //                     ),
  //                     alignment: Alignment.center,
  //                     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         const SizedBox(width: 16),
  //                         Text('เลือกกลุ่ม', style: Styles.white24(context)),
  //                         IconButton(
  //                           icon: const Icon(Icons.close, color: Colors.white),
  //                           onPressed: () => Navigator.of(context).pop(),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Expanded(
  //                     flex: 4,
  //                     child: Padding(
  //                       padding: const EdgeInsets.symmetric(
  //                           vertical: 8.0, horizontal: 8.0),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const SizedBox(height: 16),
  //                           Row(
  //                             children: [
  //                               const SizedBox(width: 16),
  //                               Text('กลุ่ม', style: Styles.black24(context)),
  //                             ],
  //                           ),
  //                           Divider(
  //                             color: Colors.grey[200],
  //                             thickness: 1,
  //                             indent: 16,
  //                             endIndent: 16,
  //                           ),
  //                           Wrap(
  //                             spacing: 8.0,
  //                             runSpacing: 8.0,
  //                             children: groupList.map((data) {
  //                               bool isSelected = selectedGroups.contains(data);
  //                               return ChoiceChip(
  //                                 showCheckmark: false,
  //                                 label: Text(
  //                                   data,
  //                                   style: isSelected
  //                                       ? Styles.pirmary18(context)
  //                                       : Styles.grey18(context),
  //                                 ),
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(16.0),
  //                                 ),
  //                                 selected: selectedGroups.contains(data),
  //                                 side: BorderSide(
  //                                   color: isSelected
  //                                       ? Styles.primaryColor
  //                                       : Colors.grey, // Change border color
  //                                   width: 1.5,
  //                                 ),
  //                                 backgroundColor: Colors.white,
  //                                 selectedColor: Colors.white,
  //                                 onSelected: (selected) {
  //                                   setModalState(() {
  //                                     if (selected) {
  //                                       selectedGroups.add(data);
  //                                     } else {
  //                                       selectedGroups.remove(data);
  //                                     }
  //                                   });
  //                                   setState(() {
  //                                     if (selected) {
  //                                       selectedGroups = selectedGroups;
  //                                     } else {
  //                                       selectedGroups = selectedGroups;
  //                                     }
  //                                   });
  //                                   // _getFliterGroup();
  //                                   _getProductFilter();
  //                                 },
  //                               );
  //                             }).toList(),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: ButtonFullWidth(
  //                               onPressed: () {
  //                                 setModalState(() {
  //                                   selectedBrands = [];
  //                                   selectedGroups = [];
  //                                   selectedSizes = [];
  //                                   selectedFlavours = [];
  //                                   brandList = [];
  //                                   sizeList = [];
  //                                   flavourList = [];
  //                                 });
  //                                 setState(() {
  //                                   selectedBrands = [];
  //                                   selectedGroups = [];
  //                                   selectedSizes = [];
  //                                   selectedFlavours = [];
  //                                   brandList = [];
  //                                   sizeList = [];
  //                                   flavourList = [];
  //                                 });
  //                                 context.loaderOverlay.show();
  //                                 _getProduct(groupList).then((_) {
  //                                   context.loaderOverlay.hide();
  //                                   Navigator.pop(context);
  //                                 });
  //                               },
  //                               text: 'ล้างข้อมูล',
  //                               blackGroundColor: Styles.secondaryColor,
  //                               textStyle: Styles.white18(context),
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             width: 10,
  //                           ),
  //                           Expanded(
  //                             child: ButtonFullWidth(
  //                               onPressed: () async {
  //                                 await _getProduct(groupList);
  //                                 Navigator.pop(context);
  //                               },
  //                               text: 'ค้นหา',
  //                               blackGroundColor: Styles.primaryColor,
  //                               textStyle: Styles.white18(context),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         );
  //       });
  //     },
  //   );
  // }

  // void _showFilterBrandSheet(BuildContext context) {
  //   double sreenWidth = MediaQuery.of(context).size.width;
  //   double sreenHeight = MediaQuery.of(context).size.height;
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // Allow full height and scrolling
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setModalState) {
  //         return DraggableScrollableSheet(
  //           expand: false, // Allows dragging but does not expand fully
  //           initialChildSize: 0.6, // 60% of screen height
  //           minChildSize: 0.4,
  //           maxChildSize: 0.6,
  //           builder: (context, scrollController) {
  //             return Container(
  //               width: sreenWidth * 0.95,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(16),
  //                   topRight: Radius.circular(16),
  //                 ),
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Container(
  //                     decoration: const BoxDecoration(
  //                       color: Styles.primaryColor,
  //                       borderRadius: BorderRadius.only(
  //                         topLeft: Radius.circular(16),
  //                         topRight: Radius.circular(16),
  //                       ),
  //                     ),
  //                     alignment: Alignment.center,
  //                     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         const SizedBox(width: 16),
  //                         Text('เลือกแบรนด์', style: Styles.white24(context)),
  //                         IconButton(
  //                           icon: const Icon(Icons.close, color: Colors.white),
  //                           onPressed: () => Navigator.of(context).pop(),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Expanded(
  //                     flex: 4,
  //                     child: Padding(
  //                       padding: const EdgeInsets.symmetric(
  //                           vertical: 8.0, horizontal: 8.0),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const SizedBox(height: 16),
  //                           Row(
  //                             children: [
  //                               const SizedBox(width: 16),
  //                               Text('แบรนด์', style: Styles.black24(context)),
  //                             ],
  //                           ),
  //                           Divider(
  //                             color: Colors.grey[200],
  //                             thickness: 1,
  //                             indent: 16,
  //                             endIndent: 16,
  //                           ),
  //                           if (selectedGroups.isEmpty)
  //                             Center(
  //                               child: Text(
  //                                 "กรุณาเลือกกลุ่มก่อน",
  //                                 style: Styles.grey18(context),
  //                               ),
  //                             ),
  //                           Wrap(
  //                             spacing: 8.0,
  //                             runSpacing: 8.0,
  //                             children: brandList.map((data) {
  //                               bool isSelected = selectedBrands.contains(data);
  //                               return ChoiceChip(
  //                                 showCheckmark: false,
  //                                 label: Text(
  //                                   data,
  //                                   style: isSelected
  //                                       ? Styles.pirmary18(context)
  //                                       : Styles.grey18(context),
  //                                 ),
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(16.0),
  //                                 ),
  //                                 selected: selectedBrands.contains(data),
  //                                 side: BorderSide(
  //                                   color: isSelected
  //                                       ? Styles.primaryColor
  //                                       : Colors.grey, // Change border color
  //                                   width: 1.5,
  //                                 ),
  //                                 backgroundColor: Colors.white,
  //                                 selectedColor: Colors.white,
  //                                 onSelected: (selected) {
  //                                   setModalState(() {
  //                                     if (selected) {
  //                                       selectedBrands.add(data);
  //                                     } else {
  //                                       selectedBrands.remove(data);
  //                                     }
  //                                   });
  //                                   setState(() {
  //                                     if (selected) {
  //                                       selectedBrands = selectedBrands;
  //                                     } else {
  //                                       selectedBrands = selectedBrands;
  //                                     }
  //                                   });
  //                                   // _getFliterBrand();
  //                                   print("selectedBrands: ${selectedBrands}");
  //                                 },
  //                               );
  //                             }).toList(),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: ButtonFullWidth(
  //                               onPressed: () {
  //                                 setModalState(() {
  //                                   selectedBrands = [];
  //                                   selectedGroups = [];
  //                                   selectedSizes = [];
  //                                   selectedFlavours = [];
  //                                   brandList = [];
  //                                   sizeList = [];
  //                                   flavourList = [];
  //                                 });
  //                                 setState(() {
  //                                   selectedBrands = [];
  //                                   selectedGroups = [];
  //                                   selectedSizes = [];
  //                                   selectedFlavours = [];
  //                                   brandList = [];
  //                                   sizeList = [];
  //                                   flavourList = [];
  //                                 });
  //                                 context.loaderOverlay.show();
  //                                 _getProduct(groupList).then((_) {
  //                                   context.loaderOverlay.hide();
  //                                   Navigator.pop(context);
  //                                 });
  //                               },
  //                               text: 'ล้างข้อมูล',
  //                               blackGroundColor: Styles.secondaryColor,
  //                               textStyle: Styles.white18(context),
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             width: 10,
  //                           ),
  //                           Expanded(
  //                             child: ButtonFullWidth(
  //                               onPressed: () async {
  //                                 await _getProduct(groupList);
  //                                 Navigator.pop(context);
  //                               },
  //                               text: 'ค้นหา',
  //                               blackGroundColor: Styles.primaryColor,
  //                               textStyle: Styles.white18(context),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             );
  //           },
  //         );
  //       });
  //     },
  //   );
  // }

  // void _showFilterSizeSheet(BuildContext context) {
  //   double sreenWidth = MediaQuery.of(context).size.width;
  //   double sreenHeight = MediaQuery.of(context).size.height;
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // Allow full height and scrolling
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setModalState) {
  //         return DraggableScrollableSheet(
  //           expand: false, // Allows dragging but does not expand fully
  //           initialChildSize: 0.6, // 60% of screen height
  //           minChildSize: 0.4,
  //           maxChildSize: 0.6,
  //           builder: (context, scrollController) {
  //             return Container(
  //               width: sreenWidth * 0.95,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(16),
  //                   topRight: Radius.circular(16),
  //                 ),
  //               ),
  //               child: Column(
  //                 // mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Container(
  //                     decoration: const BoxDecoration(
  //                       color: Styles.primaryColor,
  //                       borderRadius: BorderRadius.only(
  //                         topLeft: Radius.circular(16),
  //                         topRight: Radius.circular(16),
  //                       ),
  //                     ),
  //                     alignment: Alignment.center,
  //                     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         const SizedBox(width: 16),
  //                         Text('เลือกขนาด', style: Styles.white24(context)),
  //                         IconButton(
  //                           icon: const Icon(Icons.close, color: Colors.white),
  //                           onPressed: () => Navigator.of(context).pop(),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Expanded(
  //                     flex: 4,
  //                     child: Padding(
  //                       padding: const EdgeInsets.symmetric(
  //                           vertical: 8.0, horizontal: 8.0),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const SizedBox(height: 16),
  //                           Row(
  //                             children: [
  //                               const SizedBox(width: 16),
  //                               Text('ขนาด', style: Styles.black24(context)),
  //                             ],
  //                           ),
  //                           Divider(
  //                             color: Colors.grey[200],
  //                             thickness: 1,
  //                             indent: 16,
  //                             endIndent: 16,
  //                           ),
  //                           if (selectedGroups.isEmpty)
  //                             Center(
  //                               child: Text(
  //                                 "กรุณาเลือกกลุ่มก่อน",
  //                                 style: Styles.grey18(context),
  //                               ),
  //                             ),
  //                           Wrap(
  //                             spacing: 8.0,
  //                             runSpacing: 8.0,
  //                             children: sizeList.map((data) {
  //                               bool isSelected = selectedSizes.contains(data);
  //                               return ChoiceChip(
  //                                 showCheckmark: false,
  //                                 label: Text(
  //                                   data,
  //                                   style: isSelected
  //                                       ? Styles.pirmary18(context)
  //                                       : Styles.grey18(context),
  //                                 ),
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(16.0),
  //                                 ),
  //                                 selected: selectedSizes.contains(data),
  //                                 side: BorderSide(
  //                                   color: isSelected
  //                                       ? Styles.primaryColor
  //                                       : Colors.grey, // Change border color
  //                                   width: 1.5,
  //                                 ),
  //                                 backgroundColor: Colors.white,
  //                                 selectedColor: Colors.white,
  //                                 onSelected: (selected) {
  //                                   setModalState(() {
  //                                     if (selected) {
  //                                       selectedSizes.add(data);
  //                                     } else {
  //                                       selectedSizes.remove(data);
  //                                     }
  //                                   });
  //                                   setState(() {
  //                                     if (selected) {
  //                                       selectedSizes = selectedSizes;
  //                                     } else {
  //                                       selectedSizes = selectedSizes;
  //                                     }
  //                                   });
  //                                   _getProductFilter();
  //                                   // _getFliterSize();
  //                                 },
  //                               );
  //                             }).toList(),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                       child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           child: ButtonFullWidth(
  //                             onPressed: () {
  //                               setModalState(() {
  //                                 selectedBrands = [];
  //                                 selectedGroups = [];
  //                                 selectedSizes = [];
  //                                 selectedFlavours = [];
  //                                 brandList = [];
  //                                 sizeList = [];
  //                                 flavourList = [];
  //                               });
  //                               setState(() {
  //                                 selectedBrands = [];
  //                                 selectedGroups = [];
  //                                 selectedSizes = [];
  //                                 selectedFlavours = [];
  //                                 brandList = [];
  //                                 sizeList = [];
  //                                 flavourList = [];
  //                               });
  //                               context.loaderOverlay.show();
  //                               _getProduct(groupList).then((_) {
  //                                 context.loaderOverlay.hide();
  //                                 Navigator.pop(context);
  //                               });
  //                             },
  //                             text: 'ล้างข้อมูล',
  //                             blackGroundColor: Styles.secondaryColor,
  //                             textStyle: Styles.white18(context),
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           width: 10,
  //                         ),
  //                         Expanded(
  //                           child: ButtonFullWidth(
  //                             onPressed: () async {
  //                               await _getProduct(groupList);
  //                               Navigator.pop(context);
  //                             },
  //                             text: 'ค้นหา',
  //                             blackGroundColor: Styles.primaryColor,
  //                             textStyle: Styles.white18(context),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   )),
  //                 ],
  //               ),
  //             );
  //           },
  //         );
  //       });
  //     },
  //   );
  // }

  // void _showFilterFlavourSheet(BuildContext context) {
  //   double sreenWidth = MediaQuery.of(context).size.width;
  //   double sreenHeight = MediaQuery.of(context).size.height;
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // Allow full height and scrolling
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setModalState) {
  //         return DraggableScrollableSheet(
  //           expand: false, // Allows dragging but does not expand fully
  //           initialChildSize: 0.6, // 60% of screen height
  //           minChildSize: 0.4,
  //           maxChildSize: 0.6,
  //           builder: (context, scrollController) {
  //             return Container(
  //               width: sreenWidth * 0.95,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(16),
  //                   topRight: Radius.circular(16),
  //                 ),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Container(
  //                     decoration: const BoxDecoration(
  //                       color: Styles.primaryColor,
  //                       borderRadius: BorderRadius.only(
  //                         topLeft: Radius.circular(16),
  //                         topRight: Radius.circular(16),
  //                       ),
  //                     ),
  //                     alignment: Alignment.center,
  //                     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         const SizedBox(width: 16),
  //                         Text('เลือกรสชาติ', style: Styles.white24(context)),
  //                         IconButton(
  //                           icon: const Icon(Icons.close, color: Colors.white),
  //                           onPressed: () => Navigator.of(context).pop(),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Expanded(
  //                     flex: 4,
  //                     child: Padding(
  //                       padding: const EdgeInsets.symmetric(
  //                           vertical: 8.0, horizontal: 8.0),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const SizedBox(height: 16),
  //                           Row(
  //                             children: [
  //                               const SizedBox(width: 16),
  //                               Text('รสชาติ', style: Styles.black24(context)),
  //                             ],
  //                           ),
  //                           Divider(
  //                             color: Colors.grey[200],
  //                             thickness: 1,
  //                             indent: 16,
  //                             endIndent: 16,
  //                           ),
  //                           if (selectedGroups.isEmpty)
  //                             Center(
  //                               child: Text(
  //                                 "กรุณาเลือกกลุ่มก่อน",
  //                                 style: Styles.grey18(context),
  //                               ),
  //                             ),
  //                           Wrap(
  //                             spacing: 8.0,
  //                             runSpacing: 8.0,
  //                             children: flavourList.map((data) {
  //                               bool isSelected =
  //                                   selectedFlavours.contains(data);
  //                               return ChoiceChip(
  //                                 showCheckmark: false,
  //                                 label: Text(
  //                                   data,
  //                                   style: isSelected
  //                                       ? Styles.pirmary18(context)
  //                                       : Styles.grey18(context),
  //                                 ),
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(16.0),
  //                                 ),
  //                                 selected: selectedFlavours.contains(data),
  //                                 side: BorderSide(
  //                                   color: isSelected
  //                                       ? Styles.primaryColor
  //                                       : Colors.grey, // Change border color
  //                                   width: 1.5,
  //                                 ),
  //                                 backgroundColor: Colors.white,
  //                                 selectedColor: Colors.white,
  //                                 onSelected: (selected) {
  //                                   setModalState(() {
  //                                     if (selected) {
  //                                       selectedFlavours.add(data);
  //                                     } else {
  //                                       selectedFlavours.remove(data);
  //                                     }
  //                                   });
  //                                   setState(() {
  //                                     if (selected) {
  //                                       selectedFlavours = selectedFlavours;
  //                                     } else {
  //                                       selectedFlavours = selectedFlavours;
  //                                     }
  //                                   });
  //                                 },
  //                               );
  //                             }).toList(),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                       child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           child: ButtonFullWidth(
  //                             onPressed: () {
  //                               setModalState(() {
  //                                 selectedBrands = [];
  //                                 selectedGroups = [];
  //                                 selectedSizes = [];
  //                                 selectedFlavours = [];
  //                                 brandList = [];
  //                                 sizeList = [];
  //                                 flavourList = [];
  //                               });
  //                               setState(() {
  //                                 selectedBrands = [];
  //                                 selectedGroups = [];
  //                                 selectedSizes = [];
  //                                 selectedFlavours = [];
  //                                 brandList = [];
  //                                 sizeList = [];
  //                                 flavourList = [];
  //                               });
  //                               context.loaderOverlay.show();
  //                               _getProduct(groupList).then((_) {
  //                                 context.loaderOverlay.hide();
  //                                 Navigator.pop(context);
  //                               });
  //                             },
  //                             text: 'ล้างข้อมูล',
  //                             blackGroundColor: Styles.secondaryColor,
  //                             textStyle: Styles.white18(context),
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           width: 10,
  //                         ),
  //                         Expanded(
  //                           child: ButtonFullWidth(
  //                             onPressed: () async {
  //                               await _getProduct(groupList);
  //                               Navigator.pop(context);
  //                             },
  //                             text: 'ค้นหา',
  //                             blackGroundColor: Styles.primaryColor,
  //                             textStyle: Styles.white18(context),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ))
  //                 ],
  //               ),
  //             );
  //           },
  //         );
  //       });
  //     },
  //   );
  // }
}
