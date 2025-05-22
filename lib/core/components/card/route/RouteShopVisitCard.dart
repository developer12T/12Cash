import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/chart/CircularChart.dart';
import 'package:_12sale_app/core/styles/style.dart';

import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/route/RouteVisit.dart';
import 'package:_12sale_app/data/models/route/StoreVisit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RouteShopVisitCard extends StatelessWidget {
  final StoreVisit item;
  // final int all;
  // final int pending;
  // final int buy;
  // final int notBuy;
  // final int total;
  final VoidCallback onDetailsPressed;
  const RouteShopVisitCard({
    required this.item,
    required this.onDetailsPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onDetailsPressed,
      child: Container(
        height: screenWidth / 3,
        margin: EdgeInsets.all(8.0),
        child: BoxShadowCustom(
          shadowColor: item.percentVisit < 50
              ? Styles.fail!
              : item.percentVisit < 79
                  ? Styles.warning!
                  : Styles.success!,
          borderColor: item.percentVisit < 50
              ? Styles.fail!
              : item.percentVisit < 79
                  ? Styles.warning!
                  : Styles.success!,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            // color: Colors.cyan,
            decoration: BoxDecoration(
              // color: Styles.successTextColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: screenWidth / 4,
                        child: Column(
                          children: [
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'R${item.day}',
                                  style: Styles.headerBlack24(context),
                                ),
                                // Text(
                                //   'R${item.day}',
                                //   style: Styles.headerBlack24(context),
                                // ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ทั้งหมด',
                                  style: Styles.black18(context),
                                ),
                                Text(
                                  '${item.storeAll}',
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ซื้อ',
                                  style: Styles.black18(context),
                                ),
                                Text(
                                  '${item.storeSell}',
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'เยี่ยมแล้ว',
                                  style: Styles.black18(context),
                                ),
                                Text(
                                  '${item.storeCheckInNotSell}',
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ไม่ซื้อ',
                                  style: Styles.black18(context),
                                ),
                                Text(
                                  '${item.storeNotSell}',
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'รอเยี่ยม',
                                  style: Styles.black18(context),
                                ),
                                Text(
                                  '${item.storePending}',
                                  style: Styles.black18(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                bottom: 35,
                                top: 35,
                                left: screenWidth / 15,
                              ),
                              child: CustomPaint(
                                size: Size(200, 200),
                                painter: CircularChartPainter(
                                  completionPercentage: item.percentComplete,
                                  effectivenessPercentage: item.percentVisit,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${item.storeTotal}/${item.storeAll}",
                                        style: Styles.black18(context),
                                      ),
                                      SizedBox(
                                        width: 80,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
