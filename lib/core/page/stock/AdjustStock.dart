import 'dart:async';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListCard.dart';
// import 'pack2sale_app/core/components/card/order/OrderMenuListCard.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListVerticalCard.dart';
import 'package:_12sale_app/core/components/filter/BadageFilter.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/order/CreateOrderScreen.dart';
import 'package:_12sale_app/core/page/withdraw/WithdrawDetailScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/Cart.dart';
import 'package:_12sale_app/data/models/order/Product.dart';
import 'package:_12sale_app/data/models/stock/StockAjustCart.dart';
import 'package:_12sale_app/data/models/withdraw/Shipping.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dartx/dartx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toastification/toastification.dart';

class AdjustStock extends StatefulWidget {
  final String orderId;
  const AdjustStock({
    super.key,
    required this.orderId,
  });

  @override
  State<AdjustStock> createState() => _AdjustStockState();
}

class _AdjustStockState extends State<AdjustStock> {
  final Debouncer _debouncer = Debouncer();
  List<StockAjustCart> cartList = [];
  List<Product> productList = [];
  List<Product> filteredProductList = [];

  bool _loadingProduct = true;

  List<String> groupList = [];
  List<String> selectedGroups = [];

  List<String> brandList = [];
  List<String> selectedBrands = [];

  List<String> sizeList = [];
  List<String> selectedSizes = [];

  List<String> flavourList = [];
  List<String> selectedFlavours = [];

  String selectedSize = "";
  String selectedUnit = "";
  String selectType = "reduce";
  bool _isGridView = false;
  int _isSelectedGridView = 1;
  int count = 1;
  double price = 0;
  double total = 0.00;
  double totalCart = 0.00;
  int isSelect = 1;

  int stockQty = 0;

  TextEditingController countController = TextEditingController();

  TextEditingController searchController = TextEditingController();

  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  String isShippingId = '';
  List<ShippingData> shippingList = [];
  String casue = '';

  List<String> causeAdd = [];

  List<String> causeReduce = [];

  void initState() {
    super.initState();
    _getFliter();
    _getProduct();
    _getCart();
    _getOption('add');
  }

