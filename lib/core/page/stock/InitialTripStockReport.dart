import 'dart:async';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListCard.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListVerticalCard.dart';
import 'package:_12sale_app/core/components/filter/BadageFilter.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/Product.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dartx/dartx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

class InitialTripStockReport extends StatefulWidget {
  const InitialTripStockReport({super.key});

  @override
  State<InitialTripStockReport> createState() => _InitialTripStockReportState();
}

class _InitialTripStockReportState extends State<InitialTripStockReport> {
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
  bool _isGridView = false;
  int _isSelectedGridView = 1;
  int count = 1;
  double price = 0;
  double total = 0.00;
  double totalCart = 0.00;

  int stockQty = 0;

  TextEditingController countController = TextEditingController();

  TextEditingController searchController = TextEditingController();

  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  void initState() {
    super.initState();
    _getFliter();
    _getProduct();
    // _getCart();
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
                                                  // lotStock = '';
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
            )
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
                                                  // await _getQty(
                                                  //     product, setModalState);
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

                                                  // await _addCart(product);
                                                  // await _getCart();

                                                  // await _updateStock(product,
                                                  //     setModalState, "OUT");
                                                  // context.loaderOverlay
                                                  //     .hide();
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
