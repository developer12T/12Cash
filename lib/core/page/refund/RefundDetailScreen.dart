import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/button/ShowPhotoButton.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/printer/ManagePrinterScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';

import 'package:_12sale_app/data/models/refund/RefundDetail.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:toastification/toastification.dart';

class RefundDetailScreen extends StatefulWidget {
  final orderId;
  const RefundDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<RefundDetailScreen> createState() => _RefundDetailScreenState();
}

class _RefundDetailScreenState extends State<RefundDetailScreen> {
  // Sale? saleDetail;
  // Store? storeDetail;

  RefundDetail? refundDetails;
  List<Product> listProduct = [];
  List<Product> listPromotionItems = [];
  List<Product> listPromotions = [];
  List<ListImage> listImage = [];

  List<Product> listProductRefund = [];
  List<Product> listProductChange = [];

  // List<Product> listProduct = [];
  // List<Promotion> listPromotions = [];
  // List<PromotionListItem> listPromotionItems = [];
  // List<ListImage> listImage = [];

  double subtotal = 0;
  double discount = 0;
  double discountProduct = 0;
  double vat = 0;
  double totalExVat = 0;
  double total = 0;
  bool _isCreateOrderEnabled = false;
//  Map<String, dynamic> itemPr = [];

  @override
  void initState() {
    super.initState();
    // requestPermissions();
    // _getCart();
    _getOrderDetail();
    _fetchPairedDevices();
    _cartScrollController.addListener(_handleInnerScroll);
    _promotionScrollController.addListener(_handleInnerScroll2);
    _outerController.addListener(_onScroll);
  }
  // Scroll Bar

  final ScrollController _cartScrollController = ScrollController();
  final ScrollController _promotionScrollController = ScrollController();
  ScrollController _outerController = ScrollController();
  bool _isInnerAtTop = true;
  bool _isInnerAtBottom = false;

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

  Future<void> _updateStatus() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/refund/updateStatus',
        method: 'POST',
        body: {
          "orderId": "${widget.orderId}",
          "status": "canceled"
          // 'pending', 'completed', 'canceled', 'rejected'
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
            "ยกเลิกการคืนสินค้าสำเร็จ",
            style: Styles.green18(context),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(
              index: 3,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error $e");
    }
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

  bool _loadOrderDetail = false;

  Future<void> _getOrderDetail() async {
    ApiService apiService = ApiService();
    await apiService.init();
    var response = await apiService.request(
      endpoint: 'api/cash/refund/detail/${widget.orderId}',
      method: 'GET',
    );

    print(response.data);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      setState(() {
        refundDetails = RefundDetail.fromJson(data);
        // saleDetail = Sale.fromJson(response.data['data'][0]['sale']);
        receiptData['customer']['customercode'] = refundDetails?.store.storeId;
        receiptData['customer']['customername'] = refundDetails?.store.name;
        receiptData['customer']['address1'] = refundDetails?.store.address;
        receiptData['customer']['salecode'] = refundDetails?.sale.saleCode;
        receiptData['customer']['taxno'] = refundDetails?.store.taxId;
        receiptData['CUOR'] = widget.orderId;
        receiptData['OAORDT'] = DateFormat('dd/MM/yyyy').format(DateTime.now());

        receiptData['totalRefundExVat'] =
            "${refundDetails?.totalRefundExVat.toStringAsFixed(2)}";
        receiptData['totalRefundVat'] =
            "${refundDetails?.totalRefundVat.toStringAsFixed(2)}";
        receiptData['totalRefund'] =
            "${refundDetails?.totalRefund.toStringAsFixed(2)}";
        receiptData['totalChangeExVat'] =
            "${refundDetails?.totalChangeExVat.toStringAsFixed(2)}";
        receiptData['totalChangeVat'] =
            "${refundDetails?.totalChangeVat.toStringAsFixed(2)}";
        receiptData['totalChange'] =
            "${refundDetails?.totalChange.toStringAsFixed(2)}";
        receiptData['totalDiff'] =
            "${refundDetails?.totalDiff.toStringAsFixed(2)}";

        // receiptData['totalChange'] =
        //     "${refundDetails?.totalChange.toStringAsFixed(2)}";
        // receiptData['totalRefund'] =
        //     "${refundDetails?.totalRefund.toStringAsFixed(2)}";
        // receiptData['vat'] = "${refundDetails?.vat.toStringAsFixed(2)}";
        // receiptData['totalExVat'] =
        //     "${refundDetails?.totalExVat.toStringAsFixed(2)}";
        // receiptData['total'] = "${refundDetails?.total.toStringAsFixed(2)}";
        receiptData['OBSMCD'] = "${refundDetails?.sale.name}";
        // receiptData['totaltext'] = "${refundDetails?.total.toStringAsFixed(2)}";
      });
      for (var element in refundDetails!.listProductRefund) {
        listProductRefund.add(element);
      }
      for (var element in refundDetails!.listProductChange) {
        listProductChange.add(element);
      }
      for (var element in refundDetails!.listImage) {
        listImage.add(element);
      }
      receiptData["items"] = listProductChange
          .map((item) => {
                "name": item.name,
                "qty": item.qty.toStringAsFixed(0),
                "unit": item.unitName,
                "price": item.price.toStringAsFixed(2),
                "discount": "0.00",
                "discountProduct": item.netTotal.toStringAsFixed(2)
              })
          .toList();
      receiptData["refundItems"] = listProductRefund
          .map((item) => {
                "name": item.name,
                "condition": item.condition,
                "qty": item.qty.toStringAsFixed(0),
                "unit": item.unitName,
                "price": item.price.toStringAsFixed(2),
                "discount": "0.00",
                "discountProduct": item.netTotal.toStringAsFixed(2)
              })
          .toList();
    }

    context.loaderOverlay.hide();
  }