  Future<void> _getOption(type) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/manage/option/get?module=ajustStock&type=${type}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        if (type == 'add') {
          var list = response.data['data']
              .map<String>((item) => item['name'] as String)
              .toList();

          setState(() {
            causeAdd = list;
          });
        } else {
          var list = response.data['data']
              .map<String>((item) => item['name'] as String)
              .toList();

          setState(() {
            causeReduce = list;
          });
        }
      }

      print(causeAdd);
    } catch (e) {
      print("Error _getOption: $e");
    }
  }

  Future<void> _checkout() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/stock/checkout',
        method: 'POST',
        body: {
          "type": "adjuststock",
          "withdrawId": '${widget.orderId}',
          "area": User.area,
          "period": period,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          cartList = [];
        });
        _getCart();
      }
    } catch (e) {
      print("Error _checkout: $e");
    }
  }

  Future<void> _getCart() async {
    try {
      print("Get Cart is Loading");
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/get?type=adjuststock&area=${User.area}&withdrawId=${widget.orderId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'][0]['listProduct'];
        print("listProduct ${response.data['data']}");
        setState(() {
          cartList = data.map((item) => StockAjustCart.fromJson(item)).toList();
        });
      }
    } catch (e) {
      setState(() {
        cartList = [];
      });

      print("Error _getCart: $e");
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

  Future<void> _addCart(Product product, String type) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
        endpoint: 'api/cash/cart/add',
        method: 'POST',
        body: {
          // sale, withdraw, refund, give, adjuststock
          "type": "adjuststock",
          "period": period,
          "area": User.area,
          "id": product.id,
          "withdrawId": widget.orderId,
          "qty": count,
          "unit": selectedUnit,
          "action": "OUT", // add,reduce for adjuststock
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
            "เพิ่มลงในรายการสำเร็จ",
            style: Styles.green18(context),
          ),
        );
      }
    } catch (e) {
      print("Error _addCart: $e");
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

  Future<void> _getProduct() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
        endpoint: 'api/cash/product/get',
        method: 'POST',
        body: {
          "type": "sale",
          "orderId": "${widget.orderId}",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child:
            AppbarCustom(title: " แจ้งได้รับของไม่ครบ", icon: Icons.warehouse),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    "จากใบเบิก ${widget.orderId}",
                    style: Styles.headerBlack24(context),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        elevation: 0, // Disable shadow
                        shadowColor:
                            Colors.transparent, // Ensure no shadow color
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // No rounded corners
                          side: BorderSide.none, // Remove border
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.pending,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                  Text(
                                    casue != "" ? casue : " เลือกเหตุผล",
                                    style: Styles.grey18(context),
                                  )
                                ],
                              ),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.black,
                                size: 20,
                              )
                            ],
                          ),
                        ],
                      ),
                      onPressed: () {
                        _showCauseSheet(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: BoxShadowCustom(
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
                                            Timer(Duration(seconds: 1), () {
                                              context.loaderOverlay.hide();
                                            }));
                                      },
                                      onSearch: _getProduct,
                                    );
                                  },
                                  child: badgeFilter(
                                    isSelected: selectedGroups.isNotEmpty
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
                                      maxLines: 1, // Restrict to 1 line
                                      softWrap: false, // Avoid wrapping
                                    ),
                                    width: selectedGroups.isEmpty ? 85 : 120,
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
                                            context.loaderOverlay.hide());
                                      },
                                      onSearch: _getProduct,
                                    );
                                  },
                                  child: badgeFilter(
                                    isSelected: selectedBrands.isNotEmpty
                                        ? true
                                        : false,
                                    child: Text(
                                      selectedBrands.isEmpty
                                          ? 'แบรนด์'
                                          : selectedBrands.join(', '),
                                      style: selectedBrands.isEmpty
                                          ? Styles.black18(context)
                                          : Styles.pirmary18(context),
                                      overflow: TextOverflow
                                          .ellipsis, // Truncate if too long
                                      maxLines: 1, // Restrict to 1 line
                                      softWrap: false, // Avoid wrapping
                                    ),
                                    width: selectedBrands.isEmpty ? 120 : 120,
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
                                            context.loaderOverlay.hide());
                                      },
                                      onSearch: _getProduct,
                                    );
                                  },
                                  child: badgeFilter(
                                    isSelected:
                                        selectedSizes.isNotEmpty ? true : false,
                                    child: Text(
                                      selectedSizes.isEmpty
                                          ? 'ขนาด'
                                          : selectedSizes.join(', '),
                                      style: selectedSizes.isEmpty
                                          ? Styles.black18(context)
                                          : Styles.pirmary18(context),
                                      overflow: TextOverflow
                                          .ellipsis, // Truncate if too long
                                      maxLines: 1, // Restrict to 1 line
                                      softWrap: false, // Avoid wrapping
                                    ),
                                    width: selectedSizes.isEmpty ? 120 : 120,
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
                                            Timer(Duration(seconds: 1), () {
                                              context.loaderOverlay.hide();
                                            }));
                                      },
                                      onSearch: _getProduct,
                                    );
                                  },
                                  child: badgeFilter(
                                    isSelected: selectedFlavours.isNotEmpty
                                        ? true
                                        : false,
                                    child: Text(
                                      selectedFlavours.isEmpty
                                          ? 'รสชาติ'
                                          : selectedFlavours.join(', '),
                                      style: selectedFlavours.isEmpty
                                          ? Styles.black18(context)
                                          : Styles.pirmary18(context),
                                      overflow: TextOverflow
                                          .ellipsis, // Truncate if too long
                                      maxLines: 1, // Restrict to 1 line
                                      softWrap: false, // Avoid wrapping
                                    ),
                                    width: selectedFlavours.isEmpty ? 120 : 120,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _clearFilter();
                                    context.loaderOverlay.show();
                                    _getProduct().then(
                                        (_) => Timer(Duration(seconds: 1), () {
                                              context.loaderOverlay.hide();
                                            }));
                                  },
                                  child: badgeFilter(
                                    openIcon: false,
                                    child: Text(
                                      'ล้างตัวเลือก',
                                      style: Styles.black18(context),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                duration: const Duration(milliseconds: 500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              autofocus: false,
                              style: Styles.black18(context),
                              controller: searchController,
                              onChanged: (query) {
                                if (query != "") {
                                  setState(() {
                                    filteredProductList = productList
                                        .where((item) =>
                                            item.name.toLowerCase().contains(
                                                query.toLowerCase()) ||
                                            item.brand.toLowerCase().contains(
                                                query.toLowerCase()) ||
                                            item.group.toLowerCase().contains(
                                                query.toLowerCase()) ||
                                            item.flavour.toLowerCase().contains(
                                                query.toLowerCase()) ||
                                            item.id.toLowerCase().contains(
                                                query.toLowerCase()) ||
                                            item.size
                                                .toLowerCase()
                                                .contains(query.toLowerCase()))
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
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _isGridView
                        ? Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount:
                                        (filteredProductList.length / 2).ceil(),
                                    itemBuilder: (context, index) {
                                      final firstIndex = index * 2;
                                      final secondIndex = firstIndex + 1;
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: OrderMenuListVerticalCard(
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
                                              child: OrderMenuListVerticalCard(
                                                item: filteredProductList[
                                                    secondIndex],
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
                                        product: filteredProductList[index],
                                        onTap: () {
                                          print(filteredProductList[index]);
                                          setState(() {
                                            selectedUnit = '';
                                            selectedSize = '';
                                            price = 0.00;
                                            count = 1;
                                            total = 0.00;
                                            stockQty = 0;
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
                  ],
                ),
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
                          Icons.warehouse_outlined,
                          color: Colors.white,
                          size: 35,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(4),
                          backgroundColor: Styles.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      cartList.isNotEmpty
                          ? Container(
                              width: 25, // Set the width of the button
                              height: 25,
                              // constraints: BoxConstraints(minHeight: 32, minWidth: 32),
                              decoration: BoxDecoration(
                                // This controls the shadow
                                boxShadow: [
                                  BoxShadow(
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    color: Colors.black.withAlpha(50),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(180),
                                color: Colors
                                    .red, // This would be color of the Badge
                              ),
                              // This is your Badge
                            )
                          : Container(),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Expanded(
                  //   flex: 2,
                  //   child: Text(
                  //     "ยอดรวม ฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(totalCart)} บาท",
                  //     style: Styles.black24(context),
                  //   ),
                  // ),
                  const SizedBox(width: 8),
                  Expanded(
                    // Ensures text does not overflow the screen
                    child: ButtonFullWidth(
                      text: 'ขอปรับรายการ Stock',
                      blackGroundColor: Styles.primaryColor,
                      textStyle: Styles.white18(context),
                      onPressed: () {
                        if (cartList.length > 0 && casue != '') {
                          _checkout();
                          // Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WithdrawDetailScreen(orderId: widget.orderId),
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
                              "กรุณาเลือกรายกาและเหตุผล",
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
      )),
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
                                                  'รหัส : ${product.id}',
                                                  style:
                                                      Styles.black16(context),
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
                                                  // context.loaderOverlay.show();
                                                  // print(selectedUnit);
                                                  // print(selectedSize);
                                                  await _getQty(
                                                      product, setModalState);
                                                  // context.loaderOverlay.hide();
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
                                              text: 'เลือก',
                                              blackGroundColor:
                                                  Styles.primaryColor,
                                              textStyle:
                                                  Styles.white18(context),
                                              onPressed: () async {
                                                print(
                                                    "selectedSize $selectedSize");
                                                if (selectedSize != "") {
                                                  context.loaderOverlay.show();

                                                  await _addCart(
                                                      product, selectType);
                                                  await _getCart();
                                                  context.loaderOverlay.hide();
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

  Future<void> _reduceCart(
      StockAjustCart cart, StateSetter setModalState) async {
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
              "type": "adjuststock",
              "area": User.area,
              "withdrawId": widget.orderId,
              "id": cart.id,
              "qty": cart.qty,
              "unit": cart.unit,
              "stockType": "OUT"
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

  Future<void> _deleteCart(
      StockAjustCart cart, StateSetter setModalState) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/cart/delete',
        method: 'POST',
        body: {
          "type": "adjuststock",
          "area": "${User.area}",
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
    } catch (e) {
      print("Error _deleteCart: $e");
    }
  }

  void _showCartSheet(BuildContext context, List<StockAjustCart> cartlist) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height and scrolling
      shape: const RoundedRectangleBorder(
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
                                Icons.warehouse_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              Text(' รายการสินค้าที่ขอปรับ',
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
                                // controller: _cartScrollController,
                                thickness: 10,
                                thumbVisibility: true,
                                trackVisibility: true,
                                radius: Radius.circular(16),
                                child: ListView.builder(
                                  // controller: _cartScrollController,
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
                                                        const Icon(
                                                            Icons.hide_image,
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
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'ประเภท : ${cartlist[index].action}',
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

                                                                setModalState(
                                                                  () {
                                                                    cartList.removeWhere((item) => (item.id ==
                                                                            cartlist[index]
                                                                                .id &&
                                                                        item.unit ==
                                                                            cartlist[index].unit));
                                                                  },
                                                                );

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
                    // Container(
                    //   color: Styles.primaryColor,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(16.0),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Text("ยอดรวม", style: Styles.white24(context)),
                    //         Text(
                    //             "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(totalCart)} บาท",
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

  void _showCauseSheet(BuildContext context) {
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
                                Icons.pending,
                                color: Colors.white,
                                size: 30,
                              ),
                              Text(' เลือกเหตุผลที่ขอปรับ Stock',
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
                              // controller: _shippingScrollController,
                              thickness: 10,
                              thumbVisibility: true,
                              trackVisibility: true,
                              radius: Radius.circular(16),
                              child: ListView.builder(
                                // controller: _shippingScrollController,
                                itemCount: isSelect == 1
                                    ? causeAdd.length
                                    : causeReduce.length,
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
                                                  if (isSelect == 1) {
                                                    setModalState(() {
                                                      isShippingId =
                                                          causeAdd[index];
                                                    });
                                                  } else {
                                                    setModalState(() {
                                                      isShippingId =
                                                          causeReduce[index];
                                                    });
                                                  }

                                                  if (isSelect == 1) {
                                                    setState(() {
                                                      casue = causeAdd[index];
                                                    });
                                                  } else {
                                                    setState(() {
                                                      casue =
                                                          causeReduce[index];
                                                    });
                                                  }
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
                                                              isSelect == 1
                                                                  ? Text(
                                                                      causeAdd[
                                                                          index],
                                                                      style: Styles
                                                                          .black18(
                                                                              context),
                                                                    )
                                                                  : Text(
                                                                      causeReduce[
                                                                          index],
                                                                      style: Styles
                                                                          .black18(
                                                                              context)),
                                                            ],
                                                          ),
                                                        ),
                                                        isSelect == 1
                                                            ? isShippingId ==
                                                                    causeAdd[
                                                                        index]
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
                                                            : isShippingId ==
                                                                    causeReduce[
                                                                        index]
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
                              // _getCart();
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
