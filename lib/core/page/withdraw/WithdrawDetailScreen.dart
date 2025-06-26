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
                          builder: (context) => AjustStock(),
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
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.all(8),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: withdrawDetail.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            // height: screenHeight * 0.13,
                            child: BoxShadowCustom(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "วันที่ทำรายการ: ${DateFormat('dd/MM/yyyy').format(withdrawDetail[index].createdAt)}",
                                          style: Styles.black16(context),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Styles.warning,
                                          ),
                                          child: Text(
                                            "${withdrawDetail[index].status.toUpperCase()}",
                                            textAlign: TextAlign.center,
                                            style: Styles.white16(context),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "เลขที่: ${withdrawDetail[index].orderId}",
                                            style: Styles.black16(context),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "ประเภทการเบิก: ${withdrawDetail[index].orderTypeName}",
                                            style: Styles.black16(context),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  // Expanded(
                                                  //   child: Text(
                                                  //     "วันทีจัดส่ง: ${DateFormat('dd/MM/yyyy').format(withdrawDetail[index].sendDate)}",
                                                  //     style: Styles.black16(
                                                  //         context),
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "หมายเหตุ: ${withdrawDetail[index].remark}",
                                                      style: Styles.black16(
                                                          context),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "สถานที่จัดส่ง: ${withdrawDetail[index].shippingName} ${withdrawDetail[index].sendAddress}",
                                            style: Styles.black16(context),
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
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: screenHeight * 0.6,
                            child: BoxShadowCustom(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "รายการที่สั่ง",
                                          style: Styles.black18(context),
                                        ),
                                        Text(
                                          "จำนวน ${withdrawDetail[index].listProduct.length} รายการ",
                                          style: Styles.black18(context),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        // controller: _cartScrollController,
                                        itemCount: withdrawDetail[index]
                                            .listProduct
                                            .length,
                                        itemBuilder: (context, innerIndex) {
                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.network(
                                                      '${ApiService.apiHost}/images/products/${withdrawDetail[index].listProduct[innerIndex].id}.webp',
                                                      width: screenWidth / 8,
                                                      height: screenWidth / 8,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          width:
                                                              screenWidth / 8,
                                                          height:
                                                              screenWidth / 8,
                                                          color: Colors.grey,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .hide_image,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 30),
                                                              Text(
                                                                "ไม่มีภาพ",
                                                                style: Styles
                                                                    .white18(
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
                                                                  withdrawDetail[
                                                                          index]
                                                                      .listProduct[
                                                                          innerIndex]
                                                                      .name,
                                                                  style: Styles
                                                                      .black16(
                                                                          context),
                                                                  softWrap:
                                                                      true,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  "รหัส : ${withdrawDetail[index].listProduct[innerIndex].id}",
                                                                  style: Styles
                                                                      .black16(
                                                                          context),
                                                                  softWrap:
                                                                      true,
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
                                                                  // Row(
                                                                  //   children: [
                                                                  //     Text(
                                                                  //       'Lot : 2407242110000000',
                                                                  //       style: Styles.black16(
                                                                  //           context),
                                                                  //     ),
                                                                  //   ],
                                                                  // ),
                                                                  // Row(
                                                                  //   children: [
                                                                  //     Text(
                                                                  //       'ราคา : ${withdrawDetail[index].listProductWithdraw[innerIndex].price}',
                                                                  //       style: Styles
                                                                  //           .black16(
                                                                  //               context),
                                                                  //     ),
                                                                  //   ],
                                                                  // ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "เบิก",
                                                          style: Styles.black18(
                                                              context),
                                                        ),
                                                        Text(
                                                          "${withdrawDetail[index].listProduct[innerIndex].qty}",
                                                          style: Styles.black18(
                                                              context),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "รับ",
                                                          style: Styles.red18(
                                                              context),
                                                        ),
                                                        Text(
                                                          "0",
                                                          style: Styles.red18(
                                                              context),
                                                        ),
                                                      ],
                                                    ),
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
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: screenHeight * 0.132,
                            child: BoxShadowCustom(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            "เบิก",
                                            style: Styles.black18(context),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "จำนวนรวม",
                                                style: Styles.black18(context),
                                              ),
                                              Text(
                                                "${withdrawDetail[index].totalQty} หีบ",
                                                style: Styles.black18(context),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "น้ำหนักรวม",
                                                style: Styles.black18(context),
                                              ),
                                              Text(
                                                "${withdrawDetail[index].totalWeightGross.toStringAsFixed(2)} กก.",
                                                style: Styles.black18(context),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "น้ำหนักรวมสุทธิ",
                                                style: Styles.black18(context),
                                              ),
                                              Text(
                                                "${withdrawDetail[index].totalWeightNet.toStringAsFixed(2)} กก.",
                                                style: Styles.black18(context),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            "รับ",
                                            style: Styles.black18(context),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "จำนวนรวม",
                                                style: Styles.black18(context),
                                              ),
                                              Text(
                                                "${withdrawDetail[index].receivetotalQty} หีบ",
                                                style: Styles.black18(context),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "น้ำหนักรวม",
                                                style: Styles.black18(context),
                                              ),
                                              Text(
                                                "${withdrawDetail[index].receivetotalWeightGross.toStringAsFixed(2)} กก.",
                                                style: Styles.black18(context),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "น้ำหนักรวมสุทธิ",
                                                style: Styles.black18(context),
                                              ),
                                              Text(
                                                "${withdrawDetail[index].receivetotalWeightNet.toStringAsFixed(2)} กก.",
                                                style: Styles.black18(context),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // Container(
          //   height: MediaQuery.of(context).size.height * 0.9,
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Column(
          //       children: [
          //         BoxShadowCustom(
          //           child: Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Column(
          //               children: [
          //                 Row(
          //                   mainAxisAlignment: MainAxisAlignment.start,
          //                   children: [
          //                     Text(
          //                       "เลขที่ ${withdrawDetail[0].orderId}",
          //                       style: Styles.black24(context),
          //                     ),
          //                   ],
          //                 ),
          //                 Row(
          //                   mainAxisAlignment: MainAxisAlignment.start,
          //                   children: [
          //                     Text(
          //                       "จากศูนย์ ${withdrawDetail[0].fromWarehouse} ไป ${withdrawDetail[0].toWarehouse}",
          //                       style: Styles.black18(context),
          //                     ),
          //                   ],
          //                 ),
          //                 // Text(
          //                 //   "เลขที่ ${withdrawDetail[0].orderTypeName}",
          //                 //   style: Styles.black18(context),
          //                 // ),
          //               ],
          //             ),
          //           ),
          //         ),
          //         SizedBox(
          //           height: 10,
          //         ),
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