  // Future<void> _getOrderDetail() async {
  //   try {
  //     print("Order ID : ${widget.orderId}");
  //     ApiService apiService = ApiService();
  //     await apiService.init();
  //     var response = await apiService.request(
  //       endpoint: 'api/cash/refund/detail/${widget.orderId}',
  //       method: 'GET',
  //     );
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = response.data['data'][0]['listProduct'];
  //       final List<dynamic> images = response.data['data'][0]['listImage'];
  //       final List<dynamic> prData = response.data['data'][0]['listPromotions'];
  //       setState(() {
  //         saleDetail = Sale.fromJson(response.data['data'][0]['sale']);
  //         storeDetail = Store.fromJson(response.data['data'][0]['store']);
  //         listProduct = data.map((item) => Product.fromJson(item)).toList();
  //         listImage = images.map((item) => ListImage.fromJson(item)).toList();
  //         listPromotions =
  //             prData.map((item) => Promotion.fromJson(item)).toList();

  //         subtotal = response.data['data'][0]['subtotal'].toDouble();
  //         discount = response.data['data'][0]['discount'].toDouble();
  //         discountProduct =
  //             response.data['data'][0]['discountProduct'].toDouble();
  //         vat = response.data['data'][0]['vat'].toDouble();
  //         totalExVat = response.data['data'][0]['totalExVat'].toDouble();
  //         total = response.data['data'][0]['total'].toDouble();
  //         // Map cartList to receiptData["items"]
  //         receiptData['customer']['customercode'] = storeDetail?.storeId;
  //         receiptData['customer']['customername'] = storeDetail?.name;
  //         receiptData['customer']['address1'] = storeDetail?.address;
  //         receiptData['customer']['salecode'] = storeDetail?.storeId;
  //         receiptData['customer']['customercode'] = storeDetail?.storeId;
  //         receiptData['customer']['taxno'] = storeDetail?.taxId;
  //         receiptData['CUOR'] = widget.orderId;
  //         receiptData['OAORDT'] =
  //             DateFormat('dd/MM/yyyy').format(DateTime.now());

  //         receiptData['totaltext'] =
  //             "${response.data['data'][0]['subtotal'].toStringAsFixed(2)}";
  //         receiptData['ex_vat'] =
  //             "${response.data['data'][0]['totalExVat'].toStringAsFixed(2)}";
  //         receiptData['vat'] =
  //             "${response.data['data'][0]['vat'].toStringAsFixed(2)}";
  //         receiptData['discountProduct'] =
  //             "${response.data['data'][0]['discountProduct'].toStringAsFixed(2)}";
  //         receiptData['discount'] =
  //             "${response.data['data'][0]['discount'].toStringAsFixed(2)}";
  //         receiptData['total'] =
  //             "${response.data['data'][0]['total'].toStringAsFixed(2)}";
  //         receiptData['OBSMCD'] = "${saleDetail?.name}";
  // receiptData['taxno'] = "${storeDetail?.taxId}";

  //         receiptData["items"] = listProduct
  //             .map((cartItem) => {
  //                   "name": cartItem.name,
  //                   "qty": cartItem.qty.toString(),
  //                   "unit": cartItem.unitName,
  //                   "price": cartItem.price.toStringAsFixed(2),
  //                   "discount": cartItem.discount.toStringAsFixed(2),
  //                   "discountProduct": cartItem.netTotal.toStringAsFixed(2)
  //                 })
  //             .toList();
  //         for (var promotion in listPromotions) {
  //           for (var item in promotion.listPromotion) {
  //             listPromotionItems.add(item);
  //           }
  //         }

  //         for (var promotion in listPromotions) {
  //           for (var item in promotion.listPromotion) {
  //             receiptData["items"].add({
  //               "name": item.name,
  //               "qty": item.qty.toString(),
  //               "unit": item.unitName,
  //               "price": "0.00",
  //               "discount": "0.00",
  //               "discountProduct": "0.00"
  //             });
  //           }
  //         }
  //       });
  //       print(receiptData);
  //       Timer(const Duration(milliseconds: 500), () {
  //         context.loaderOverlay.hide();
  //         if (mounted) {
  //           setState(() {
  //             _loadOrderDetail = false;
  //           });
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     print("Error $e");
  //   }
  // }

