import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/order/OrderDetail.dart';
import 'package:_12sale_app/data/models/order/Orders.dart';
import 'package:_12sale_app/data/models/refund/RefundOrder.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RefundCard extends StatelessWidget {
  final RefundOrder item;
  final VoidCallback onDetailsPressed;
  const RefundCard({
    required this.item,
    required this.onDetailsPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // DateTime formattedDate =
    //     DateTime(item.createAt.year, item.createAt.month, item.createAt.day);
    return GestureDetector(
      onTap: onDetailsPressed,
      child: Container(
        height: screenWidth / 4,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: BoxShadowCustom(
          child: Container(
            // color: Colors.cyan,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Styles.secondaryColor.withOpacity(0.1),
                          ),
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.change_circle_outlined,
                                color: Styles.primaryColorIcons,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "วันที่เวลา: ${DateFormat('dd/MM/yyyy | HH:mm:ss').format(DateTime.now())}",
                                      style: Styles.black16(context),
                                    ),
                                  ],
                                ),
                                Skeleton.ignore(
                                  child: Container(
                                    width: screenWidth / 7,
                                    // padding: EdgeInsets.all(4),
                                    // margin: EdgeInsets.only(right: 8),
                                    // height: screenWidth / ,
                                    decoration: BoxDecoration(
                                      color: item.status == 'completed'
                                          ? Styles.successTextColor
                                          : item.status == 'canceled'
                                              ? Styles.failTextColor
                                              : Styles.warning,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      '${item.status.toUpperCase()}',
                                      style: Styles.white16(context),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "ร้าน: ${item.storeName}",
                                        style: Styles.headerBlack18(context),
                                      ),
                                      Text(
                                        "เลขที่: ${item.orderId}",
                                        style: Styles.black16(context),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "ที่อยู่: ${item.storeAddress}",
                                              style: Styles.black16(context),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(item.totalRefund)}",
                                            style: Styles.grey16(context),
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(item.totalChange)}",
                                            style: Styles.grey16(context),
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(item.total)}",
                                            style:
                                                Styles.headerGreen24(context),
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Container(
                            //     margin: EdgeInsets.only(right: 8),
                            //     child: Text(
                            //       "ราคารวม ${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(item.total)} บาท",
                            //       style: Styles.black16(context),
                            //     ),
                            //   ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
