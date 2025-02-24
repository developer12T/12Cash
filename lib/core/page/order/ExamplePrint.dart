import 'dart:typed_data';
import 'package:sprintf/sprintf.dart';
import 'package:_12sale_app/core/page/printer/StingHelper.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'dart:convert';

class ExamplePrint extends StatefulWidget {
  @override
  _ExamplePrintState createState() => _ExamplePrintState();
}

class _ExamplePrintState extends State<ExamplePrint> {
  List<BluetoothInfo> _devices = [];
  bool _connected = false;
  BluetoothInfo? _selectedDevice;
  final int paperWidth = 69;
  final int paperWidthHeader = 76;

  final Map<String, dynamic> receiptData = {
    "customer": {
      "customercode": "VB22600260",
      "customername": "เจ๊โฉลก",
      "address1": "172/1 ต.ศรีมหาโพธิ์",
      "address2": "อ.ปากน้ำ",
      "address3": "จ.สมุทรปราการ",
      "postCode": "10270",
      "taxno": "1234567890123",
      "salecode": "20359-คุณจาง"
    },
    "CUOR": "6707132130012",
    "OAORDT": "06/07/2024",
    "items": [
      {
        "itemname": "น้ำก๋วยเตี๋ยวน้ำข้น ฟ้าไทย 10g x12x20",
        "qtytext": "1",
        "unit": "หีบ",
        "OBSAPR": "1455.00",
        "disamount": "0.00",
        "itemamount": "2910.00"
      },
      {
        "itemname": "ผงปรุงรสหมู ฟ้าไทย 10g x24x10 ชนิดแผง",
        "qtytext": "1",
        "unit": "ซอง",
        "OBSAPR": "762.00",
        "disamount": "0.00",
        "itemamount": "762.00"
      },
      // {
      //   "itemname": "ผงปรุงรสหมู ฟ้าไทย 80g x10x8 แถมช้อนจีน",
      //   "qtytext": "1",
      //   "unit": "ถุง",
      //   "OBSAPR": "0.00",
      //   "disamount": "0.00",
      //   "itemamount": "0.00"
      // },
      // {
      //   "itemname": "ผงปรุงรสหมู ฟ้าไทย 450g x12 แถมชามพลาสติก",
      //   "qtytext": "6",
      //   "unit": "แผง",
      //   "OBSAPR": "0.00",
      //   "disamount": "102.00",
      //   "itemamount": "0.00"
      // },
      // {
      //   "itemname": "ผงปรุงรสหมู ฟ้าไทย 80g x10x8 แถมเห็ด 10g",
      //   "qtytext": "13",
      //   "unit": "กระสอบ",
      //   "OBSAPR": "0.00",
      //   "disamount": "0.00",
      //   "itemamount": "0.00"
      // },
      // {
      //   "itemname": "ผงปรุงรสไก่ ฟ้าไทย 80g x10x8",
      //   "qtytext": "2",
      //   "unit": "แพ็ค",
      //   "OBSAPR": "0.00",
      //   "disamount": "0.00",
      //   "itemamount": "0.00"
      // },
      // {
      //   "itemname": "ผงปรุงรสไก่ ฟ้าไทย 900g x6",
      //   "qtytext": "1",
      //   "unit": "กล่อง",
      //   "OBSAPR": "0.00",
      //   "disamount": "0.00",
      //   "itemamount": "0.00"
      // },
      // {
      //   "itemname": "ผงปรุงรสไก่ ฟ้าไทย 850g x6 แถมรสไก่ 80g",
      //   "qtytext": "7",
      //   "unit": "กระปุก",
      //   "OBSAPR": "0.00",
      //   "disamount": "0.00",
      //   "itemamount": "0.00"
      // }
    ],
    "totaltext": "3672.45",
    "ex_vat": "3431.78",
    "vat": "240.22",
    "totaldis": "0.00",
    "total": "3672.45",
    "OBSMCD": "ลูกนง ปทุมศรี"
  };

