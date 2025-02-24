import 'dart:convert';
import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/card/CartCard.dart';
import 'package:_12sale_app/core/page/order/OrderScreen.dart';
import 'package:_12sale_app/core/page/route/PromotionScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShoppingCartScreen extends StatefulWidget {
  final String customerNo;
  final String customerName;
  final String status;

  const ShoppingCartScreen(
      {super.key,
      required this.customerNo,
      required this.customerName,
      required this.status});
  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  int count = 4;
  double price = 2000.0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(
            title: " ${"route.shop_cart_screen.title".tr()}",
            icon: Icons.shopping_cart_outlined),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("route.shop_cart_screen.store_id".tr(),
                style: Styles.black24(context)),
            Text("ร้าน ${widget.customerName}", style: Styles.black24(context)),
            Align(
              alignment: Alignment.center,
              child: Text(
                "route.shop_cart_screen.store_name".tr(),
                style: Styles.black24(context),
              ),
            ),
            Expanded(
              flex: 8,
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
                        // border: Border.all(color: Colors.grey),
                        // borderRadius: BorderRadius.circular(10),
                      ),
                      child: CartCard(onDetailsPressed: () {}),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth / 2.3,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Orderscreen(
                              customerNo: widget.customerNo,
                              customerName: widget.customerName,
                              status: widget.status),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.primaryColor,
                      // padding: EdgeInsets.symmetric(
                      //     vertical: screenWidth / 85,
                      //     horizontal: screenWidth / 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("route.shop_cart_screen.select_item".tr(),
                        style: Styles.white18(context)),
                  ),
                ),
                SizedBox(
                  width: screenWidth / 2.3,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Promotionscreen(
                            customerName: widget.customerName,
                            customerNo: widget.customerNo,
                            status: widget.status,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.successButtonColor,
                      // padding: EdgeInsets.symmetric(
                      //     vertical: screenWidth / 80,
                      //     horizontal: screenWidth / 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("route.shop_cart_screen.create_order".tr(),
                        style: Styles.white18(context)),
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("route.shop_cart_screen.qty".tr(),
                    style: Styles.black24(context)),
                Row(
                  children: [
                    Text("$count    ", style: Styles.black24(context)),
                    Text("route.shop_cart_screen.item".tr(),
                        style: Styles.black24(context)),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("route.shop_cart_screen.amount".tr(),
                    style: Styles.black24(context)),
                Row(
                  children: [
                    Text("$price          ", style: Styles.black24(context)),
                    Text("route.shop_cart_screen.bath".tr(),
                        style: Styles.black24(context)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
