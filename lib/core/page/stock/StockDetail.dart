import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/page/stock/StockIN.dart';
import 'package:_12sale_app/core/page/stock/StockOUT.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/stock/StockDetail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StockDetail extends StatefulWidget {
  final String itemCode;
  StockDetail({
    super.key,
    required this.itemCode,
  });

  @override
  State<StockDetail> createState() => _StockDetailState();
}

class _StockDetailState extends State<StockDetail> {
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  late final StockDetailData stockDetailData;

  var data = {
    "productId": "10010101034",
    "productName": "ผงปรุงรสหมู ฟ้าไทย 75g x10x8",
    "STOCK": {
      "stock": [
        {"unit": "CTN", "qty": 4},
        {"unit": "BAG", "qty": 0},
        {"unit": "PCS", "qty": 7}
      ],
      "date": "datetime"
    },
    "IN": {
      "stock": [
        {"unit": "CTN", "qty": 0},
        {"unit": "BAG", "qty": 0},
        {"unit": "PCS", "qty": 0}
      ],
      "withdrawStock": [
        {"unit": "CTN", "qty": 0},
        {"unit": "BAG", "qty": 0},
        {"unit": "PCS", "qty": 0}
      ],
      "withdraw": [
        {
          "area": "SH224",
          "orderId": "W680662401",
          "orderType": "T04",
          "orderTypeName": "รับของเอง",
          "sendDate": "2025-06-11",
          "total": 4,
          "status": "pending"
        },
        {
          "area": "SH224",
          "orderId": "W680662402",
          "orderType": "T04",
          "orderTypeName": "รับของเอง",
          "sendDate": "2025-06-16",
          "total": 3,
          "status": "pending"
        }
      ],
      "refundStock": [
        {"unit": "CTN", "qty": 0},
        {"unit": "BAG", "qty": 0},
        {"unit": "PCS", "qty": 0}
      ],
      "refund": [
        {
          "orderId": "6806936240001",
          "storeId": "C9400001",
          "storeName": "คุณยุพดี  ศรีไตรรัตน์ชัย",
          "storeAddress": "79/61  ถ.ยะรัง  ต.อาเนาะรู  อ.เมือง  จ.ปัตตานี",
          "totalChange": "45.00",
          "totalRefund": "90.00",
          "total": "-45.00",
          "status": "pending"
        },
        {
          "orderId": "6806936240002",
          "storeId": "C9400001",
          "storeName": "คุณยุพดี  ศรีไตรรัตน์ชัย",
          "storeAddress": "79/61  ถ.ยะรัง  ต.อาเนาะรู  อ.เมือง  จ.ปัตตานี",
          "totalChange": "246.00",
          "totalRefund": "492.00",
          "total": "-246.00",
          "status": "pending"
        }
      ],
      "summaryStock": [
        {"unit": "CTN", "qty": 0},
        {"unit": "BAG", "qty": 0},
        {"unit": "PCS", "qty": 0}
      ],
      "summary": 1000
    },
    "OUT": {
      "orderStock": [
        {"unit": "CTN", "qty": 0},
        {"unit": "BAG", "qty": 0},
        {"unit": "PCS", "qty": 0}
      ],
      "order": [
        {
          "orderId": "6806136240002",
          "storeId": "VS21900047",
          "storeName": "อะดำผักสด",
          "storeAddress": "1 ถ.- ต.ปัตตานี  อ.เมือง จ.ปัตตานี",
          "createAt": "2025-06-11T06:33:21.023Z",
          "total": 1080,
          "status": "pending",
          "createdAt": "2025-06-11T06:33:21.023Z"
        },
        {
          "orderId": "6806136240003",
          "storeId": "C9400001",
          "storeName": "คุณยุพดี  ศรีไตรรัตน์ชัย",
          "storeAddress": "79/61  ถ.ยะรัง  ต.อาเนาะรู  อ.เมือง  จ.ปัตตานี",
          "createAt": "2025-06-13T07:54:02.853Z",
          "total": 1620,
          "status": "pending",
          "createdAt": "2025-06-13T07:54:02.853Z"
        }
      ],
      "promotionStock": [
        {"unit": "CTN", "qty": 0},
        {"unit": "BAG", "qty": 0},
        {"unit": "PCS", "qty": 0}
      ],
      "change": [
        {"unit": "CTN", "qty": 0},
        {"unit": "BAG", "qty": 0},
        {"unit": "PCS", "qty": 0}
      ],
      "refund": [
        {
          "orderId": "6806936240001",
          "storeId": "C9400001",
          "storeName": "คุณยุพดี  ศรีไตรรัตน์ชัย",
          "storeAddress": "79/61  ถ.ยะรัง  ต.อาเนาะรู  อ.เมือง  จ.ปัตตานี",
          "totalChange": "45.00",
          "totalRefund": "90.00",
          "total": "-45.00",
          "status": "pending"
        },
        {
          "orderId": "6806936240002",
          "storeId": "C9400001",
          "storeName": "คุณยุพดี  ศรีไตรรัตน์ชัย",
          "storeAddress": "79/61  ถ.ยะรัง  ต.อาเนาะรู  อ.เมือง  จ.ปัตตานี",
          "totalChange": "246.00",
          "totalRefund": "492.00",
          "total": "-246.00",
          "status": "pending"
        }
      ],
      "summaryStock": [
        {"unit": "CTN", "qty": 0},
        {"unit": "BAG", "qty": 0},
        {"unit": "PCS", "qty": 0}
      ],
      "summary": 1000
    },
    "BALANCE": [
      {"unit": "CTN", "qty": 10},
      {"unit": "BAG", "qty": 6},
      {"unit": "PCS", "qty": 0}
    ],
    "summary": 1000
  };

