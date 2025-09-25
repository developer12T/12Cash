import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/page/stock/AdjustStock.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/withdraw/WithdrawDetail2.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

class WithdrawDetailScreen extends StatefulWidget {
  final orderId;
  const WithdrawDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<WithdrawDetailScreen> createState() => _WithdrawDetailScreenState();
}

class _WithdrawDetailScreenState extends State<WithdrawDetailScreen>
    with RouteAware {
  List<WithdrawDetail> withdrawDetail = [];
  List<WithdrawDetail> adjustStockDetail = [];
  String highStatus = '';
  String lowStatus = '';

  String getTypeTH(String status) {
    switch (status) {
      case 'normal':
        return "เบิกปกติ"; // รอ
      case 'clearance':
        return "ระบาย"; // อนุมัติแล้ว
      case 'credit':
        return "รับโอนจากเครดิต"; // อนุมัติแล้ว
      default:
        return ""; // fallback
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Register this screen as a route-aware widget
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Only subscribe if the route is a P ageRoute
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // setState(() {
    //   _loadingRouteVisit = true;
    // });
    // Called when the screen is popped back to
    // _getCart();
    _getWithdrawDetail();
    _getAdjustStockDetail();
  }

  @override
  void initState() {
    super.initState();
    _getReceiveQty();
    _getWithdrawDetail();
    _getAdjustStockDetail();
  }

  Future<void> _getReceiveQty() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/distribution/getReceiveQty',
        method: 'POST',
        body: {
          "orderId": widget.orderId,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          highStatus = response.data['data']['highStatus'];
          lowStatus = response.data['data']['lowStatus'];
        });
        if (lowStatus == '99') {
          toastification.show(
            autoCloseDuration: const Duration(seconds: 5),
            context: context,
            primaryColor: Colors.green,
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            title: Text(
              "จัดส่งสำเร็จแล้ว",
              style: Styles.green18(context),
            ),
          );
        } else if (highStatus == '99') {
          toastification.show(
            autoCloseDuration: const Duration(seconds: 5),
            context: context,
            primaryColor: Styles.primaryColor,
            type: ToastificationType.info,
            style: ToastificationStyle.flatColored,
            title: Text(
              "ติดต่อศูนย์ให้ดำเนินการใบเบิก",
              style: Styles.pirmary18(context),
            ),
          );
        } else {
          toastification.show(
            autoCloseDuration: const Duration(seconds: 5),
            context: context,
            primaryColor: Colors.green,
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            title: Text(
              "ติดต่อศูนย์ให้ดำเนินการใบเบิก",
              style: Styles.green18(context),
            ),
          );
        }
        print(response.data['data']['lowStatus']);
        await _getWithdrawDetail();
      }
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.red,
          type: ToastificationType.warning,
          style: ToastificationStyle.flatColored,
          title: Text(
            "ติดต่อศูนย์ให้ดำเนินการใบเบิก",
            style: Styles.red18(context),
          ),
        );
      } else if (e.statusCode == 404) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.red,
          type: ToastificationType.warning,
          style: ToastificationStyle.flatColored,
          title: Text(
            "ไม่พบใบเบิกนี้ไม่เข้าระบบ Info M3",
            style: Styles.red18(context),
          ),
        );
      }
    } catch (e) {
      print("Error _getReceiveQty $e");
    }
  }

  Future<void> _getAdjustStockDetail() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/stock/getAdjustStockDetail?withdrawId=${widget.orderId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic>? data = response.data['data'];
        if (data != null && data.isNotEmpty) {
          adjustStockDetail.clear();
          if (mounted) {
            setState(() {
              // ถ้ามีหลาย record แนะนำใช้ .addAll หรือ .map
              adjustStockDetail =
                  data.map((e) => WithdrawDetail.fromJson(e)).toList();
            });
          }
        }
        print("adjustStockDetail: $adjustStockDetail");
      }
    } catch (e) {
      print("Error _getAdjustStockDetail $e");
    }
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
        final List<dynamic>? data = response.data['data'];
        if (data != null && data.isNotEmpty) {
          withdrawDetail.clear();

          if (mounted) {
            setState(() {
              withdrawDetail.add(WithdrawDetail.fromJson(data[0]));
            });
          }
        }
      }
    } catch (e) {
      print("Error _getWithdrawDetail $e");
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.grey; // รอ
      case 'approved':
        return Colors.blue.shade700; // อนุมัติแล้ว
      case 'onprocess':
        return Colors.orange; // กำลังดำเนินการ
      case 'success':
        return Colors.green.shade600; // สำเร็จ
      case 'confirm':
        return Colors.lightBlue.shade300; // ยืนยันแล้ว
      case 'rejected':
        return Colors.redAccent; // ยืนยันแล้ว
      default:
        return Colors.black; // fallback
    }
  }

  Future<void> _saleConfirmWithdraw() async {
    try {
      context.loaderOverlay.show();
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/distribution/saleConfirmWithdraw',
        method: 'POST',
        body: {
          "orderId": widget.orderId,
          "status": true,
        },
      );
      // if (response.statusCode == 200) {
      //   Navigator.pop(context);
      // }
      context.loaderOverlay.hide();
    } catch (e) {
      // Navigator.pop(context);
      context.loaderOverlay.hide();
      print("Error _saleConfirmWithdraw $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // สมมติใน build() มีตัวแปรพวกนี้อยู่แล้ว:
// String? lowStatus;
// List<WithdrawDetail>? withdrawDetail;

    final wd0 = (withdrawDetail != null && withdrawDetail.isNotEmpty)
        ? withdrawDetail!.first
        : null;

    final bool isLow99 = (lowStatus?.trim() == '99');
    final bool isCredit = (wd0?.withdrawType?.trim().toLowerCase() == 'credit');
    final bool isNewTrip = (wd0?.newTrip?.trim().toLowerCase() == 'false');

    final String? st = wd0?.status?.trim().toLowerCase();
// ถ้าไม่มีสถานะ => ถือว่า "ยังไม่ยืนยัน" (ให้แสดงปุ่ม)
    final bool notConfirmed =
        (st == null) || (st != 'confirm' && st != 'confrim');

    final bool showReceiveButton =
        (isLow99 || isCredit || isNewTrip) && notConfirmed;

    // print(isNewTrip);

    // double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " รายละเอียดการเบิกสินค้า",
          icon: Icons.local_shipping_outlined,
        ),
      ),
      persistentFooterButtons: [
        // เช็ค null & isNotEmpty ก่อนเสมอ
        Row(
          children: [
            withdrawDetail.isNotEmpty &&
                    (withdrawDetail[0]?.status.toUpperCase()) != "PENDING" &&
                    (withdrawDetail.isNotEmpty &&
                        (withdrawDetail[0].status?.toUpperCase() ?? '') !=
                            "CONFIRM")
                ? Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: Styles.fail,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        await _getReceiveQty();
                        await _getWithdrawDetail();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("เช็คสถานะใบเบิก",
                                style: Styles.headerWhite18(context)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
            (withdrawDetail.isNotEmpty &&
                    (withdrawDetail[0].status?.toUpperCase() ?? '') ==
                        "CONFIRM")
                ? Expanded(
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
                            builder: (context) => AdjustStock(
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
                  )
                : const SizedBox(),
            const SizedBox(
              width: 10,
            ),
            showReceiveButton
                ? Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: Styles.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        // AllAlert.customAlert(
                        //     context,
                        //     "store.processtimeline_screen.alert.title".tr(),
                        //     "คุณต้องการจะรับสินค้าใช่หรือไม่ ?",
                        //     _saleConfirmWithdraw);
                        await _saleConfirmWithdraw();
                        await _getWithdrawDetail();
                        await _getAdjustStockDetail();
                        // await _saleConfirmWithdraw();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("รับสินค้า",
                                style: Styles.headerWhite18(context)),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        )
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
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
                              width: screenWidth / 4.5,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: getStatusColor(detail.status)),
                              child: Text(
                                textAlign: TextAlign.center,
                                detail.statusTH.toUpperCase(),
                                style: Styles.white16(context),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("เลขที่: ${detail.orderId}",
                                style: Styles.black16(context)),
                            Text("${getTypeTH(detail.withdrawType)}",
                                style: Styles.black16(context)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("ประเภทการเบิก: ${detail.orderTypeName}",
                                style: Styles.black16(context)),
                            Text(
                                "${detail.newTrip == "true" ? "เบิกต้นทริป" : "เบิกระหว่างทริป"}",
                                style: Styles.black16(context)),
                          ],
                        ),
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
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: detail.listProduct.length,
                          separatorBuilder: (context, i) => const Divider(),
                          itemBuilder: (context, i) {
                            final p = detail.listProduct[i];
                            return Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '${ApiService.image}/images/products/${p.id}.webp',
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
                                          const Icon(Icons.hide_image,
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
                                      Text("เบิกมา",
                                          style: Styles.black18(context)),
                                      Text("${p.qty} ${p.unit}",
                                          style: Styles.black18(context)),
                                    ],
                                  ),
                                ),
                                detail.status == "confirm"
                                    ? Expanded(
                                        child: Column(
                                          children: [
                                            Text("ได้รับ",
                                                style: Styles.red18(context)),
                                            Text("${p.receiveQty} ${p.unit}",
                                                style: Styles.red18(context)),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(),
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
                                  Text("${detail.totalQty}",
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
                                  Text("${detail.receivetotalQty}",
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
                SizedBox(height: 10),

                // Adjust Stock
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ปรับใบเบิก", style: Styles.black18(context)),
                          Text("${adjustStockDetail.length} ใบ",
                              style: Styles.black18(context)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Adjust Stock Details
                ...adjustStockDetail.map((adjust) {
                  return Column(
                    children: [
                      BoxShadowCustom(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "รายการที่ปรับใบปรับของ ${adjust.orderId}",
                                    style: Styles.black18(context),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: adjust.status.toUpperCase() ==
                                                "APPROVED"
                                            ? Styles.success
                                            : Styles.warning),
                                    child: Text(
                                      adjust.status.toUpperCase(),
                                      style: Styles.white16(context),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "จำนวน ${adjust.listProduct.length} รายการ",
                                    style: Styles.black18(context),
                                  ),
                                ],
                              ),
                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: adjust.listProduct.length,
                                separatorBuilder: (context, i) =>
                                    const Divider(),
                                itemBuilder: (context, i) {
                                  final p = adjust.listProduct[i];
                                  return Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          '${ApiService.image}/images/products/${p.id}.webp',
                                          width: screenWidth / 8,
                                          height: screenWidth / 8,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
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
                                                    style: Styles.white18(
                                                        context)),
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
                                            Text("ปรับออก",
                                                style: Styles.black16(context)),
                                            Text("${p.qty}",
                                                style: Styles.black16(context)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
