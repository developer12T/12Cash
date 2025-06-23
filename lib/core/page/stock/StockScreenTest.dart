import 'dart:async';
import 'dart:typed_data';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchCustom.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchGroup.dart';
import 'package:_12sale_app/core/components/table/ReusableTable.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/stock/Stock.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:toastification/toastification.dart';

import '../../../data/models/option/Group.dart';

class StockScreenTest extends StatefulWidget {
  const StockScreenTest({super.key});

  @override
  State<StockScreenTest> createState() => _StockScreenTestState();
}

class _StockScreenTestState extends State<StockScreenTest> {
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  List<Stock> stocks = [];
  List<List<String>> rows = [];
  List<String> footerTable = [];
  List<String> footerTable2 = [];
  Group? selectedGroup;
  List<List<String>> filteredRows = [];
  bool isLoading = true;
  bool _loadingProduct = true;
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
  final int paperWidth = 69;
  final int paperWidthHeader = 76;
  static const String encoding = 'TIS-620';

  final Map<String, dynamic> receiptData = {
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
  };

  @override
  void initState() {
    super.initState();
    _getStockQty();
  }

  Future<List<Group>> getShoptype(String filter) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
        endpoint: 'api/cash/order/getGroup',
        method: 'GET',
      );
      var rawList = response.data['data'] as List<dynamic>;
      // print(data);
      // var data = response.data['data'] as List<dynamic>;

      List<Group> groups = rawList
          .where(
              (e) => e['groupCode'] != null) // Optional: ensure code is present
          .map((e) => Group.fromJson(e))
          .toList();

      return groups;
    } catch (e) {
      print("Error occurred: $e");
      return [];
    }
  }

  Future<void> _getStockQty() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      final response = await apiService.request(
        endpoint: 'api/cash/stock/getStockQty',
        method: 'POST',
        body: {"area": User.area, "period": period},
      );

      if (response.statusCode == 200 && mounted) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          footerTable = [
            'รวมจำนวน (PCS)',
            '${response.data['summaryStockPcs']}',
            '${response.data['summaryStockInPcs']}',
            '${response.data['summaryStockOutPcs']}',
            '${response.data['summaryStockBalPcs']}'
          ];

          footerTable2 = [
            'รวมจำนวนเงิน (บาท)',
            '${response.data['summaryStock']}',
            '${response.data['summaryStockIn']}',
            '${response.data['summaryStockOut']}',
            '${response.data['summaryStockBal']}'
          ];
        });

        // final allowedUnits = ['CTN', 'PCS'];

        final fetchedStocks = (response.data['data'] as List)
            .map((item) => Stock.fromJson(item))
            .toList();

        setState(() {
          receiptData["items"] = data
              .map((item) {
                final listUnit = (item["listUnit"] as List)
                    .where((unit) =>
                        unit["unit"] != null) // optional filter, if needed
                    .map((unit) => {
                          "unit": unit["unit"],
                          "unitName": unit["unitName"],
                          "stock": unit["stock"] ?? 0,
                          "stockIn": unit["stockIn"] ?? 0,
                          "stockOut": unit["stockOut"] ?? 0,
                          "balance": unit["balance"] ?? 0,
                        })
                    .toList();

                if (listUnit.isEmpty) return null;

                return {
                  "productId": item["productId"],
                  "productName": item["productName"],
                  "listUnit": listUnit
                };
              })
              .where((e) => e != null)
              .toList();
        });

        // setState(() {
        //   receiptData["items"] = data
        //       .map((item) {
        //         final pcsUnit = (item["listUnit"] as List).firstWhere(
        //           (unit) => unit["unit"] == "PCS",
        //           orElse: () => null,
        //         );

        //         if (pcsUnit == null) return null;

        //         return {
        //           "productId": item["productId"],
        //           "productName": item["productName"],
        //           "listUnit": [
        //             {
        //               "unit": "PCS",
        //               "stock": pcsUnit["stock"] ?? 0,
        //               "stockIn": pcsUnit["stockIn"] ?? 0,
        //               "stockOut": pcsUnit["stockOut"] ?? 0,
        //               "balance": pcsUnit["balance"] ?? 0,
        //             }
        //           ]
        //         };
        //       })
        //       .where((e) => e != null)
        //       .toList();
        // });

        final fetchedRows = fetchedStocks.map<List<String>>((item) {
          // final unitMap = <String, Map<String, int>>{};
          final unitList = <Unit>[];
          // for (var unit in item.listUnit) {
          //   // if (allowedUnits.contains(unit.unit)) {
          //   unitMap[unit.unit] = {
          //     'stock': unit.stock,
          //     'stockIn': unit.stockIn,
          //     'stockOut': unit.stockOut,
          //     'balance': unit.balance,
          //   };
          //   // }
          // }

          for (var unit in item.listUnit) {
            unitList.add(Unit(
              unit: unit.unit,
              unitName: unit.unitName,
              stock: unit.stock,
              stockIn: unit.stockIn,
              stockOut: unit.stockOut,
              balance: unit.balance,
            ));
          }
          // print("unitMap $unitMap");

          // String joinField(String field) {
          //   return unitMap.entries.map((entry) {
          //     final unit = entry.key;
          //     final value = entry.value[field]?.toString() ?? '0';
          //     return '$unit: $value';
          //   }).join('\n');
          // }

          String joinField(String field) {
            return unitList.map((u) {
              final value = switch (field) {
                'stock' => u.stock,
                'stockIn' => u.stockIn,
                'stockOut' => u.stockOut,
                'balance' => u.balance,
                _ => 0,
              };
              return '$value ${u.unitName}';
            }).join('\n');
          }

          // String joinField(String field) => allowedUnits
          //     .map((unit) => unitMap[unit]?[field]?.toString() ?? '0')
          //     .join('/');

          return [
            item.productName,
            joinField('stock'),
            joinField('stockIn'),
            joinField('stockOut'),
            joinField('balance'),
          ];
        }).toList();

        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loadingProduct = false;
            });
          }
        });

        setState(() {
          stocks = fetchedStocks;
          rows = fetchedRows;
          filteredRows = rows; // Initially show all
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error _getStockQty: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  int _getNoOfUpperLowerChars(String text) {
    int counter =
        text.split('').where((char) => vowelAndToneMark.contains(char)).length;
    return counter;
  }

  Future<void> _printText(String text,
      {int fontSize = 1, bool isBold = false, int newLine = 1}) async {
    // Convert text to TIS-620 encoding
    Uint8List encodedText = await CharsetConverter.encode(encoding, text);

    // Print the encoded text
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedText));
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

  String centerText(String text, int width) {
    int leftPadding =
        (width - text.length + _getNoOfUpperLowerChars(text)) ~/ 2;
    return ' ' * leftPadding + text;
  }

  Future<void> printHeaderBill(String typeBill) async {
    String header = '''
${centerText('รายการ Stock ณ วันที่ ${DateTime.now().toString().substring(0, 10)} เขต ${User.area}', 69)}
''';
    Uint8List encodedContent = await CharsetConverter.encode('TIS-620', header);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedContent));
  }

  String leftRightText(String left, String right, int width) {
    int space = width - left.length - right.length;
    return left + ' ' * space + right;
  }

  // String formatFixedWidthRow2(String num, String itemName, String stock,
  //     String stockIn, String stockOut, String balance) {
  //   const int numWidth = 3;
  //   const int nameWidth = 35;
  //   const int stockWidth = 5;
  //   const int stockInWidth = 5;
  //   const int stockOutWidth = 5;
  //   const int balanceWidth = 5;

  //   List<String> wrapText(String text, int width) {
  //     List<String> lines = [];
  //     for (int i = 0; i < text.length; i += width) {
  //       lines.add(text.substring(
  //           i, i + width > text.length ? text.length : i + width));
  //     }
  //     return lines;
  //   }

  //   List<String> itemNameLines = wrapText(itemName, nameWidth);

  //   // Ensure all wrapped lines are properly padded
  //   itemNameLines = itemNameLines.map((line) {
  //     return line.padRight(nameWidth + _getNoOfUpperLowerChars(line));
  //   }).toList();
  //   String formattedNum = num.padRight(numWidth);
  //   String formattedStock = stock.padLeft(stockWidth);
  //   String formattedStockIn = stockIn.padLeft(stockInWidth);
  //   String formattedStockOut = stockOut.padLeft(stockOutWidth);
  //   String formattedBalance = balance.padLeft(balanceWidth);

  //   StringBuffer rowBuffer = StringBuffer();
  //   for (int i = 0; i < itemNameLines.length; i++) {
  //     if (i == 0) {
  //       rowBuffer.write(formattedNum);
  //     }
  //     if (i > 0) {
  //       rowBuffer.write(''.padRight(numWidth));
  //     }

  //     rowBuffer.write(itemNameLines[i]);

  //     if (i == 0) {
  //       // First line includes all columns
  //       rowBuffer.write(
  //           '   $formattedStock $formattedStockIn $formattedStockOut $formattedBalance \n');
  //     } else {
  //       // Subsequent lines only contain the wrapped item name
  //       rowBuffer.write('\n');
  //     }
  //   }

  //   return rowBuffer.toString();
  // }

  String formatFixedWidthRowMultiUnit(
    String num,
    String itemName,
    List<Map<String, String>>
        unitRows, // [{stock, stockIn, stockOut, balance, unit}]
  ) {
    const int numWidth = 3;
    const int nameWidth = 24;
    const int qtyWidth = 3;
    const int unitWidth = 5;

    List<String> wrapText(String text, int width) {
      List<String> lines = [];
      for (int i = 0; i < text.length; i += width) {
        lines.add(text.substring(
            i, i + width > text.length ? text.length : i + width));
      }
      return lines;
    }

    List<String> itemNameLines =
        wrapText(itemName, nameWidth + _getNoOfUpperLowerChars(itemName));

    // List<String> itemNameLines = [];
    // itemNameLines.add(
    //     itemName.padRight(4 + nameWidth + _getNoOfUpperLowerChars(itemName)));

    itemNameLines = itemNameLines.map((line) {
      return line.padRight(2 + nameWidth + _getNoOfUpperLowerChars(line));
    }).toList();

    String padQtyUnit(String qty, String unit) {
      return '${qty.padLeft(qtyWidth)} ${unit.padRight(unitWidth + _getNoOfUpperLowerChars(unit))}';
    }

    // StringBuffer rowBuffer = StringBuffer();
    // for (int i = 0; i < itemNameLines.length; i++) {
    //   if (i == 0) {
    //     rowBuffer.write(formattedNum);
    //   }
    //   if (i > 0) {
    //     rowBuffer.write(''.padRight(numWidth));
    //   }
    //   rowBuffer.write(itemNameLines[i]);
    //   if (i == 0) {
    //     rowBuffer.write(num.padRight(numWidth));
    //     rowBuffer.write(itemNameLines[0]);
    //   } else {
    //     // Subsequent lines only contain the wrapped item name
    //     rowBuffer.write('\n');
    //   }
    // }

    // for (int i = 0; i < unitRows.length; i++) {
    //   final row = unitRows[i];

    //   final String stock =
    //       padQtyUnit(row['stock'] ?? '', row['unitName'] ?? '');
    //   final String stockIn =
    //       padQtyUnit(row['stockIn'] ?? '', row['unitName'] ?? '');
    //   final String stockOut =
    //       padQtyUnit(row['stockOut'] ?? '', row['unitName'] ?? '');
    //   final String balance =
    //       padQtyUnit(row['balance'] ?? '', row['unitName'] ?? '');

    //   if (i == 0) {
    //     buffer.write(num.padRight(numWidth));
    //     buffer.write(itemNameLines[0]);
    //   } else {
    //     buffer.write(''.padRight(numWidth));
    //     buffer
    //         .write(''.padRight(nameWidth + _getNoOfUpperLowerChars(itemName)));
    //   }
    //   buffer.write('$stock $stockIn $stockOut $balance\n');
    // }
    StringBuffer rowBuffer = StringBuffer();
    var labelWidth = numWidth + nameWidth + 1;

// Loop item name lines
    for (int i = 0; i < itemNameLines.length; i++) {
      final isFirstLine = i == 0;

      // Add prefix padding or number
      rowBuffer
          .write(isFirstLine ? num.padRight(numWidth) : ''.padRight(numWidth));

      // Write item name
      rowBuffer.write(itemNameLines[i].padRight(nameWidth + numWidth));

      // Write matching unit line (if exists)
      if (i < unitRows.length) {
        final row = unitRows[i];
        final stock = padQtyUnit(row['stock'] ?? '', row['unitName'] ?? '');
        final stockIn = padQtyUnit(row['stockIn'] ?? '', row['unitName'] ?? '');
        final stockOut =
            padQtyUnit(row['stockOut'] ?? '', row['unitName'] ?? '');
        final balance = padQtyUnit(row['balance'] ?? '', row['unitName'] ?? '');

        // final indent =
        //     ''.padLeft(nameWidth + _getNoOfUpperLowerChars(itemNameLines[i]));

        rowBuffer.write('$stock $stockIn $stockOut $balance');

        // rowBuffer.write(
        //     '${'' * (nameWidth + _getNoOfUpperLowerChars(itemNameLines[i]))}$stock $stockIn $stockOut $balance');
      }

      rowBuffer.write('\n');
    }

// If there are more unit rows than item name lines
    for (int i = itemNameLines.length; i < unitRows.length; i++) {
      final row = unitRows[i];
      final stock = padQtyUnit(row['stock'] ?? '', row['unitName'] ?? '');
      final stockIn = padQtyUnit(row['stockIn'] ?? '', row['unitName'] ?? '');
      final stockOut = padQtyUnit(row['stockOut'] ?? '', row['unitName'] ?? '');
      final balance = padQtyUnit(row['balance'] ?? '', row['unitName'] ?? '');

      rowBuffer.write(''.padRight(labelWidth));
      rowBuffer.write(' $stock $stockIn $stockOut $balance\n');
    }

    return rowBuffer.toString();
  }

  Future<void> printBodyBill(Map<String, dynamic> data) async {
    // พิมพ์หัวตาราง
    //     await printBill('รายการสินค้า'.padRight(nameWidth) +
    //         'STOCK'.padLeft(colWidth) +
    //         'IN'.padLeft(colWidth) +
    //         'OUT'.padLeft(colWidth) +
    //         'BAL'.padLeft(colWidth));
    //     await printBill('-' * (nameWidth + colWidth * 4));
    await printBill(
        "รายการสินค้า${' ' * (21)}STOCK${' ' * (8)}IN${' ' * (8)}OUT${' ' * (7)}BAL");

    // final items = (data['items'] as List)
    //     .asMap()
    //     .entries
    //     .where((entry) {
    //       var list = entry.value['listUnit'] as List;
    //       return list.any((u) => u['unit'] == 'PCS');
    //     })
    //     .take(10)
    //     .map((entry) {
    //       int index = entry.key;
    //       var item = entry.value;
    //       String itemName = item['productName'];

    //       var pcsUnit =
    //           (item['listUnit'] as List).firstWhere((u) => u['unit'] == 'PCS');

    //       return formatFixedWidthRowMultiUnit(
    //         "${index + 1}",
    //         itemName,
    //         pcsUnit['stock'].toString(),
    //         pcsUnit['stockIn'].toString(),
    //         pcsUnit['stockOut'].toString(),
    //         pcsUnit['balance'].toString(),
    //       );
    //     })
    //     .join('\n');

    final items = (data['items'] as List).asMap().entries.where((entry) {
      var list = entry.value['listUnit'] as List;
      var item = entry.value;
      // return item['productId'] == "10020902002" && list.isNotEmpty;
      return list.isNotEmpty; // Optionally filter if listUnit has content
    })
        // .take(10)
        .map((entry) {
      int index = entry.key;
      var item = entry.value;
      String itemName = item['productName'];
      List<Map<String, String>> unitRows = (item['listUnit'] as List)
          .map<Map<String, String>>((u) => {
                "unit": u['unit'] ?? '',
                "unitName": u['unitName'] ?? '',
                "stock": (u['stock'] ?? 0).toString(),
                "stockIn": (u['stockIn'] ?? 0).toString(),
                "stockOut": (u['stockOut'] ?? 0).toString(),
                "balance": (u['balance'] ?? 0).toString(),
              })
          .toList();

      return formatFixedWidthRowMultiUnit(
        "${index + 1}",
        itemName,
        unitRows,
      );
    }).join('\n');

    print(
        "รายการสินค้า${' ' * (21)}STOCK${' ' * (8)}IN${' ' * (8)}OUT${' ' * (7)}BAL");
    print(items);
    Uint8List encoded = await CharsetConverter.encode('TIS-620', items);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encoded));

    // Footer
    String footer = '''
${leftRightText('', '\n\n\n', 61)}
''';
    Uint8List encodedFooter = await CharsetConverter.encode('TIS-620', footer);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedFooter));
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

  @override
  Widget build(BuildContext context) {
    final columns = ['ชื่อ', 'STOCK', 'IN', 'OUT', 'BAL'];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(title: " สต๊อก", icon: Icons.warehouse),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: Styles.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (!_loadingProduct) {
                    // await printBodyBill(receiptData);
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
                          const Icon(
                            Icons.print_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                          Text(
                            " พิมพ์ Stock",
                            style: Styles.headerWhite18(context),
                          ),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : rows.isEmpty
                  ? const Center(child: Text('ไม่มีข้อมูล'))
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownSearchCustom<Group>(
                                label: 'เลือกกลุ่ม',
                                titleText: "เลือกกลุ่ม",
                                fetchItems: (filter) => getShoptype(filter),
                                onChanged: (Group? selected) async {
                                  if (selected != null) {
                                    setState(() {
                                      selectedGroup = selected;

                                      // Filter rows based on selected group
                                      filteredRows = rows.where((row) {
                                        // Assuming the group name is in the first column of each row (row[0])
                                        return row[0].contains(selected.group);
                                      }).toList();
                                    });
                                  }
                                },
                                itemAsString: (Group data) => data.group,
                                itemBuilder: (context, item, isSelected) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          "${item.group}",
                                          style: Styles.black18(context),
                                        ),
                                        selected: isSelected,
                                      ),
                                      Divider(
                                        color: Colors.grey[
                                            200], // Color of the divider line
                                        thickness: 1, // Thickness of the line
                                        indent:
                                            16, // Left padding for the divider line
                                        endIndent:
                                            16, // Right padding for the divider line
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Styles.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedGroup = null;
                                  filteredRows = rows; // Reset to show all
                                });
                              },
                              child: Text(
                                "ล้างตัวกรอง",
                                style: Styles.white24(context),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ReusableTable(
                            columns: columns,
                            rows: filteredRows,
                            itemCodes: stocks
                                .where((stock) => filteredRows.any((row) =>
                                    row[0] ==
                                    stock.productName)) // match ที่โชว์อยู่
                                .map((stock) =>
                                    [stock.productId]) // เก็บแค่ productId
                                .toList(),
                            footer: footerTable,
                            footer2: footerTable2,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