  @override
  void initState() {
    super.initState();
    stockDetailData = StockDetailData.fromJson(data); // ✅ Parse mock data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(
            title: " รายละเอียดสินค้าของ $period", icon: Icons.warehouse),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            BoxShadowCustom(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "${stockDetailData.productName}",
                          style: Styles.headerBlack24(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "รหัสสินค้า ${stockDetailData.productId}",
                          style: Styles.headerBlack18(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Stock",
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ยอดยกมา",
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          stockDetailData
                              .outData
                              .orderStock
                              // .where((u) => u.qty != 0)
                              !
                              .map((u) => '${u.qty} ${u.unit}')
                              .join(' '),
                          style: Styles.black18(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockIN(
                        stockIN: stockDetailData.inData), // row[0] = productId
                  ),
                );
              },
              child: BoxShadowCustom(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Stock In",
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ยอดยกมา',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            stockDetailData.inData.withdrawStock
                                // .where((u) => u.qty != 0)
                                .map((u) => '${u.qty} ${u.unit}')
                                .join(' '),
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'เบิกระหว่างทริป',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            stockDetailData.inData.withdrawStock
                                // .where((u) => u.qty != 0)
                                .map((u) => '${u.qty} ${u.unit}')
                                .join(' '),
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รับคืนดี',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            stockDetailData.inData.withdrawStock
                                // .where((u) => u.qty != 0)
                                .map((u) => '${u.qty} ${u.unit}')
                                .join(' '),
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รวมรับเข้า',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            stockDetailData.inData.withdrawStock
                                // .where((u) => u.qty != 0)
                                .map((u) => '${u.qty} ${u.unit}')
                                .join(' '),
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'มูลค่ารับเข้า',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(stockDetailData.inData.summary)}",
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
                child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockOUT(
                        stockOut:
                            stockDetailData.outData), // row[0] = productId
                  ),
                );
              },
              child: BoxShadowCustom(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Stock Out",
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ขาย',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            stockDetailData
                                .outData
                                .orderStock
                                // .where((u) => u.qty != 0)
                                !
                                .map((u) => '${u.qty} ${u.unit}')
                                .join(' '),
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'แถม',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            stockDetailData
                                .outData
                                .orderStock
                                // .where((u) => u.qty != 0)
                                !
                                .map((u) => '${u.qty} ${u.unit}')
                                .join(' '),
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'เปลี่ยน',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            stockDetailData
                                .outData
                                .orderStock
                                // .where((u) => u.qty != 0)
                                !
                                .map((u) => '${u.qty} ${u.unit}')
                                .join(' '),
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ค่าตั้ง',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            stockDetailData
                                .outData
                                .orderStock
                                // .where((u) => u.qty != 0)
                                !
                                .map((u) => '${u.qty} ${u.unit}')
                                .join(' '),
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รวม',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            stockDetailData
                                .outData
                                .orderStock
                                // .where((u) => u.qty != 0)
                                !
                                .map((u) => '${u.qty} ${u.unit}')
                                .join(' '),
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รวมมูลค่าขาย',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(stockDetailData.inData.summary)}",
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รวมมูลค่าแถม',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(stockDetailData.inData.summary)}",
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รวมมูลเปลี่ยน',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(stockDetailData.inData.summary)}",
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รวมมูลค่าตั้งร้านโชว์',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(stockDetailData.inData.summary)}",
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รวมมูลค่าสินค้าออก',
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(stockDetailData.inData.summary)}",
                            style: Styles.black18(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ))
          ],
        ),
      ),
      persistentFooterButtons: [
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: Styles.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Balance",
                              style: Styles.headerWhite18(context),
                            ),
                            Text(
                              stockDetailData.balance
                                  .where((u) => u.qty != 0)
                                  .map((u) => '${u.qty} ${u.unit}')
                                  .join(' '),
                              style: Styles.headerWhite18(context),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: Styles.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "รวมราคา ",
                              style: Styles.headerWhite18(context),
                            ),
                            Text(
                                "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(stockDetailData.summary)} บาท",
                                style: Styles.headerWhite18(context))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
