import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/page/Ractangle3D.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

class UtilzedDetail extends StatefulWidget {
  const UtilzedDetail({super.key});

  @override
  State<UtilzedDetail> createState() => _UtilzedDetailState();
}

class _UtilzedDetailState extends State<UtilzedDetail> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
            title: " รายละเอียดน้ำหนักสุทธิ", icon: Icons.local_shipping),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BoxShadowCustom(
              child: Container(
                height: screenHeight * 0.8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "dwa",
                            style: Styles.black18(context),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "dwa",
                            style: Styles.black18(context),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "dwa",
                            style: Styles.black18(context),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "dwa",
                            style: Styles.black18(context),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "dwa",
                            style: Styles.black18(context),
                          )
                        ],
                      ),
                      Hero(
                        tag: 'rectangle',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WaterFilledRectangle(
                              isWithdraw: true,
                              width: screenWidth / 5,
                              height: screenWidth / 9,
                              depth: screenWidth / 6,
                              fillStockPercentage: 0.75,
                              fillWithdrawPercentage: 0.40,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
