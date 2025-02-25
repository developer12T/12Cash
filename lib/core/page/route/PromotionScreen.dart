import 'dart:convert';
import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/page/route/VerifyOrderScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Promotionscreen extends StatefulWidget {
  final String customerNo;
  final String customerName;
  final String status;

  const Promotionscreen(
      {super.key,
      required this.customerNo,
      required this.customerName,
      required this.status});

  @override
  State<Promotionscreen> createState() => _PromotionscreenState();
}

class _PromotionscreenState extends State<Promotionscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
            title: " ${"route.promotion_screen.title".tr()}",
            icon: Icons.campaign_rounded),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("route.promotion_screen.giveaway".tr(),
                style: Styles.headerBlack24(context)),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
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
                        // border: Border.all(color: Colors.grey),
                        // borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
            Text("route.promotion_screen.discount".tr(),
                style: Styles.headerBlack24(context)),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
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
                        // border: Border.all(color: Colors.grey),
                        // borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Perform save action
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Verifyorderscreen(
                        customerName: widget.customerName,
                        customerNo: widget.customerNo,
                        status: widget.status,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.successButtonColor,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("route.promotion_screen.next_button".tr(),
                    style: Styles.white18(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
