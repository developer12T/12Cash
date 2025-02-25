import 'dart:ui';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/layout/BuildTextRowDetailShop.dart';
import 'package:_12sale_app/core/page/3D_canvas/Ractangle3D.dart';
import 'package:_12sale_app/core/page/withdraw/UtilzeDetail.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WeightCudeCard extends StatefulWidget {
  const WeightCudeCard({super.key});

  @override
  State<WeightCudeCard> createState() => _WeightCudeCardState();
}

class _WeightCudeCardState extends State<WeightCudeCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return BoxShadowCustom(
      child: Container(
        height: screenWidth / 1.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ตัวอย่าง${"dashboard.weightcude_card.title".tr()}",
                  style: Styles.black24(context),
                ),
              ],
            ),
            SizedBox(
              height: screenWidth / 15,
            ),
            Hero(
              tag: 'rectangle',
              child: GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => UtilzedDetail(),
                  //   ),
                  // );
                },
                child: WaterFilledRectangle(
                  isWithdraw: true,
                  width: screenWidth / 5,
                  height: screenWidth / 9,
                  depth: screenWidth / 6,
                  fillStockPercentage: 0.75,
                  fillWithdrawPercentage: 0.40,
                ),
              ),
            ),
            // Row(
            //   children: [
            //     Text(
            //       "Net Weight",
            //       style: Styles.black18(context),
            //     )
            //   ],
            // )
            BuildTextRowBetween(
                text: "dashboard.weightcude_card.net_weight".tr(),
                text2: "0.94 ${"dashboard.weightcude_card.gilo_unit".tr()}",
                style: Styles.black24(context)),
            BuildTextRowBetween(
                text: "dashboard.weightcude_card.gross_weight".tr(),
                text2: "0.94 ${"dashboard.weightcude_card.gilo_unit".tr()}",
                style: Styles.black24(context)),
            BuildTextRowBetween(
                text: "dashboard.weightcude_card.utilized_weight".tr(),
                text2: "0.94 ${"dashboard.weightcude_card.ton_unit".tr()}",
                style: Styles.black24(context)),
            // SizedBox(
            //   height: screenWidth / 15,
            // ),
          ],
        ),
      ),
    );
  }
}