  static const String encoding = 'TIS-620';
  final List<String> vowelAndToneMark = [
    '่',
    '้',
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
    'ี๋',
    '์',
    'ำ',
    '.'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPairedDevices();
  }

  Future<void> _fetchPairedDevices() async {
    try {
      final List<BluetoothInfo> pairedDevices =
          await PrintBluetoothThermal.pairedBluetooths;
      setState(() {
        _devices = pairedDevices;
      });
    } catch (e) {
      print("Error fetching paired devices: $e");
    }
  }

  Future<void> _connectToPrinter(BluetoothInfo device) async {
    bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress);
    setState(() {
      _connected = result;
      _selectedDevice = result ? device : null;
    });

    final snackBarText = result
        ? "Connected to ${device.name}"
        : "Failed to connect to ${device.name}";
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(snackBarText)));
  }

  // --------------------------- Printer Test--------------------------
  final List<String> vowelAndToneMark2 = [
    '่', '้', '๊', '๋', 'ั', '็', 'ิ', 'ี', 'ุ', 'ู',
    'ึ', 'ื', '์', 'ำ', '.' // Removed '้ำ' to prevent double counting
  ];
  int _getNoOfUpperLowerChars(String text) {
    int counter = 0;
    for (var char in vowelAndToneMark2) {
      int count = RegExp(RegExp.escape(char)).allMatches(text).length;
      // print("Character: $char, Count: $count"); // Debugging
      counter += count;
    }
    return counter;
  }

  String printTable(String itemName, String qty, String unit, String price,
      String discount, String total) {
    const int nameWidth = 25; // Width for item name

    // Wrap text if it exceeds the width
    List<String> wrapText(String text, int width) {
      List<String> lines = [];
      for (int i = 0; i < text.length; i += width) {
        lines.add(text.substring(
            i, i + width > text.length ? text.length : i + width));
      }
      return lines;
    }

    // Wrap `itemName` if it exceeds the width
    List<String> itemNameLines = wrapText(itemName, nameWidth);

    // Format each line with wrapped itemName using sprintf
    StringBuffer rowBuffer = StringBuffer();
    for (int i = 0; i < itemNameLines.length; i++) {
      // Use sprintf to format the first line
      if (i == 0) {
        rowBuffer.write(
          sprintf(
            '%*s| %*s| %*s| %-*s| %-*s| %-*s',
            [
              nameWidth, itemNameLines[i], // Item name
              3, qty, // Quantity
              7, unit, // Unit
              8, price, // Price
              8, discount, // Discount
              8, total // Total
            ],
          ),
        );
        // rowBuffer.write(sprintf('%*s| %*s| %*s| %-*s| %-*s| %-*s', [
        //   nameWidth, itemNameLines[i], // Item name
        //   3, qty.padLeft(3), // Quantity
        //   7, unit.padLeft(7), // Unit
        //   8, price.padLeft(8), // Price
        //   8, discount.padLeft(8), // Discount
        //   8, total.padLeft(8) // Total
        // ]));
      } else {
        // Subsequent lines only contain the item name
        rowBuffer.write(sprintf('%*s', [nameWidth, itemNameLines[i]]));
      }
      rowBuffer.write('\n'); // New line after each row
    }

    return rowBuffer.toString();
  }

  Future<void> printBetween(String frontText, String backText,
      {int fontSize = 1, bool isBold = false}) async {
    int frontSpaces = paperWidth ~/ 2 + _getNoOfUpperLowerChars(frontText);
    int backSpaces = paperWidth ~/ 2 + _getNoOfUpperLowerChars(backText);

    String formattedText =
        frontText.padRight(frontSpaces) + backText.padLeft(backSpaces);
    await _printText(formattedText, fontSize: fontSize, isBold: isBold);
  }

  String formatFixedWidthRow2(String itemName, String qty, String unit,
      String price, String discount, String total) {
    const int nameWidth = 31;
    const int qtyWidth = 3;
    const int unitWidth = 5;
    const int priceWidth = 8;
    const int discountWidth = 8;
    const int totalWidth = 8;
    List<String> wrapText(String text, int width) {
      List<String> lines = [];
      for (int i = 0; i < text.length; i += width) {
        lines.add(text.substring(
            i, i + width > text.length ? text.length : i + width));
      }
      return lines;
    }

    List<String> itemNameLines = wrapText(itemName, nameWidth);
    for (var i = 0; i < itemNameLines.length; i++) {
      for (var j = itemNameLines[i].length; j < nameWidth; j++) {
        itemNameLines[i] += ' ';
      }
    }

    String formattedQty = qty.padLeft(qtyWidth);
    String formattedUnit =
        unit.padRight(unitWidth + _getNoOfUpperLowerChars(unit));
    String formattedPrice = price.padLeft(priceWidth);
    String formattedDiscount = discount.padLeft(discountWidth);
    String formattedTotal = total.padLeft(totalWidth);
    // Format each line with wrapped itemName
    StringBuffer rowBuffer = StringBuffer();
    for (int i = 0; i < itemNameLines.length; i++) {
      // First line includes all columns, subsequent lines only contain `itemName`
      rowBuffer.write(
          itemNameLines[i].padRight(18 + _getNoOfUpperLowerChars(itemName)));
      if (i == 0) {
        // First line includes other columns
        rowBuffer.write(
            '${'   $formattedQty'}${' $formattedUnit'}${'  $formattedPrice'}${' $formattedDiscount'}${' $formattedTotal'}\n');
      } else {
        // Subsequent lines only contain the item name to create a wrapped effect
        rowBuffer.write('\n');
      }
    }
    return rowBuffer.toString();
  }

  Future<void> _printText(String text,
      {int fontSize = 1, bool isBold = false, int newLine = 1}) async {
    // Convert text to TIS-620 encoding
    Uint8List encodedText = await CharsetConverter.encode(encoding, text);

    // Print the encoded text
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedText));

    // Add newline characters
    // for (int i = 0; i < newLine; i++) {
    //   await PrintBluetoothThermal.writeBytes([10]); // ASCII newline code
    // }
  }

  String leftRightText(String left, String right, int width) {
    int space = width - left.length - right.length;
    return left + ' ' * space + right;
  }

  String centerText(String text, int width) {
    int leftPadding = (width - text.length) ~/ 2;
    return ' ' * leftPadding + text;
  }

  String leftText(String text, int width) {
    return text.padRight(width);
  }

  String rightText(String text, int width) {
    return text.padLeft(width);
  }

  String padThaiText(String text, int length) {
    int extraSpaces = getNoOfUpperLowerChar(text);
    return text.padRight(length + extraSpaces);
  }

  int getNoOfUpperLowerChar(String text) {
    int counter = 0;
    for (var char in text.characters) {
      if (vowelAndToneMark.contains(char)) {
        counter++;
      }
    }
    return counter;
  }

  String centerTextSeparator(String text, int width) {
    int totalPadding = width - text.length;
    int leftPadding = totalPadding ~/ 2;
    int rightPadding = totalPadding - leftPadding;
    return '-' * leftPadding + text + '-' * rightPadding;
  }

  Future<void> printHeaderSeparator() async {
    String header =
        '''\n${centerTextSeparator('ตัดตามรอยปะ', paperWidth)}\n\n\n''';
    Uint8List encodedContent = await CharsetConverter.encode('TIS-620', header);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedContent));
  }

  Future<void> printTest() async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      // await printHeaderSeparator();
      // await printHeaderBill('บิลเงินสด/ใบกำกับภาษี');
      await printBodyBill(receiptData);
      // await printHeaderSeparator();
      // await printHeaderBill('ใบลดหนี้');
      // await printBodyBill(receiptData);
    } else {
      print("Printer is disconnected ($connectionStatus)");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Printer is not connected")),
      );
    }
  }

  Future<void> printHeaderBill(String typeBill) async {
    String header = '''
${centerText('บริษัท วันทูเทรดดิ้ง จำกัด', paperWidthHeader)}
${centerText('58/3 หมู่ที่ 6 ถ.พระประโทน-บ้านแพ้ว', paperWidthHeader)}
${centerText('ต.ตลาดจินดา อ.สามพราน จ.นครปฐม 73110', paperWidthHeader)}
${centerText('โทร.(034) 981-555', paperWidthHeader)}
${centerText('เลขประจำตัวผู้เสียภาษี 0105563063410', paperWidthHeader)}
${centerText('ออกใบกำกับภาษีโดยสำนักงานใหญ่', paperWidthHeader)}
${centerText('($typeBill)', paperWidthHeader)}
${centerText('เอกสารออกเป็นชุด', paperWidthHeader)}''';
    Uint8List encodedContent = await CharsetConverter.encode('TIS-620', header);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedContent));
  }

  Future<void> printBodyBill(Map<String, dynamic> data) async {
//     await printBetween('รหัสลูกค้า ${data['customer']['customercode']}',
//         'เลขที่ ${data['CUOR']}');
//     await printBetween('ชื่อลูกค้า ${data['customer']['customername']}',
//         'วันที่ ${data['OAORDT']}');
//     await printBill(
//         'ที่อยู่ ${data['customer']['address1']} ${data['customer']['address2']} ${data['customer']['address3']}');
//     String body = '''
// รายการสินค้า${' ' * (21)}จำนวน${' ' * (10)}ราคา${' ' * (4)}ส่วนลด${' ' * (6)}รวม
// ''';
//     Uint8List encodedBody = await CharsetConverter.encode('TIS-620', body);
//     await PrintBluetoothThermal.writeBytes(List<int>.from(encodedBody));

    String items = await data['items'].asMap().entries.map((entry) {
      int index = entry.key;
      var item = entry.value;
      // Safely get a substring only if the length is greater than 36
      String itemName = item['itemname'];
      return formatFixedWidthRow2(
        '${(index + 1).toString()} $itemName',
        item['qtytext'],
        item['unit'],
        item['OBSAPR'],
        item['disamount'],
        item['itemamount'],
      );
    }).join('\n');
    Uint8List encodedItems = await CharsetConverter.encode('TIS-620', items);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedItems));

    // double? totalValue = double.tryParse(data['totaltext'] ?? "00.00");
    // String totalText = thaiNumberToWords(totalValue!);
    // await printBetween('รวมมูลค่าสินค้า', data['ex_vat'].toString());
    // await printBetween('ส่วนลด', '0.00');
    // await printBetween('ภาษีมูลค่าเพิ่ม 7%', data['vat'].toString());
    // await printBetween('ส่วนลดท้ายบิล', '00.00');
    // await printBetween('ส่วนลดร้านค้า', data['totaldis'].toString());
    // await printBetween('จำนวนเงินรวมสุทธิ', data['total'].toString());
    // await printBetween("", "($totalText)");
    // String footer = '''
    // ${leftRightText('ผู้รับเงิน 20406-${data['OBSMCD']}', '.........................', 70)}
    // ${leftRightText('', 'ลายเซ็นลูกค้า', 58)}
    // ''';
    // Uint8List encodedFooter = await CharsetConverter.encode('TIS-620', footer);
    // await PrintBluetoothThermal.writeBytes(List<int>.from(encodedFooter));
  }

  String formatItem(String no, String name, String qty, String price,
      String discount, String total) {
    return '$no ${padThaiText(name, 31)} ${padThaiText(qty, 7)} ${rightText(price, 6)} ${rightText(discount, 6)} ${rightText(total, 11)}';
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

  String thaiNumberToWords(double amount) {
    String convert(int number) {
      final values = [
        '',
        'หนึ่ง',
        'สอง',
        'สาม',
        'สี่',
        'ห้า',
        'หก',
        'เจ็ด',
        'แปด',
        'เก้า'
      ];
      final places = ['', 'สิบ', 'ร้อย', 'พัน', 'หมื่น', 'แสน', 'ล้าน'];
      final exceptions = {
        'หนึ่งสิบ': 'สิบ',
        'สองสิบ': 'ยี่สิบ',
        'สิบหนึ่ง': 'สิบเอ็ด'
      };

      String output = '';
      var numStr = number.toString().split('').reversed.toList();

      for (int i = 0; i < numStr.length; i++) {
        if (i % 6 == 0 && i > 0) output = places[6] + output;
        if (numStr[i] != '0')
          output = values[int.parse(numStr[i])] + places[i % 6] + output;
      }

      exceptions.forEach((search, replace) {
        output = output.replaceAll(search, replace);
      });

      return output;
    }

    List<String> parts = amount.toStringAsFixed(2).split('.');
    String baht = convert(int.parse(parts[0]));
    String satang = convert(int.parse(parts[1]));
    String output = amount < 0 ? 'ลบ' : '';
    output += baht.isNotEmpty ? '$bahtบาท' : '';
    output += satang.isNotEmpty ? '$satangสตางค์' : 'ถ้วน';

    return output.isEmpty ? 'ศูนย์บาทถ้วน' : output;
  }

  // Convert a UTF-8 string to Windows-874 encoded bytes

  Future<void> _printUtf8Text(String text,
      {bool isBold = false, int size = 1}) async {
    // final encodedText = utf8.encode(text); // Convert text to UTF-8 bytes
    Uint8List encodedText = await CharsetConverter.encode('TIS-620', text);
    await PrintBluetoothThermal.writeBytes(
        List<int>.from(encodedText)); // Ensure List<int> type
  }

  Future<void> _printItemRowUtf8(String product, String quantity, String price,
      String discount, String total) async {
    String formattedRow =
        "$product${_alignTextLeftRight(quantity, 10)}${_alignTextLeftRight(price, 100)}${_alignTextLeftRight(discount, 100)}$total\n";
    // final encodedText = utf8.encode(formattedRow); // Encode row to UTF-8 bytes
    Uint8List encodedText =
        await CharsetConverter.encode('TIS-620', formattedRow);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedText));
  }

  String _alignTextLeftRight(String text, int width) {
    return text.padRight(width);
  }

  Future<void> _disconnectPrinter() async {
    bool result = await PrintBluetoothThermal.disconnect;
    print("Printer disconnected ($result)");
    setState(() {
      _connected = !result;
      _selectedDevice = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Printer disconnected")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth Printers"),
      ),
      body: Column(
        children: [
          Expanded(
            child: _devices.isNotEmpty
                ? ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        title: Text(device.name ?? "Unknown Device"),
                        subtitle: Text(device.macAdress),
                        trailing: _connected && _selectedDevice == device
                            ? Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () => _connectToPrinter(device),
                      );
                    },
                  )
                : Center(child: Text("No paired devices found")),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text("Print Test"),
                  onPressed: _connected ? printTest : null,
                ),
                ElevatedButton(
                  child: Text("Test"),
                  onPressed: () {
                    print(
                        " ${_getNoOfUpperLowerChars('น้ำก๋วยเตี๋ยวน้ำข้น ฟ้าไทย 10g x12x20')}");
                    print(
                        " ${_getNoOfUpperLowerChars('ผงปรุงรสหมู ฟ้าไทย 10g x24x10 ชนิดแผง')}");
                  },
                ),
                ElevatedButton(
                  child: Text("Disconnect"),
                  onPressed: _connected ? _disconnectPrinter : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
