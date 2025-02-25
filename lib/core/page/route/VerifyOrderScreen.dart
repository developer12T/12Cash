import 'dart:convert';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/layout/BuildTextRowDetailShop.dart';
import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/components/card/order/CartCard.dart';
import 'package:_12sale_app/core/components/table/VerifyTable.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Verifyorderscreen extends StatefulWidget {
  final String customerNo;
  final String customerName;
  final String status;

  const Verifyorderscreen(
      {super.key,
      required this.customerNo,
      required this.customerName,
      required this.status});

  @override
  State<Verifyorderscreen> createState() => _VerifyorderscreenState();
}

class _VerifyorderscreenState extends State<Verifyorderscreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
            title: " ${"route.verify_screen.title".tr()}",
            icon: Icons.receipt_long),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.2), // Shadow color with transparency
                    spreadRadius: 2, // Spread of the shadow
                    blurRadius: 8, // Blur radius of the shadow
                    offset: const Offset(
                        0, 4), // Offset of the shadow (horizontal, vertical)
                  ),
                ],
              ),
              // color: Colors.amber,F
              child: Column(
                children: [
                  BuildTextRowDetailShop(
                    text: "route.verify_screen.sale_name".tr(),
                    value: "จิตรีน เชียงเหิน",
                    left: 3,
                    right: 7,
                  ),
                  BuildTextRowDetailShop(
                    text: "route.verify_screen.customer_no".tr(),
                    value: widget.customerNo,
                    left: 3,
                    right: 7,
                  ),
                  BuildTextRowDetailShop(
                    text: "route.verify_screen.customer_name".tr(),
                    value: widget.customerName,
                    left: 3,
                    right: 7,
                  ),
                  BuildTextRowDetailShop(
                    text: "route.verify_screen.address".tr(),
                    value: "99/9 ถ.ย่ายชื่อ ต.บางบา อ.พานทอง จ.ชลบุรี",
                    left: 3,
                    right: 7,
                  ),
                  BuildTextRowDetailShop(
                    text: "route.verify_screen.customer_phone".tr(),
                    value: "0831157890",
                    left: 3,
                    right: 7,
                  ),
                  BuildTextRowDetailShop(
                    text: "route.verify_screen.tax_no".tr(),
                    value: "-",
                    left: 3,
                    right: 7,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth / 37),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    // Use Expanded here for the container to take available width
                    child: Container(
                      height: double
                          .infinity, // Expands to the maximum height availableF
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                0.2), // Shadow color with transparency
                            spreadRadius: 2, // Spread of the shadow
                            blurRadius: 8, // Blur radius of the shadow
                            offset: const Offset(0,
                                4), // Offset of the shadow (horizontal, vertical)
                          ),
                        ],
                      ),
                      child: CartCard(onDetailsPressed: () {}),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth / 37),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.2), // Shadow color with transparency
                    spreadRadius: 2, // Spread of the shadow
                    blurRadius: 8, // Blur radius of the shadow
                    offset: const Offset(
                        0, 4), // Offset of the shadow (horizontal, vertical)
                  ),
                ],
              ),
              // color: Colors.amber,
              child: Column(
                children: [
                  BuildTextRowBetweenCurrency(
                      text: "route.verify_screen.total".tr(),
                      price: 800.00,
                      style: Styles.black24(context)),
                  BuildTextRowBetweenCurrency(
                      text: "route.verify_screen.discount".tr(),
                      price: 8430.00,
                      style: Styles.black24(context)),
                  BuildTextRowBetweenCurrency(
                      text: "route.verify_screen.net_price".tr(),
                      price: 00.00,
                      style: Styles.black24(context)),
                  BuildTextRowBetweenCurrency(
                      text: "route.verify_screen.vat".tr(),
                      price: 7878.50,
                      style: Styles.black24(context)),
                  BuildTextRowBetweenCurrency(
                      text: "route.verify_screen.amount".tr(),
                      price: 8430.00,
                      style: Styles.headerBlack24(context)),
                ],
              ),
            ),
            SizedBox(height: screenWidth / 37),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.2), // Shadow color with transparency
                    spreadRadius: 2, // Spread of the shadow
                    blurRadius: 8, // Blur radius of the shadow
                    offset: const Offset(
                        0, 4), // Offset of the shadow (horizontal, vertical)
                  ),
                ],
              ),
              child: ButtonFullWidth(
                text: "route.verify_screen.save".tr(),
                textStyle: Styles.headerWhite24(context),
                blackGroundColor: Styles.successButtonColor,
                screen: const HomeScreen(index: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