  // Bluetooth Connect
  List<BluetoothInfo> _devices = [];
  bool _connected = false;
  BluetoothInfo? _selectedDevice;
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
    "items": [],
    "refundItems": [],
    "totalRefundExVat": 0.0,
    "totalRefundVat": 0.0,
    "totalRefund": 0.0,
    "totalChangeExVat": 0.0,
    "totalChangeVat": 0.0,
    "totalChange": 0.0,
    "totalDiff": 0.0,
    "totaltextChange": "",
    "totaltextRefund": "",
    "totaltextDiff": "",
    "OBSMCD": ""
  };

  Future<void> _fetchPairedDevices() async {
    try {
      // _disconnectPrinter();
      final List<BluetoothInfo> pairedDevices =
          await PrintBluetoothThermal.pairedBluetooths;
      print(User.devicePrinter.macAdress);
      print(User.devicePrinter.name);
      print(User.connectPrinter);
      setState(() {
        _devices = pairedDevices;
        User.devicePrinter = _devices[0];
      });
      if (!User.connectPrinter) {
        await _connectToPrinter(User.devicePrinter);
      }
    } catch (e) {
      print("Error fetching paired devices: $e");
    }
  }

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

  // --------------------------- Printer Test--------------------------

  final List<String> combinedCharacters = ['ี๋'];

  // int _getNoOfUpperLowerChars(String text) {
  //   int counter = 0;

  //   // First, count combined characters
  //   for (var combinedChar in combinedCharacters) {
  //     if (text.contains(combinedChar)) {
  //       counter += 1;
  //       text = text.replaceAll(combinedChar,
  //           ''); // Remove the combined character to avoid double-counting
  //     }
  //   }

  //   // Then, count individual characters
  //   for (var char in vowelAndToneMark2) {
  //     int count = RegExp(RegExp.escape(char)).allMatches(text).length;
  //     counter += count;
  //   }

  //   return counter;
  // }

  Future<void> printBetween(String frontText, String backText,
      {int fontSize = 1, bool isBold = false}) async {
    int frontSpaces = paperWidth ~/ 2 + _getNoOfUpperLowerChars(frontText);
    int backSpaces = paperWidth ~/ 2 + _getNoOfUpperLowerChars(backText);

    String formattedText =
        frontText.padRight(frontSpaces) + backText.padLeft(backSpaces);
    await _printText(formattedText, fontSize: fontSize, isBold: isBold);
  }

  String formatFixedWidthRowRefund(
    String num,
    String itemName,
    String qty,
    String unit,
    String price,
    String discount,
    String total,
    // String condition,
  ) {
    const int numWidth = 3;
    const int nameWidth = 25;
    const int qtyWidth = 3;
    const int unitWidth = 5;
    const int priceWidth = 8;
    const int discountWidth = 8;
    const int totalWidth = 9;

    List<String> wrapText(String text, int width) {
      List<String> lines = [];
      for (int i = 0; i < text.length; i += width) {
        lines.add(text.substring(
            i, i + width > text.length ? text.length : i + width));
      }
      return lines;
    }

    List<String> itemNameLines = wrapText(itemName, nameWidth);

    // Ensure all wrapped lines are properly padded
    itemNameLines = itemNameLines.map((line) {
      return line.padRight(nameWidth + _getNoOfUpperLowerChars(line));
    }).toList();
    String formattedNum = num.padRight(numWidth);
    String formattedQty = qty.padLeft(qtyWidth);
    String formattedUnit =
        unit.padRight(unitWidth + _getNoOfUpperLowerChars(unit));
    String formattedPrice = price.padLeft(priceWidth);
    String formattedDiscount = discount.padLeft(discountWidth);
    String formattedTotal = total.padLeft(totalWidth);

    StringBuffer rowBuffer = StringBuffer();
    for (int i = 0; i < itemNameLines.length; i++) {
      if (i == 0) {
        rowBuffer.write(formattedNum);
      }
      if (i > 0) {
        rowBuffer.write(''.padRight(numWidth));
      }

      rowBuffer.write(itemNameLines[i]);

      if (i == 0) {
        // First line includes all columns
        rowBuffer.write(
            '   $formattedQty $formattedUnit  $formattedPrice $formattedDiscount $formattedTotal\n');
      } else {
        // Subsequent lines only contain the wrapped item name

        // rowBuffer.write('\n');
      }
    }

    return rowBuffer.toString();
  }

  String formatFixedWidthRow2(String num, String itemName, String qty,
      String unit, String price, String discount, String total) {
    const int numWidth = 3;
    const int nameWidth = 25;
    const int qtyWidth = 3;
    const int unitWidth = 5;
    const int priceWidth = 8;
    const int discountWidth = 8;
    const int totalWidth = 9;

    List<String> wrapText(String text, int width) {
      List<String> lines = [];
      for (int i = 0; i < text.length; i += width) {
        lines.add(text.substring(
            i, i + width > text.length ? text.length : i + width));
      }
      return lines;
    }

    List<String> itemNameLines = wrapText(itemName, nameWidth);

    // Ensure all wrapped lines are properly padded
    itemNameLines = itemNameLines.map((line) {
      return line.padRight(nameWidth + _getNoOfUpperLowerChars(line));
    }).toList();
    String formattedNum = num.padRight(numWidth);
    String formattedQty = qty.padLeft(qtyWidth);
    String formattedUnit =
        unit.padRight(unitWidth + _getNoOfUpperLowerChars(unit));
    String formattedPrice = price.padLeft(priceWidth);
    String formattedDiscount = discount.padLeft(discountWidth);
    String formattedTotal = total.padLeft(totalWidth);

    StringBuffer rowBuffer = StringBuffer();
    for (int i = 0; i < itemNameLines.length; i++) {
      if (i == 0) {
        rowBuffer.write(formattedNum);
      }
      if (i > 0) {
        rowBuffer.write(''.padRight(numWidth));
      }

      rowBuffer.write(itemNameLines[i]);

      if (i == 0) {
        // First line includes all columns
        rowBuffer.write(
            '   $formattedQty $formattedUnit  $formattedPrice $formattedDiscount $formattedTotal\n');
      } else {
        // Subsequent lines only contain the wrapped item name

        // rowBuffer.write('\n');
      }
    }

    return rowBuffer.toString();
  }

  int _getNoOfUpperLowerChars(String text) {
    int counter =
        text.split('').where((char) => vowelAndToneMark.contains(char)).length;
    return counter;
  }

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

  // int _getNoOfUpperLowerChars(String text) {
  //   int counter = 0;
  //   for (var char in vowelAndToneMark) {
  //     counter += char.allMatches(text).length;
  //   }
  //   return counter;
  // }

  // String formatFixedWidthRow2(String itemName, String qty, String unit,
  //     String price, String discount, String total) {
  //   const int nameWidth = 31;
  //   const int qtyWidth = 3;
  //   const int unitWidth = 5;
  //   const int priceWidth = 8;
  //   const int discountWidth = 8;
  //   const int totalWidth = 8;

  //   List<String> wrapText(String text, int width) {
  //     List<String> lines = [];
  //     for (int i = 0; i < text.length; i += width) {
  //       lines.add(text.substring(
  //           i, i + width > text.length ? text.length : i + width));
  //     }
  //     return lines;
  //   }

  //   List<String> itemNameLines = wrapText(itemName, nameWidth);
  //   for (var i = 0; i < itemNameLines.length; i++) {
  //     while (itemNameLines[i].length < nameWidth) {
  //       itemNameLines[i] += ' ';
  //     }
  //   }

  //   String formattedQty = qty.padLeft(qtyWidth);
  //   String formattedUnit =
  //       unit.padRight(unitWidth + _getNoOfUpperLowerChars(unit));
  //   String formattedPrice = price.padLeft(priceWidth);
  //   String formattedDiscount = discount.padLeft(discountWidth);
  //   String formattedTotal = total.padLeft(totalWidth);

  //   StringBuffer rowBuffer = StringBuffer();
  //   for (int i = 0; i < itemNameLines.length; i++) {
  //     rowBuffer.write(itemNameLines[i].padRight(nameWidth));

  //     if (i == 0) {
  //       rowBuffer.write(
  //           ' $formattedQty  $formattedUnit  $formattedPrice  $formattedDiscount  $formattedTotal\n');
  //     } else {
  //       rowBuffer.write('\n');
  //     }
  //   }
  //   return rowBuffer.toString();
  // }

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

  String leftText(String text, int width) {
    return text.padRight(width);
  }

  String rightText(String text, int width) {
    return text.padLeft(width);
  }

  String padThaiText(String text, int length) {
    int extraSpaces = 0;
    return text.padRight(length + extraSpaces);
  }

  String centerTextSeparator(String text, int width) {
    int totalPadding = width - text.length;
    int leftPadding = totalPadding ~/ 2;
    int rightPadding = totalPadding - leftPadding;
    return '-' * leftPadding + text + '-' * rightPadding;
  }

  String centerText(String text, int width) {
    int leftPadding =
        (width - text.length + _getNoOfUpperLowerChars(text)) ~/ 2;
    return ' ' * leftPadding + text;
  }

  Future<void> printHeaderSeparator2() async {
    String header = '${centerTextSeparator('', paperWidth)}';
    Uint8List encodedContent = await CharsetConverter.encode('TIS-620', header);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedContent));
  }

  Future<void> printHeaderBill(String typeBill) async {
    String header = '''
${centerText('บริษัท วันทูเทรดดิ้ง จำกัด', 69)}
${centerText('58/3 หมู่ที่ 6 ถ.พระประโทน-บ้านแพ้ว', 69)}
${centerText('ต.ตลาดจินดา อ.สามพราน จ.นครปฐม 73110', 69)}
${centerText('โทร.(034) 981-555', 69)}
${centerText('เลขประจำตัวผู้เสียภาษี 0105563063410', 69)}
${centerText('ออกใบกำกับภาษีโดยสำนักงานใหญ่', 69)}
${centerText('($typeBill)', 69)}
${centerText('เอกสารออกเป็นชุด', 69)}
''';
//     String header = '''
// ${centerText('บริษัท วันทูเทรดดิ้ง จำกัด', paperWidthHeader)}
// ${centerText('58/3 หมู่ที่ 6 ถ.พระประโทน-บ้านแพ้ว', paperWidthHeader)}
// ${centerText('ต.ตลาดจินดา อ.สามพราน จ.นครปฐม 73110', paperWidthHeader)}
// ${centerText('โทร.(034) 981-555', paperWidthHeader)}
// ${centerText('เลขประจำตัวผู้เสียภาษี 0105563063410', paperWidthHeader)}
// ${centerText('ออกใบกำกับภาษีโดยสำนักงานใหญ่', paperWidthHeader)}
// ${centerText('($typeBill)', paperWidthHeader)}
// ${centerText('เอกสารออกเป็นชุด', paperWidthHeader)}''';
    Uint8List encodedContent = await CharsetConverter.encode('TIS-620', header);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedContent));
  }

  Future<void> printBodyBillRefund(Map<String, dynamic> data) async {
    await printBetween('รหัสลูกค้า ${data['customer']['customercode']}',
        'เลขที่ ${data['CUOR']}');
    await printBetween('ชื่อลูกค้า ${data['customer']['customername']}',
        'วันที่ ${data['OAORDT']}');
    await printBill(
        'ที่อยู่ ${data['customer']['address1']} ${data['customer']['address2']} ${data['customer']['address3']}');
    await printBill('เลขประจำตัวผู้เสียภาษี ${data['customer']['taxno']}');
    await printBill('สินค้าที่รับคืนมาจากร้านค้า');
    await printHeaderSeparator2();
    await printBill(
        "\nรายการสินค้า${' ' * (21)}จำนวน${' ' * (10)}ราคา${' ' * (4)}ส่วนลด${' ' * (7)}รวม");
    String items = await data['refundItems'].asMap().entries.map((entry) {
      int index = entry.key;
      var item = entry.value;
      // Safely get a substring only if the length is greater than 36
      String itemName = "${item['name']}";
      return formatFixedWidthRowRefund(
        "${(index + 1).toString()}",
        '$itemName',
        item['qty'],
        item['unit'],
        item['price'],
        item['discount'],
        item['discountProduct'],
        // item['condition'],
      );
    }).join('\n');
    Uint8List encodedItems = await CharsetConverter.encode('TIS-620', items);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedItems));

    double? totalValue = double.tryParse(data['totalRefund'] ?? "0");
    String totalText = thaiNumberToWords(totalValue!);

    String? totalRefundExVat =
        " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['totalRefundExVat'] ?? "0.00"))}";
    String? totalRefundVat =
        " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['totalRefundVat'] ?? "0.00"))}";
    String? totalRefund =
        " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['totalRefund'] ?? "0.00"))}";

    await printBetween('รวมมูลค่าสินค้ารับคืน', totalRefundExVat);
    await printBetween('ภาษีมูลค่าเพิ่ม 7%', totalRefundVat);
    await printBetween('จำนวนเงินรวมสุทธิ', totalRefund);
    await printBetween("", "($totalText)");
    String footer = '''\n\n
    ${leftRightText('ผู้รับเงิน ${data['OBSMCD']}', '.........................', 70)}
    ${leftRightText('', 'ลายเซ็นลูกค้า', 61)}
    \n\n\n''';
    Uint8List encodedFooter = await CharsetConverter.encode('TIS-620', footer);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedFooter));
  }

  Future<void> printBodyBill(Map<String, dynamic> data) async {
    await printBetween('รหัสลูกค้า ${data['customer']['customercode']}',
        'เลขที่ ${data['CUOR']}');
    await printBetween('ชื่อลูกค้า ${data['customer']['customername']}',
        'วันที่ ${data['OAORDT']}');
    await printBill(
        'ที่อยู่ ${data['customer']['address1']} ${data['customer']['address2']} ${data['customer']['address3']}');
    await printBill('เลขประจำตัวผู้เสียภาษี ${data['customer']['taxno']}');
    await printBill('สินค้าที่เปลี่ยนให้ร้านค้า');
    await printHeaderSeparator2();
    await printBill(
        "\nรายการสินค้า${' ' * (21)}จำนวน${' ' * (10)}ราคา${' ' * (4)}ส่วนลด${' ' * (7)}รวม");
    String items = await data['items'].asMap().entries.map((entry) {
      int index = entry.key;
      var item = entry.value;
      // Safely get a substring only if the length is greater than 36
      String itemName = item['name'];
      return formatFixedWidthRow2(
        "${(index + 1).toString()}",
        '$itemName',
        item['qty'],
        item['unit'],
        item['price'],
        item['discount'],
        item['discountProduct'],
      );
    }).join('\n');
    Uint8List encodedItems = await CharsetConverter.encode('TIS-620', items);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedItems));

    String? totalChangeExVat =
        " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['totalChangeExVat'] ?? "0.00"))}";
    String? totalChangeVat =
        " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['totalChangeVat'] ?? "0.00"))}";
    String? totalChange =
        " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['totalChange'] ?? "0.00"))}";
    String? totalDiff =
        " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['totalDiff'] ?? "0.00"))}";

    // double? totalValue = double.tryParse(data['totaltext'] ?? "00.00");
    // String totalText = thaiNumberToWords(totalValue!);
    double? totalValueR = double.tryParse(data['totalChange'] ?? "0.00");
    String totalTextR = thaiNumberToWords(totalValueR!);

    double? totalValueD = double.tryParse(data['totalDiff'] ?? "0.00");
    String totalTextD = thaiNumberToWords(totalValueD!);

    await printBetween('รวมมูลค่าสินค้ารับคืน', totalChangeExVat);
    await printBetween('ภาษีมูลค่าเพิ่ม 7%', totalChangeVat);
    await printBetween('จำนวนเงินรวมสุทธิ', totalChange);
    await printBetween("", "($totalTextR)\n");
    await printBetween('ค่าส่วนต่างที่ต้องชำระ', totalDiff);
    await printBetween("", "($totalTextD)");

    // String? totalChange =
    //     " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['totalChange'] ?? "00.00"))}";
    // String? totalRefund =
    //     " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['totalRefund'] ?? "00.00"))}";
    // String? vat =
    //     " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['vat'] ?? "00.00"))}";
    // String? totalExVat =
    //     " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['totalExVat'] ?? "00.00"))}";
    // String? totalCurrency =
    //     " ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(double.tryParse(data['total'] ?? "00.00"))}";

    // await printBetween('รวมรับคืนสินค้า', totalChange);
    // await printBetween('รวมรับเปลี่ยนสินค้า', totalRefund);
    // await printBetween('ภาษีมูลค่าเพิ่ม 7%', vat);
    // await printBetween(
    //     'รวมมูลค่าส่วนต่างก่อนหัก ภาษีมูลค่าเพิ่ม 7%', totalExVat);
    // await printBetween('จำนวนเงินรวมสุทธิ', totalCurrency);
    // await printBetween("", "($totalText)");
    String footer = '''
    ${leftRightText('ผู้รับเงิน ${data['OBSMCD']}', '.........................', 70)}
    ${leftRightText('', 'ลายเซ็นลูกค้า\n\n\n', 61)}
    ''';
    Uint8List encodedFooter = await CharsetConverter.encode('TIS-620', footer);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedFooter));
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

  Future<void> printHeaderSeparator() async {
    String header =
        '''\n${centerTextSeparator('ตัดตามรอยปะ', paperWidth)}\n\n\n''';
    Uint8List encodedContent = await CharsetConverter.encode('TIS-620', header);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedContent));
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

  Future<void> printTest() async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      await printHeaderBill('ใบลดหนี้');
      await printBodyBillRefund(receiptData);
      await printHeaderSeparator();
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
      // print("Printer is disconnected ($connectionStatus)");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Printer is not connected")),
      // );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _cartScrollController.removeListener(_handleInnerScroll);
    _promotionScrollController.removeListener(_handleInnerScroll2);
    _cartScrollController.dispose();
    _promotionScrollController.dispose();
    _outerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton(
      //   heroTag: 'printerScreen',
      //   shape: CircleBorder(),
      //   backgroundColor: Styles.primaryColor,
      //   child: Icon(
      //     Icons.print_rounded,
      //     color: Styles.white,
      //   ),
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => ManagePrinterScreen(),
      //       ),
      //     );
      //   },
      // ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " รายละเอียดการคืนสินค้า",
          icon: FontAwesomeIcons.clipboardList,
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
      body: NotificationListener<ScrollNotification>(
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
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          controller: _outerController,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.735, // Set height
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  // "${widget.storeId}",
                                  "${refundDetails?.store.name} ${refundDetails?.store.storeId}",
                                  style: Styles.black24(context),
                                ),
                                listImage.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () async {
                                          if (listImage.isNotEmpty) {
                                            // context.loaderOverlay.show();
                                            await showDialog(
                                              context: context,
                                              builder: (_) => ImageDialog(
                                                imagePath: listImage.isNotEmpty
                                                    ? listImage
                                                        .firstWhere((i) =>
                                                            i.type == 'slip')
                                                        .path
                                                    : '',
                                                checkNetwork: true,
                                              ),
                                            ).then((_) {
                                              // context.loaderOverlay.hide();
                                            });
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
                                                "ไม่มีรูปภาพ",
                                                style: Styles.red18(context),
                                              ),
                                            );
                                          }
                                        },
                                        child: Icon(
                                          Icons.image,
                                          size: 30,
                                        ),
                                      )
                                    : SizedBox()
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  // "${widget.storeId}",
                                  "เลขที่ผู้เสียภาษี : ${refundDetails?.store.taxId}",
                                  style: Styles.black18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  // "${widget.storeId}",
                                  "เบอร์โทรศัพท์ : ${refundDetails?.store.tel}",
                                  style: Styles.black18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "ที่อยู่การจัดส่ง",
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
                                          side:
                                              BorderSide.none, // Remove border
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                    // " ${widget.storeAddress}",
                                                    "${refundDetails?.store.address}",
                                                    style:
                                                        Styles.grey18(context),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  // "${widget.storeId}",
                                  "พนักงานขาย : ${refundDetails?.sale.name}",
                                  style: Styles.black24(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  // "${widget.storeId}",
                                  "เบอร์โทรศัพท์ : ${refundDetails?.sale.tel}",
                                  style: Styles.black18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  // "${widget.storeId}",
                                  "หมายเหตุ : ${refundDetails?.note}",
                                  style: Styles.black18(context),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    BoxShadowCustom(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: screenHeight * 0.395,
                          // color: Colors.red,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "รายการคืน",
                                      style: Styles.black18(context),
                                    ),
                                    Text(
                                      "จำนวน ${refundDetails?.listProductRefund.length} รายการ",
                                      style: Styles.black18(context),
                                    ),
                                  ],
                                ),
                                Expanded(
                                    child: Scrollbar(
                                  controller: _cartScrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  radius: Radius.circular(16),
                                  thickness: 10,
                                  child: ListView.builder(
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    controller: _cartScrollController,
                                    itemCount: listProductRefund.length,
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
                                                  '${ApiService.apiHost}/images/products/${listProductRefund[index].id}.webp',
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
                                                  padding: const EdgeInsets.all(
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
                                                              listProductRefund[
                                                                      index]
                                                                  .name,
                                                              style: Styles
                                                                  .black16(
                                                                      context),
                                                              softWrap: true,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .visible,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              "${listProductRefund[index].condition == "damaged" ? "คืนเสีย" : "คืนดี"}",
                                                              style: Styles
                                                                  .black16(
                                                                      context),
                                                              textAlign:
                                                                  TextAlign.end,
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
                                                                    'จำนวน : ${listProductRefund[index].qty.toStringAsFixed(0)} ${listProductRefund[index].unit}',
                                                                    style: Styles
                                                                        .black16(
                                                                            context),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'ราคา : ${listProductRefund[index].price}',
                                                                    style: Styles
                                                                        .black16(
                                                                            context),
                                                                  ),
                                                                ],
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
                                  ),
                                ))
                              ],
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
              height: screenHeight * 0.4,
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
                                      "รายการเปลี่ยน",
                                      style: Styles.black18(context),
                                    ),
                                    Text(
                                      "จำนวน ${listProductChange.length} รายการ",
                                      style: Styles.black18(context),
                                    ),
                                  ],
                                ),

                                Expanded(
                                  child: Scrollbar(
                                    controller: _promotionScrollController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    radius: Radius.circular(16),
                                    thickness: 10,
                                    child: ListView.builder(
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      controller: _promotionScrollController,
                                      itemCount: listProductChange.length,
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
                                                    '${ApiService.apiHost}/images/products/${listProductChange[index].id}.webp',
                                                    width: screenWidth / 8,
                                                    height: screenWidth / 8,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
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
                                                                listProductChange[
                                                                        index]
                                                                    .name,
                                                                style: Styles
                                                                    .black16(
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
                                                                      'จำนวน : ${listProductChange[index].qty.toStringAsFixed(0)} ${listProductChange[index].unit}',
                                                                      style: Styles
                                                                          .black16(
                                                                              context),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'ราคา : ${listProductChange[index].price}',
                                                                      style: Styles
                                                                          .black16(
                                                                              context),
                                                                    ),
                                                                  ],
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
                                    ),
                                  ),
                                ),

                                // Expanded(
                                //     child: Container(
                                //   height:
                                //       200, // Set a height to avoid rendering errors
                                //   child: Scrollbar(
                                //     controller: _promotionScrollController,
                                //     thumbVisibility: true,
                                //     trackVisibility: true,
                                //     radius: Radius.circular(16),
                                //     thickness: 10,
                                //     child: ListView.builder(
                                //         shrinkWrap: true,
                                //         physics: ClampingScrollPhysics(),
                                //         controller: _promotionScrollController,
                                //         itemCount: listProductChange.length,
                                //         itemBuilder: (context, innerIndex) {
                                //           return Column(
                                //             children: [
                                //               Row(
                                //                 mainAxisAlignment:
                                //                     MainAxisAlignment.start,
                                //                 children: [
                                //                   ClipRRect(
                                //                     borderRadius:
                                //                         BorderRadius.circular(
                                //                             8),
                                //                     child: Image.network(
                                //                       '${ApiService.apiHost}/images/products/${widget.product.id}.webp',
                                //                       width: screenWidth / 8,
                                //                       height: screenWidth / 8,
                                //                       fit: BoxFit.cover,
                                //                       errorBuilder: (context,
                                //                           error, stackTrace) {
                                //                         return const Center(
                                //                           child: Icon(
                                //                             Icons.error,
                                //                             color: Colors.red,
                                //                             size: 50,
                                //                           ),
                                //                         );
                                //                       },
                                //                     ),
                                //                   ),
                                //                   Expanded(
                                //                     flex: 3,
                                //                     child: Padding(
                                //                       padding:
                                //                           const EdgeInsets.all(
                                //                               16.0),
                                //                       child: Column(
                                //                         crossAxisAlignment:
                                //                             CrossAxisAlignment
                                //                                 .start,
                                //                         children: [
                                //                           Row(
                                //                             children: [
                                //                               Expanded(
                                //                                 child: Text(
                                //                                   listProductChange[
                                //                                           innerIndex]
                                //                                       .name,
                                //                                   style: Styles
                                //                                       .black16(
                                //                                           context),
                                //                                   softWrap:
                                //                                       true,
                                //                                   maxLines: 2,
                                //                                   overflow:
                                //                                       TextOverflow
                                //                                           .visible,
                                //                                 ),
                                //                               ),
                                //                             ],
                                //                           ),
                                //                           // Row(
                                //                           //   children: [
                                //                           //     Expanded(
                                //                           //       child: Text(
                                //                           //         listPromotions[
                                //                           //                 innerIndex]
                                //                           //             .proName,
                                //                           //         style: Styles
                                //                           //             .black16(
                                //                           //                 context),
                                //                           //         softWrap: true,
                                //                           //         maxLines: 2,
                                //                           //         overflow:
                                //                           //             TextOverflow
                                //                           //                 .visible,
                                //                           //       ),
                                //                           //     ),
                                //                           //   ],
                                //                           // ),
                                //                           Row(
                                //                             mainAxisAlignment:
                                //                                 MainAxisAlignment
                                //                                     .spaceBetween,
                                //                             children: [
                                //                               Column(
                                //                                 crossAxisAlignment:
                                //                                     CrossAxisAlignment
                                //                                         .start,
                                //                                 children: [
                                //                                   Row(
                                //                                     children: [
                                //                                       Text(
                                //                                         '${listProductChange[innerIndex].id}',
                                //                                         style: Styles.black16(
                                //                                             context),
                                //                                       ),
                                //                                     ],
                                //                                   ),
                                //                                   Row(
                                //                                     children: [
                                //                                       Text(
                                //                                         '${listProductChange[innerIndex].group} รส${listProductChange[innerIndex].flavour}',
                                //                                         style: Styles.black16(
                                //                                             context),
                                //                                       ),
                                //                                     ],
                                //                                   ),
                                //                                 ],
                                //                               ),
                                //                               Row(
                                //                                 mainAxisAlignment:
                                //                                     MainAxisAlignment
                                //                                         .end,
                                //                                 children: [
                                //                                   Container(
                                //                                     padding:
                                //                                         EdgeInsets
                                //                                             .all(4),
                                //                                     decoration:
                                //                                         BoxDecoration(
                                //                                       border:
                                //                                           Border
                                //                                               .all(
                                //                                         color: Colors
                                //                                             .grey,
                                //                                         width:
                                //                                             1,
                                //                                       ),
                                //                                       borderRadius:
                                //                                           BorderRadius.circular(
                                //                                               16),
                                //                                     ),
                                //                                     width: 75,
                                //                                     child: Text(
                                //                                       '${listProductChange[innerIndex].qty.toStringAsFixed(0)} ${listProductChange[innerIndex].unitName}',
                                //                                       textAlign:
                                //                                           TextAlign
                                //                                               .center,
                                //                                       style: Styles
                                //                                           .black18(
                                //                                         context,
                                //                                       ),
                                //                                     ),
                                //                                   ),
                                //                                 ],
                                //                               ),
                                //                             ],
                                //                           ),
                                //                         ],
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 ],
                                //               ),
                                //               Divider(
                                //                 color: Colors.grey[200],
                                //                 thickness: 1,
                                //                 indent: 16,
                                //                 endIndent: 16,
                                //               ),
                                //             ],
                                //           );
                                //         }),
                                //   ),
                                // ))
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BoxShadowCustom(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "รวมรับเปลี่ยนสินค้า",
                            style: Styles.grey18(context),
                          ),
                          Text(
                            "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(refundDetails != null ? refundDetails?.totalChangeExVat : 0)} บาท",
                            style: Styles.grey18(context),
                          )
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       "รวมรับเปลี่ยนสินค้า VAT",
                      //       style: Styles.grey18(context),
                      //     ),
                      //     Text(
                      //       "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(refundDetails != null ? refundDetails?.totalChangeVat : 0)} บาท",
                      //       style: Styles.grey18(context),
                      //     )
                      //   ],
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "รวมรับเปลี่ยนสินค้ารวม VAT",
                            style: Styles.grey18(context),
                          ),
                          Text(
                            "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(refundDetails != null ? refundDetails?.totalChange : 0)} บาท",
                            style: Styles.grey18(context),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "รวมรับคืนสินค้า",
                            style: Styles.grey18(context),
                          ),
                          Text(
                            "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(refundDetails != null ? refundDetails?.totalRefundExVat : 0)} บาท",
                            style: Styles.grey18(context),
                          )
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       "รวมรับคืนสินค้า VAT",
                      //       style: Styles.grey18(context),
                      //     ),
                      //     Text(
                      //       "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(refundDetails != null ? refundDetails?.totalRefundVat : 0)} บาท",
                      //       style: Styles.grey18(context),
                      //     )
                      //   ],
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "รวมรับคืนสินค้ารวม VAT",
                            style: Styles.grey18(context),
                          ),
                          Text(
                            "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(refundDetails != null ? refundDetails?.totalRefund : 0)} บาท",
                            style: Styles.grey18(context),
                          )
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "จำนวนเงินรวมสุทธิ",
                            style: Styles.green24(context),
                          ),
                          Text(
                            "฿${NumberFormat.currency(locale: 'th_TH', symbol: '').format(refundDetails != null ? refundDetails?.totalDiff : 0)} บาท",
                            style: Styles.green24(context),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
                    backgroundColor: Styles.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await printTest();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
                              " พิมพ์ใบคืนสินค้า",
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
                    backgroundColor: refundDetails?.status == "pending"
                        ? Styles.fail
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (refundDetails?.status == "pending") {
                      AllAlert.customAlert(
                          context,
                          "store.processtimeline_screen.alert.title".tr(),
                          "คุณต้องการยกเลิกรายการใช่หรือไม่ ?",
                          _updateStatus);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("ยกเลิกรายการ",
                            style: Styles.headerWhite18(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
