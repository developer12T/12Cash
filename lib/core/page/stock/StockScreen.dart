import 'dart:async';
import 'dart:typed_data';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/components/card/stock/ProductStockCard.dart';
import 'package:_12sale_app/core/components/card/stock/ProductStockVerticalCard.dart';
import 'package:_12sale_app/core/components/filter/BadageFilter.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:toastification/toastification.dart';

import '../../../data/models/order/Product.dart';

// import '../../../data/models/stock/StockAvaliable.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  bool _connected = false;
  BluetoothInfo? _selectedDevice;

  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  List<Product> filteredProductList = [];

  List<Product> productList = [];

  List<String> groupList = [];
  List<String> selectedGroups = [];

  List<String> brandList = [];
  List<String> selectedBrands = [];

  List<String> sizeList = [];
  List<String> selectedSizes = [];
  List<String> selectedFlavours = [];
  List<String> flavourList = [];

  int count = 1;
  double price = 0;
  double total = 0.00;
  String selectedSize = "";
  String selectedUnit = "";
  double totalCart = 0.00;

  bool _loadingProduct = true;
  bool _isGridView = false;
  int _isSelectedGridView = 1;

  int stockQty = 0;
  // String lotStock = "";

  final int paperWidth = 69;
  final int paperWidthHeader = 76;

  static const String encoding = 'TIS-620';

  String status = '';
  final List<String> vowelAndToneMark = [
    '่',
    '้',
    '๊',
    '๋',
    'ั',
    '็',
    'ิ',
    'ี',
    'ุ',
    'ู',
    'ึ',
    'ื',
    '์',
    '.'
  ];

  TextEditingController searchController = TextEditingController();

  final Map<String, dynamic> receiptData = {
    "customer": {
      "customercode": "",
      "customername": "",
      "address1": "",
      "address2": "",
      "address3": "",
      "postCode": "",
      "taxno": "",
      "salecode": ""
    },
    "CUOR": "",
    "OAORDT": "",
    "items": [
      // {
      //   "name": "ผงทำซุปน้ำข้น ฟ้าไทย 75g x10x8",
      //   "id": "10010601011",
      //   "qty": "12",
      //   "qtyCTN": "2",
      //   "listUnit": [
      //     {"unitText": "หีบ", "unit": "CTN", "qty": "2"},
      //     {"unitText": "ถุง", "unit": "BAG", "qty": "5"},
      //     {"unitText": "ชิ้น", "unit": "PCS", "qty": "12"}
      //   ],
      // },
      // {
      //   "name": "ผงปรุงรสเห็ดหอม ฟ้าไทย 165g x6x6",
      //   "id": "10010301019",
      //   "qty": "300",
      //   "qtyCTN": "40",
      //   "listUnit": [
      //     {"unitText": "หีบ", "unit": "CTN", "qty": "40"},
      //     {"unitText": "ชิ้น", "unit": "PCS", "qty": "300"}
      //   ],
      // }
    ],
    "totaltext": "0.00",
    "ex_vat": "0.00",
    "vat": "0.00",
    "discount": "0.00",
    "discountProduct": "0.00",
    "total": "0.00",
    "OBSMCD": ""
  };

  @override
  void initState() {
    super.initState();
    _getFliter();
    _getProductStock();
  }

  String formatFixedWidthRow2(
    String num,
    String itemName,
    String id,
    List<Map<String, dynamic>> listUnit,
  ) {
    const int numWidth = 3;
    const int nameWidth = 30;
    const int itemCodeWidth = 12;

    List<String> wrapText(String text, int width) {
      List<String> lines = [];
      for (int i = 0; i < text.length; i += width) {
        lines.add(text.substring(
            i, i + width > text.length ? text.length : i + width));
      }
      return lines;
    }

    int _getNoOfUpperLowerChars(String text) {
      // Optional helper for spacing adjustments (can be customized)
      return 0; // keep simple unless needed
    }

    // Format unit summary
    String formatUnitSummary(List<Map<String, dynamic>> listUnit) {
      return listUnit.map((unit) => "${unit['qty']} ${unit['name']}").join('/');
    }

    List<String> itemNameLines = wrapText(itemName, nameWidth);
    itemNameLines = itemNameLines.map((line) {
      return line.padRight(nameWidth + _getNoOfUpperLowerChars(line));
    }).toList();

    String unitSummary = formatUnitSummary(listUnit);
    String formattedNum = num.padRight(numWidth);
    String formattedItemCode = id.padRight(itemCodeWidth);

    StringBuffer rowBuffer = StringBuffer();
    for (int i = 0; i < itemNameLines.length; i++) {
      if (i == 0) {
        rowBuffer.write(formattedNum);
        rowBuffer.write(formattedItemCode);
      } else {
        rowBuffer.write(''.padRight(itemCodeWidth + numWidth));
      }

      rowBuffer.write(itemNameLines[i]);

      if (i == 0) {
        rowBuffer.write('    $unitSummary\n');
      } else {
        rowBuffer.write('\n');
      }
    }
    return rowBuffer.toString();
  }

  Future<void> printBill(String text,
      {TextAlign align = TextAlign.left,
      int newLine = 1,
      int fontSize = 1,
      bool isBold = false}) async {
    String alignedText;

    switch (align) {
      case TextAlign.center:
        alignedText = text.padLeft((paperWidth + text.length) ~/ 2);
        break;
      case TextAlign.right:
        alignedText = text.padLeft(paperWidth);
        break;
      default:
        alignedText = text;
    }

    await _printText(alignedText,
        fontSize: fontSize, isBold: isBold, newLine: newLine);
  }

  Future<void> _printText(String text,
      {int fontSize = 1, bool isBold = false, int newLine = 1}) async {
    // Convert text to TIS-620 encoding
    Uint8List encodedText = await CharsetConverter.encode(encoding, text);

    // Print the encoded text
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedText));
  }

  String leftRightText(String left, String right, int width) {
    int space = width - left.length - right.length;
    return left + ' ' * space + right;
  }

  Future<void> printBodyBill(Map<String, dynamic> data) async {
    await printBill("\nรายการสินค้า${' ' * (36)}จำนวน");
    String items = await data['items'].asMap().entries.map((entry) {
      int index = entry.key;
      var item = entry.value;
      // Safely get a substring only if the length is greater than 36
      String itemName = item['name'];
      return formatFixedWidthRow2("${(index + 1).toString()}", '$itemName',
          item['id'], item['listUnit']);
    }).join('\n');

    Uint8List encodedItems = await CharsetConverter.encode('TIS-620', items);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedItems));
    String footer = '''
    ${leftRightText('', '\n\n\n', 61)}
    ''';
    Uint8List encodedFooter = await CharsetConverter.encode('TIS-620', footer);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedFooter));
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

  Future<void> _getProductStock() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/stock/availableStock',
        method: 'POST',
        body: {
          "area": "${User.area}",
          "period": "${period}",
          "type": "sale",
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
            // productList = data.map((item) => Product.fromJson(item)).toList();
            // filteredProductList = List.from(productList);
            // receiptData["items"] = productList
            //     .map((item) => {
            //           "name": item.name,
            //           "id": item.id,
            //           "qty": item.totalQtyPcs.toString(),
            //           "qtyCTN": item.totalQtyCtn.toString(),
            //           "listUnit": item.listUnit
            //               .map((unit) => {
            //                     "name": unit.name,
            //                     "unit": unit.unit,
            //                     "qty": unit
            //                         .qty, // or unit.price, depending on what qty should represent
            //                   })
            //               .toList(),
            //         })
            //     .toList();
          });
          // print("receiptData: ${receiptData["items"]}");

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
      print("Error _getProductStock: $e");
    }
  }

  int _getNoOfUpperLowerChars(String text) {
    int counter =
        text.split('').where((char) => vowelAndToneMark.contains(char)).length;
    return counter;
  }

  String centerText(String text, int width) {
    int leftPadding =
        (width - text.length + _getNoOfUpperLowerChars(text)) ~/ 2;
    return ' ' * leftPadding + text;
  }

  Future<void> printHeaderBill(String typeBill) async {
    String header = '''
${centerText('รายการ Stock ณ วันที่ ${DateTime.now().toString().substring(0, 10)}', 69)}
''';
    Uint8List encodedContent = await CharsetConverter.encode('TIS-620', header);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedContent));
  }

  Future<void> printTest() async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      await printHeaderBill('บิลเงินสด/ใบกำกับภาษี');
      await printBodyBill(receiptData);
    } else {
      toastification.show(
        autoCloseDuration: const Duration(seconds: 5),
        context: context,
        primaryColor: Colors.red,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(
          "ยังไม่ได้เชื่อมต่อเครื่องปริ้น",
          style: Styles.red18(context),
        ),
      );
    }
  }

  // Future<void> _getListStore() async {
  //   try {
  //     ApiService apiService = ApiService();
  //     await apiService.init();

  //     var response = await apiService.request(
  //       endpoint: 'api/cash/stock/?area=${User.area}&period=${period}',
  //       method: 'GET',
  //     );

  //     if (response.statusCode == 200) {}
  //   } catch (e) {
  //     print("Error _getListStore $e");
  //   }
  // }

  Future<void> _disconnectPrinter() async {
    bool result = await PrintBluetoothThermal.disconnect;
    print("Printer disconnected ($result)");
    setState(() {
      _connected = !result;
      User.connectPrinter = !result;
      _selectedDevice = null;
    });
    toastification.show(
      autoCloseDuration: const Duration(seconds: 5),
      context: context,
      primaryColor: Colors.red,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(
        "ยกเลิกการเชื่อมต่อ",
        style: Styles.red18(context),
      ),
    );
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

  Future<void> _connectToPrinter(BluetoothInfo device) async {
    try {
      bool result = await PrintBluetoothThermal.connect(
          macPrinterAddress: device.macAdress);
      setState(() {
        User.connectPrinter = result;
        _connected = result;
        _selectedDevice = result ? device : null;
      });

      if (result) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "เชื่อมต่อแล้วกับ ${device.name}",
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
            "เชื่อมต่อไม่ได้กับ ${device.name}",
            style: Styles.red18(context),
          ),
        );
      }
    } catch (e) {
      print("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(title: " สต๊อก", icon: Icons.warehouse),
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
                    backgroundColor:
                        User.connectPrinter ? Styles.success : Styles.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (!User.connectPrinter) {
                      _connectToPrinter(User.devicePrinter);
                    } else {
                      _disconnectPrinter();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.print_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
                            Text(
                              " ${User.connectPrinter ? "เชื่อมต่อแล้ว" : "ยังไม่ได้เชื่อมต่อ"}",
                              style: Styles.headerWhite18(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor:
                        _loadingProduct ? Styles.grey : Styles.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (!_loadingProduct) {
                      await printTest();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.print_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
                            Text(
                              " พิมพ์รายการ Stock",
                              style: Styles.headerWhite18(context),
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
        )
      ],
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "สินค้าคงเหลือ",
                  style: Styles.black24(context),
                  textAlign: TextAlign.center,
                ),
              ],
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
                                // autofocus: true,
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
                                              item.flavour
                                                  .toLowerCase()
                                                  .contains(
                                                      query.toLowerCase()) ||
                                              item.id.toLowerCase().contains(
                                                  query.toLowerCase()) ||
                                              item.size.toLowerCase().contains(
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
                                    borderRadius: BorderRadius.circular(16.0),
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
                                          _getProductStock().then((_) =>
                                              Timer(Duration(seconds: 3), () {
                                                context.loaderOverlay.hide();
                                              }));
                                        },
                                        onSearch: _getProductStock,
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
                                          _getProductStock().then((_) =>
                                              Timer(Duration(seconds: 3), () {
                                                context.loaderOverlay.hide();
                                              }));
                                        },
                                        onSearch: _getProductStock,
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
                                          _getProductStock().then((_) =>
                                              Timer(Duration(seconds: 3), () {
                                                context.loaderOverlay.hide();
                                              }));
                                        },
                                        onSearch: _getProductStock,
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
                                          _getProductStock().then((_) =>
                                              Timer(Duration(seconds: 3), () {
                                                context.loaderOverlay.hide();
                                              }));
                                        },
                                        onSearch: _getProductStock,
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
                                      width:
                                          selectedFlavours.isEmpty ? 120 : 120,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _clearFilter();
                                      context.loaderOverlay.show();
                                      _getProductStock().then((_) =>
                                          Timer(Duration(seconds: 3), () {
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
                                        final secondIndex = firstIndex + 1;
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: ProductStockVerticalCard(
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

                                                  // _showProductSheet(
                                                  //     context,
                                                  //     filteredProductList[
                                                  //         firstIndex]);
                                                },
                                              ),
                                            ),
                                            if (secondIndex <
                                                filteredProductList.length)
                                              Expanded(
                                                child: ProductStockVerticalCard(
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
                                                    // _showProductSheet(
                                                    //     context,
                                                    //     filteredProductList[
                                                    //         secondIndex]);
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
                                  //       child: ProductStockVerticalCard(
                                  //         onDetailsPressed: () {},
                                  //       ),
                                  //     ),
                                  //     Expanded(
                                  //       child: ProductStockVerticalCard(
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
                                        return ProductStockCard(
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
                                            // _showProductSheet(context,
                                            //     filteredProductList[index]);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      // Container(
                      //   margin: EdgeInsets.only(top: 8),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Stack(
                      //         alignment: Alignment(1.3, -1.5),
                      //         children: [
                      //           ElevatedButton(
                      //             onPressed: () async {
                      //               await _getCart();
                      //               _showCartSheet(context, cartList);
                      //             },
                      //             child: Icon(
                      //               Icons.shopping_bag_outlined,
                      //               color: Colors.white,
                      //               size: 35,
                      //             ),
                      //             style: ElevatedButton.styleFrom(
                      //               padding: EdgeInsets.all(4),
                      //               backgroundColor: Styles.primaryColor,
                      //               shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.circular(8),
                      //               ),
                      //             ),
                      //           ),
                      //           cartList.isNotEmpty
                      //               ? Container(
                      //                   width:
                      //                       25, // Set the width of the button
                      //                   height: 25,
                      //                   // constraints: BoxConstraints(minHeight: 32, minWidth: 32),
                      //                   decoration: BoxDecoration(
                      //                     // This controls the shadow
                      //                     boxShadow: [
                      //                       BoxShadow(
                      //                         spreadRadius: 1,
                      //                         blurRadius: 5,
                      //                         color: Colors.black.withAlpha(50),
                      //                       )
                      //                     ],
                      //                     borderRadius:
                      //                         BorderRadius.circular(180),
                      //                     color: Colors
                      //                         .red, // This would be color of the Badge
                      //                   ),
                      //                   // This is your Badge
                      //                 )
                      //               : Container(),
                      //         ],
                      //       ),
                      //       const SizedBox(width: 20),
                      //       Expanded(
                      //         flex: 2,
                      //         child: Text(
                      //           "ยอดรวม ฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(totalCart)} บาท",
                      //           style: Styles.black24(context),
                      //         ),
                      //       ),
                      //       const SizedBox(width: 8),
                      //       Expanded(
                      //         // Ensures text does not overflow the screen
                      //         child: ButtonFullWidth(
                      //           text: 'สั่งซื้อ',
                      //           blackGroundColor: Styles.primaryColor,
                      //           textStyle: Styles.white18(context),
                      //           onPressed: () {
                      //             if (cartList.isNotEmpty) {
                      //               Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                   builder: (context) => CreateOrderScreen(
                      //                       routeId: '',
                      //                       storeId: selectedStoreId,
                      //                       storeName: selectedStore,
                      //                       storeAddress: selectedStoreAddress),
                      //                 ),
                      //               );
                      //             } else {
                      //               toastification.show(
                      //                 autoCloseDuration:
                      //                     const Duration(seconds: 5),
                      //                 context: context,
                      //                 primaryColor: Colors.red,
                      //                 type: ToastificationType.error,
                      //                 style: ToastificationStyle.flatColored,
                      //                 title: Text(
                      //                   "กรุณาเลือกรายการสินค้า",
                      //                   style: Styles.red18(context),
                      //                 ),
                      //               );
                      //             }
                      //           },
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // void _showProductSheet(BuildContext context, Product product) {
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   double screenHeight = MediaQuery.of(context).size.height;
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
  //           maxChildSize: 0.9,

  //           builder: (context, scrollController) {
  //             return Container(
  //               width: screenWidth * 0.95,
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
  //                     alignment: Alignment.centerLeft,
  //                     padding: const EdgeInsets.symmetric(
  //                         vertical: 8.0, horizontal: 16.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Text('รายละเอียดสินค้า',
  //                             style: Styles.white24(context)),
  //                         IconButton(
  //                           icon: const Icon(Icons.close, color: Colors.white),
  //                           onPressed: () => Navigator.of(context).pop(),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: SingleChildScrollView(
  //                       scrollDirection: Axis.vertical,
  //                       controller: scrollController,
  //                       child: Container(
  //                         height: screenHeight * 0.9,
  //                         color: Colors.white,
  //                         child: Padding(
  //                           padding: const EdgeInsets.symmetric(
  //                               vertical: 8.0, horizontal: 16.0),
  //                           child: Column(
  //                             children: [
  //                               Row(
  //                                 mainAxisAlignment: MainAxisAlignment.start,
  //                                 children: [
  //                                   ClipRRect(
  //                                     borderRadius: BorderRadius.circular(8),
  //                                     child: Image.network(
  //                                       '${ApiService.apiHost}/images/products/${widget.product.id}.webp',
  //                                       width: screenWidth / 4,
  //                                       height: screenWidth / 4,
  //                                       fit: BoxFit.cover,
  //                                       errorBuilder:
  //                                           (context, error, stackTrace) {
  //                                         return const Center(
  //                                           child: Icon(
  //                                             Icons.error,
  //                                             color: Colors.red,
  //                                             size: 50,
  //                                           ),
  //                                         );
  //                                       },
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.symmetric(
  //                                         horizontal: 16,
  //                                       ),
  //                                       child: Column(
  //                                         crossAxisAlignment:
  //                                             CrossAxisAlignment.start,
  //                                         children: [
  //                                           Row(
  //                                             children: [
  //                                               Expanded(
  //                                                 child: Text(
  //                                                   product.name,
  //                                                   style:
  //                                                       Styles.black24(context),
  //                                                   softWrap: true,
  //                                                   maxLines: 2,
  //                                                   overflow:
  //                                                       TextOverflow.visible,
  //                                                 ),
  //                                               ),
  //                                             ],
  //                                           ),
  //                                           Row(
  //                                             children: [
  //                                               Text(
  //                                                 'กลุ่ม : ${product.group}',
  //                                                 style:
  //                                                     Styles.black16(context),
  //                                               ),
  //                                             ],
  //                                           ),
  //                                           Row(
  //                                             children: [
  //                                               Text(
  //                                                 'แบรนด์ : ${product.brand}',
  //                                                 style:
  //                                                     Styles.black16(context),
  //                                               ),
  //                                             ],
  //                                           ),
  //                                           Row(
  //                                             children: [
  //                                               Text(
  //                                                 'ขนาด : ${product.size}',
  //                                                 style:
  //                                                     Styles.black16(context),
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Row(
  //                                 children: [
  //                                   Expanded(
  //                                     child: SingleChildScrollView(
  //                                       scrollDirection: Axis.horizontal,
  //                                       child: Row(
  //                                         children:
  //                                             product.listUnit.map((data) {
  //                                           return Container(
  //                                             margin: EdgeInsets.all(8),
  //                                             child: ElevatedButton(
  //                                               onPressed: () async {
  //                                                 setModalState(() {
  //                                                   price = double.parse(
  //                                                       data.price);
  //                                                 });

  //                                                 setModalState(
  //                                                   () {
  //                                                     selectedSize = data.name;
  //                                                     selectedUnit = data.unit;
  //                                                     total = price * count;
  //                                                   },
  //                                                 );
  //                                                 setState(() {
  //                                                   price = double.parse(
  //                                                       data.price);
  //                                                   selectedSize = data.name;
  //                                                   selectedUnit = data.unit;
  //                                                   total = price * count;
  //                                                 });
  //                                                 context.loaderOverlay.show();
  //                                                 // print(selectedUnit);
  //                                                 // print(selectedSize);
  //                                                 await _getQty(
  //                                                     product, setModalState);
  //                                                 context.loaderOverlay.hide();
  //                                               },
  //                                               style: ElevatedButton.styleFrom(
  //                                                 padding: const EdgeInsets
  //                                                     .symmetric(vertical: 8),
  //                                                 backgroundColor: Colors.white,
  //                                                 shape: RoundedRectangleBorder(
  //                                                   borderRadius:
  //                                                       BorderRadius.circular(
  //                                                           8),
  //                                                   side: BorderSide(
  //                                                     color: selectedSize ==
  //                                                             data.name
  //                                                         ? Styles.primaryColor
  //                                                         : Colors.grey,
  //                                                     width: 1,
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                               child: Text(
  //                                                 data.name,
  //                                                 style: selectedSize ==
  //                                                         data.name
  //                                                     ? Styles.pirmary18(
  //                                                         context)
  //                                                     : Styles.grey18(context),
  //                                               ),
  //                                             ),
  //                                           );
  //                                         }).toList(), // ✅ Ensure .toList() is here
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Row(
  //                                     children: [
  //                                       Text(
  //                                           'คงเหลือ ${stockQty} ${selectedSize}',
  //                                           style: Styles.black18(context)),
  //                                     ],
  //                                   ),
  //                                 ],
  //                               ),
  //                               Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   Text(
  //                                     'ราคา',
  //                                     style: Styles.black18(context),
  //                                   ),
  //                                   Text(
  //                                     "฿${product.listUnit.any((element) => element.name == selectedSize) ? product.listUnit.where((element) => element.name == selectedSize).first.price : '0.00'} บาท",
  //                                     style: Styles.black18(context),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   Text(
  //                                     'รวม',
  //                                     style: Styles.black18(context),
  //                                   ),
  //                                   Text(
  //                                     '฿${total.toStringAsFixed(2)} บาท',
  //                                     style: Styles.black18(context),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Divider(
  //                                 color: Colors.grey[200],
  //                                 thickness: 1,
  //                                 indent: 16,
  //                                 endIndent: 16,
  //                               ),
  //                               SizedBox(
  //                                 height: 10,
  //                               ),
  //                               Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   Expanded(
  //                                     flex: 2,
  //                                     child: Row(
  //                                       children: [
  //                                         ElevatedButton(
  //                                           onPressed: () {
  //                                             if (count > 1) {
  //                                               setModalState(() {
  //                                                 count--;
  //                                                 total = price * count;
  //                                               });
  //                                               setState(() {
  //                                                 count = count;
  //                                                 total = price * count;
  //                                               });
  //                                             }
  //                                           },
  //                                           style: ElevatedButton.styleFrom(
  //                                             shape: const CircleBorder(
  //                                               side: BorderSide(
  //                                                   color: Colors.grey,
  //                                                   width: 1),
  //                                             ), // ✅ Makes the button circular
  //                                             padding: const EdgeInsets.all(8),
  //                                             backgroundColor:
  //                                                 Colors.white, // Button color
  //                                           ),
  //                                           child: const Icon(
  //                                             Icons.remove,
  //                                             size: 24,
  //                                             color: Colors.grey,
  //                                           ), // Example
  //                                         ),
  //                                         ElevatedButton(
  //                                           style: ElevatedButton.styleFrom(
  //                                             // padding: const EdgeInsets.all(8),
  //                                             elevation: 0, // Disable shadow
  //                                             shadowColor: Colors
  //                                                 .transparent, // Ensure no shadow color
  //                                             backgroundColor: Colors.white,
  //                                             shape: RoundedRectangleBorder(
  //                                                 borderRadius:
  //                                                     BorderRadius.zero,
  //                                                 side: BorderSide.none),
  //                                           ),
  //                                           onPressed: () {
  //                                             setState(() {
  //                                               count = 1;
  //                                             });
  //                                             _showCountSheet(
  //                                               context,
  //                                             );
  //                                           },
  //                                           child: Container(
  //                                             // padding: EdgeInsets.all(4),
  //                                             // margin: EdgeInsets.all(4),
  //                                             decoration: BoxDecoration(
  //                                               border: Border.all(
  //                                                 color: Colors.grey,
  //                                                 width: 1,
  //                                               ),
  //                                               borderRadius:
  //                                                   BorderRadius.circular(16),
  //                                             ),
  //                                             width: 75,
  //                                             height: 40,
  //                                             child: Column(
  //                                               mainAxisAlignment:
  //                                                   MainAxisAlignment.center,
  //                                               children: [
  //                                                 Text(
  //                                                   '${count.toStringAsFixed(0)}',
  //                                                   textAlign: TextAlign.center,
  //                                                   style:
  //                                                       Styles.black18(context),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         ElevatedButton(
  //                                           onPressed: () {
  //                                             setModalState(() {
  //                                               count++;
  //                                               total = price * count;
  //                                             });
  //                                             setState(() {
  //                                               count = count;
  //                                               total = price * count;
  //                                             });
  //                                             print("total${total}");
  //                                           },
  //                                           style: ElevatedButton.styleFrom(
  //                                             shape: const CircleBorder(
  //                                               side: BorderSide(
  //                                                   color: Colors.grey,
  //                                                   width: 1),
  //                                             ), // ✅ Makes the button circular
  //                                             padding: const EdgeInsets.all(8),
  //                                             backgroundColor:
  //                                                 Colors.white, // Button color
  //                                           ),
  //                                           child: const Icon(
  //                                             Icons.add,
  //                                             size: 24,
  //                                             color: Colors.grey,
  //                                           ), // Example
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     flex: 2,
  //                                     child: Row(
  //                                       children: [
  //                                         Expanded(
  //                                           child: ButtonFullWidth(
  //                                             text: 'ใส่ตะกร้า',
  //                                             blackGroundColor:
  //                                                 Styles.primaryColor,
  //                                             textStyle:
  //                                                 Styles.white18(context),
  //                                             onPressed: () async {
  //                                               print(
  //                                                   "selectedSize $selectedSize");
  //                                               if (selectedSize != "") {
  //                                                 if ((stockQty > 0) &&
  //                                                     (stockQty >= count)) {
  //                                                   context.loaderOverlay
  //                                                       .show();
  //                                                   await _addCart(product);
  //                                                   await _getCart();
  //                                                   await _updateStock(product,
  //                                                       setModalState, "OUT");
  //                                                   context.loaderOverlay
  //                                                       .hide();
  //                                                 } else {
  //                                                   toastification.show(
  //                                                     autoCloseDuration:
  //                                                         const Duration(
  //                                                             seconds: 5),
  //                                                     context: context,
  //                                                     primaryColor: Colors.red,
  //                                                     type: ToastificationType
  //                                                         .error,
  //                                                     style: ToastificationStyle
  //                                                         .flatColored,
  //                                                     title: Text(
  //                                                       "ไม่มีของในสต๊อกหรือมีไม่พอ",
  //                                                       style: Styles.red18(
  //                                                           context),
  //                                                     ),
  //                                                   );
  //                                                 }
  //                                               } else {
  //                                                 toastification.show(
  //                                                   autoCloseDuration:
  //                                                       const Duration(
  //                                                           seconds: 5),
  //                                                   context: context,
  //                                                   primaryColor: Colors.red,
  //                                                   type: ToastificationType
  //                                                       .error,
  //                                                   style: ToastificationStyle
  //                                                       .flatColored,
  //                                                   title: Text(
  //                                                     "กรุณาเลือกขนาด",
  //                                                     style:
  //                                                         Styles.red18(context),
  //                                                   ),
  //                                                 );
  //                                               }
  //                                             },
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ],
  //                           ),
  //                         ),
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
}
