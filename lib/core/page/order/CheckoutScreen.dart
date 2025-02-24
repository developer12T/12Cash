import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  String isSelect = '';
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppbarCustom(
          title: " Payment",
          icon: Icons.payments_rounded,
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
            child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: viewportConstraints.maxHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: BoxShadowCustom(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            // color: Colors.amber,
                            height: viewportConstraints.maxHeight * 0.95,
                            child: Column(
                              children: [
                                checkOutSelect(context, "QR Payment",
                                    "https://www.designil.com/wp-content/uploads/2022/02/prompt-pay-logo.jpg"),
                                checkOutIconSelect(context, "เงินสด"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
      }),
    );
  }

  Widget checkOutSelect(BuildContext context, String title, String image) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(0),
                elevation: 0, // Disable shadow
                shadowColor: Colors.transparent, // Ensure no shadow color
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // No rounded corners
                  side: BorderSide.none, // Remove border
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            ClipRRect(
                              child: Image.network(
                                image,
                                width: screenWidth / 5,
                                height: screenWidth / 15,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 50,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text(
                              "${title}",
                              style: Styles.grey18(context),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            (isSelect == title)
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                  )
                                : SizedBox(
                                    width: 25,
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
              ),
              onPressed: () {
                setState(() {
                  isSelect = title;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget checkOutIconSelect(BuildContext context, String title) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(0),
                elevation: 0, // Disable shadow
                shadowColor: Colors.transparent, // Ensure no shadow color
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // No rounded corners
                  side: BorderSide.none, // Remove border
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.handHoldingDollar,
                              color: Styles.primaryColor,
                              size: 40,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text(
                              "${title}",
                              style: Styles.grey18(context),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            (isSelect == title)
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                  )
                                : SizedBox(
                                    width: 25,
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
              ),
              onPressed: () {
                setState(() {
                  isSelect = title;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
