import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/page/stock/StockIN.dart';
import 'package:_12sale_app/core/page/stock/StockOUT.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/stock/StockDetail.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StockDetail extends StatefulWidget {
  final String itemCode;
  const StockDetail({super.key, required this.itemCode});

  @override
  State<StockDetail> createState() => _StockDetailState();
}

class _StockDetailState extends State<StockDetail> {
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";
  StockDetailData? stockDetailData;

  @override
  void initState() {
    super.initState();
    _getStockDetail();
  }

  Future<void> _getStockDetail() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/stock/getStockQtyDetail',
        method: 'POST',
        body: {
          "area": User.area,
          "productId": widget.itemCode,
          "period": period,
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            stockDetailData = StockDetailData.fromJson(response.data['data']);
          });
        }
      }
    } catch (e, s) {
      print('❌ Error while parsing StockDetailData: $e');
      print('Stack trace: $s');
      // print('Raw JSON: $jsonData');
      print("Error _getStockDetail: $e");
    }
  }

  String formatUnitList(List<UnitQty>? list) {
    final filtered = list?.where((u) => u.qty != 0).toList() ?? [];
    return filtered.isEmpty
        ? 'ไม่มี' // fallback if null or no quantity > 0
        : filtered.map((u) => '${u.qty} ${u.unitName}').join(' ');
  }

  String formatCurrency(double? amount) {
    return NumberFormat.currency(locale: 'th_TH', symbol: '฿')
        .format(amount ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(
            title: " รายละเอียดสินค้าของ $period", icon: Icons.warehouse),
      ),
      body: LoadingSkeletonizer(
        loading: stockDetailData == null,
        child: stockDetailData == null
            ? Container()
            : Container(
                padding: const EdgeInsets.all(16.0),
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
                                  stockDetailData?.productName ?? '',
                                  style: Styles.headerBlack24(context),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "รหัสสินค้า ${stockDetailData?.productId ?? ''}",
                                  style: Styles.headerBlack18(context),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Stock",
                                  style: Styles.black18(context),
                                ),
                                Text(
                                  "${formatDate(stockDetailData?.stock.date)}",
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("ยอดยกมา", style: Styles.black18(context)),
                                Text(
                                  formatUnitList(stockDetailData?.stock.stock),
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StockIN(stockIN: stockDetailData!.inData),
                          ),
                        );
                      },
                      child: BoxShadowCustom(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(children: [
                                Text("Stock In", style: Styles.black18(context))
                              ]),
                              buildRow(
                                  'ยอดยกมา',
                                  formatUnitList(
                                      stockDetailData?.inData.stock)),
                              buildRow(
                                  'เบิกระหว่างทริป',
                                  formatUnitList(
                                      stockDetailData?.inData.withdrawStock)),
                              buildRow(
                                  'รับคืนดี',
                                  formatUnitList(
                                      stockDetailData?.inData.refundStock)),
                              buildRow(
                                  'รวมรับเข้า',
                                  formatUnitList(
                                      stockDetailData?.inData.summaryStock)),
                              buildRow(
                                  'มูลค่ารับเข้า',
                                  formatCurrency(
                                      stockDetailData?.inData.summaryStockIn)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StockOUT(stockOut: stockDetailData!.outData),
                            ),
                          );
                        },
                        child: BoxShadowCustom(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(children: [
                                  Text("Stock Out",
                                      style: Styles.black18(context))
                                ]),
                                buildRow(
                                    'ขาย',
                                    formatUnitList(
                                        stockDetailData?.outData.orderStock)),
                                buildRow(
                                    'แถม',
                                    formatUnitList(stockDetailData
                                        ?.outData.promotionStock)),
                                buildRow(
                                    'เปลี่ยน',
                                    formatUnitList(
                                        stockDetailData?.outData.change)),
                                // buildRow(
                                //     'ค่าตั้ง',
                                //     formatUnitList(
                                //         stockDetailData?.outData.refund)),
                                buildRow(
                                    'รวม',
                                    formatUnitList(
                                        stockDetailData?.outData.summaryStock)),
                                const Spacer(),
                                buildRow(
                                    'รวมมูลค่าขาย',
                                    formatCurrency(
                                        stockDetailData?.outData.orderSum)),
                                buildRow(
                                    'รวมมูลค่าแถม',
                                    formatCurrency(
                                        stockDetailData?.outData.promotionSum)),
                                buildRow(
                                    'รวมมูลเปลี่ยน',
                                    formatCurrency(
                                        stockDetailData?.outData.changeSum)),
                                // buildRow(
                                //     'รวมมูลค่าตั้งร้านโชว์',
                                //     formatCurrency(
                                //         stockDetailData?.outData.refundSum)),
                                buildRow(
                                    'รวมมูลค่าสินค้าออก',
                                    formatCurrency(stockDetailData
                                        ?.outData.summaryStockInOut)),
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
      persistentFooterButtons: [
        Column(
          children: [
            Row(
              children: [
                Expanded(
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
                          Text("Balance", style: Styles.headerWhite18(context)),
                          Text(
                            formatUnitList(stockDetailData?.balance),
                            style: Styles.headerWhite18(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("รวมราคา ",
                              style: Styles.headerWhite18(context)),
                          Text(
                            "${formatCurrency(stockDetailData?.summary)} บาท",
                            style: Styles.headerWhite18(context),
                          ),
                        ],
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

  String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final date =
          DateTime.parse(isoString).toLocal(); // convert to local timezone
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '-';
    }
  }

  Widget buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Styles.black18(context)),
        Text(value, style: Styles.black18(context)),
      ],
    );
  }
}
