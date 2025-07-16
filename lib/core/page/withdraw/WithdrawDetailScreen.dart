import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/page/stock/AjustStock.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/withdraw/WithdrawDetail2.dart';
// import 'package:_12sale_app/data/models/withdraw/WithdrawDetail.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WithdrawDetailScreen extends StatefulWidget {
  final orderId;
  const WithdrawDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<WithdrawDetailScreen> createState() => _WithdrawDetailScreenState();
}

class _WithdrawDetailScreenState extends State<WithdrawDetailScreen> {
  List<WithdrawDetail> withdrawDetail = [];
  @override
  void initState() {
    super.initState();
    _getWithdrawDetail();
  }

  Future<void> _getWithdrawDetail() async {
    try {
      print("Order ID : ${widget.orderId}");
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/distribution/detail/${widget.orderId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        print(data[0]);
        setState(() {
          withdrawDetail.add(WithdrawDetail.fromJson(data[0]));
        });
      }
      // if (response.statusCode == 200) {
      //   for (var element in response.data['data']) {
      //     final Map<String, dynamic> data = element;
      //     setState(() {
      //       withdrawDetail.add(WithdrawDetail.fromJson(data));
      //     });
      //   }
      // }
      // print(withdrawDetail.length);
      // print(withdrawDetail[0].listProductWithdraw.length);
    } catch (e) {
      print("Error _getWithdrawDetail $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: AppbarCustom(
            title: " รายละเอียดการเบิกสินค้า",
            icon: Icons.local_shipping_outlined,
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
                        backgroundColor: Styles.fail,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AjustStock(
                              orderId: widget.orderId,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("ขอปรับ stock สินค้า",
                                style: Styles.headerWhite18(context)),
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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: Column(
            children: withdrawDetail.map((detail) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxShadowCustom(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "วันที่ทำรายการ: ${DateFormat('dd/MM/yyyy').format(detail.createdAt)}",
                                style: Styles.black16(context),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Styles.warning,
                                ),
                                child: Text(
                                  detail.status.toUpperCase(),
                                  style: Styles.white16(context),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Text("เลขที่: ${detail.orderId}",
                              style: Styles.black16(context)),
                          Text("ประเภทการเบิก: ${detail.orderTypeName}",
                              style: Styles.black16(context)),
                          Text("หมายเหตุ: ${detail.remark}",
                              style: Styles.black16(context)),
                          Text(
                            "สถานที่จัดส่ง: ${detail.shippingName} ${detail.sendAddress}",
                            style: Styles.black16(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Product list
                  BoxShadowCustom(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("รายการที่สั่ง",
                                  style: Styles.black18(context)),
                              Text("จำนวน ${detail.listProduct.length} รายการ",
                                  style: Styles.black18(context)),
                            ],
                          ),
                          ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: detail.listProduct.length,
                            separatorBuilder: (context, i) => Divider(),
                            itemBuilder: (context, i) {
                              final p = detail.listProduct[i];
                              return Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      '${ApiService.apiHost}/images/products/${p.id}.webp',
                                      width: screenWidth / 8,
                                      height: screenWidth / 8,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: screenWidth / 8,
                                        height: screenWidth / 8,
                                        color: Colors.grey,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.hide_image,
                                                color: Colors.white),
                                            Text("ไม่มีภาพ",
                                                style: Styles.white18(context)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name,
                                            style: Styles.black16(context)),
                                        Text("รหัส : ${p.id}",
                                            style: Styles.black16(context)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text("เบิก",
                                            style: Styles.black16(context)),
                                        Text("${p.qty}",
                                            style: Styles.black16(context)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text("รับ",
                                            style: Styles.red18(context)),
                                        Text("0", style: Styles.red18(context)),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Summary
                  BoxShadowCustom(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // เบิก
                          Expanded(
                            child: Column(
                              children: [
                                Text("เบิก", style: Styles.black18(context)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("จำนวนรวม",
                                        style: Styles.black16(context)),
                                    Text("${detail.totalQty} หีบ",
                                        style: Styles.black16(context)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("น้ำหนักรวม",
                                        style: Styles.black16(context)),
                                    Text(
                                        "${detail.totalWeightGross.toStringAsFixed(2)} กก.",
                                        style: Styles.black16(context)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("น้ำหนักรวมสุทธิ",
                                        style: Styles.black16(context)),
                                    Text(
                                        "${detail.totalWeightNet.toStringAsFixed(2)} กก.",
                                        style: Styles.black16(context)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // รับ
                          Expanded(
                            child: Column(
                              children: [
                                Text("รับ", style: Styles.black18(context)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("จำนวนรวม",
                                        style: Styles.black16(context)),
                                    Text("${detail.receivetotalQty} หีบ",
                                        style: Styles.black16(context)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("น้ำหนักรวม",
                                        style: Styles.black16(context)),
                                    Text(
                                        "${detail.receivetotalWeightGross.toStringAsFixed(2)} กก.",
                                        style: Styles.black16(context)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("น้ำหนักรวมสุทธิ",
                                        style: Styles.black16(context)),
                                    Text(
                                        "${detail.receivetotalWeightNet.toStringAsFixed(2)} กก.",
                                        style: Styles.black16(context)),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ));
  }
}
