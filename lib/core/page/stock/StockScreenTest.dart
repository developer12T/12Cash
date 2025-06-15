import 'dart:async';
import 'dart:typed_data';

import 'package:_12sale_app/core/components/Appbar.dart';
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
    _getStockQty();
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
        final allowedUnits = ['CTN', 'PCS'];

        final fetchedStocks = (response.data['data'] as List)
            .map((item) => Stock.fromJson(item))
            .toList();

        setState(() {
          receiptData["items"] = data
              .map((item) {
                final pcsUnit = (item["listUnit"] as List).firstWhere(
                  (unit) => unit["unit"] == "PCS",
                  orElse: () => null,
                );

                if (pcsUnit == null) return null;

                return {
                  "productId": item["productId"],
                  "productName": item["productName"],
                  "listUnit": [
                    {
                      "name": "PCS",
                      "qty":
                          pcsUnit["balance"], // ใช้ค่า balance เป็นจำนวนคงเหลือ
                    }
                  ]
                };
              })
              .where((e) => e != null)
              .toList();
        });

        final fetchedRows = fetchedStocks.map<List<String>>((item) {
          final unitMap = <String, Map<String, int>>{};
          for (var unit in item.listUnit) {
            if (allowedUnits.contains(unit.unit)) {
              unitMap[unit.unit] = {
                'stock': unit.stock,
                'stockIn': unit.stockIn,
                'stockOut': unit.stockOut,
                'balance': unit.balance,
              };
            }
          }

          String joinField(String field) => allowedUnits
              .map((unit) => unitMap[unit]?[field]?.toString() ?? '0')
              .join('/');

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
${centerText('รายการ Stock ณ วันที่ ${DateTime.now().toString().substring(0, 10)}', 69)}
''';
    Uint8List encodedContent = await CharsetConverter.encode('TIS-620', header);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedContent));
  }

  String leftRightText(String left, String right, int width) {
    int space = width - left.length - right.length;
    return left + ' ' * space + right;
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

  Future<void> printBodyBill(Map<String, dynamic> data) async {
    // พิมพ์หัวตาราง
    await printBill("รายการสินค้า".padRight(30) +
        "STOCK".padRight(8) +
        "IN".padRight(6) +
        "OUT".padRight(6) +
        "BAL");

    await printBill("-" * 69);

    String items = (data['items'] as List)
        .map((item) {
          String productName = item['productName'];
          String productId = item['productId'];

          // ดึงเฉพาะ unit ที่เป็น PCS
          final pcsUnit = (item['listUnit'] as List).firstWhere(
            (unit) => unit['unit'] == 'PCS',
            orElse: () => null,
          );

          // ถ้าไม่มี PCS unit → ข้าม
          if (pcsUnit == null) return '';

          final stock = pcsUnit['stock'].toString().padRight(8);
          final stockIn = pcsUnit['stockIn'].toString().padRight(6);
          final stockOut = pcsUnit['stockOut'].toString().padRight(6);
          final balance = pcsUnit['balance'].toString().padRight(6);

          return [
            productName.length > 30
                ? productName.substring(0, 30)
                : productName.padRight(30),
            stock,
            stockIn,
            stockOut,
            balance,
          ].join();
        })
        .where((line) => line.isNotEmpty)
        .join('\n');

    Uint8List encodedItems = await CharsetConverter.encode('TIS-620', items);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedItems));

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
        child: AppbarCustom(title: " สต๊อก", icon: Icons.settings_sharp),
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
                  : ReusableTable(columns: columns, rows: rows),
        ),
      ),
    );
  }
}
