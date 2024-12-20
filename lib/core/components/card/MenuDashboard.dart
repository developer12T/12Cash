import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/page/NotificationScreen.dart';
import 'package:_12sale_app/core/page/printer/PrinterScreen.dart';
import 'package:_12sale_app/core/page/setting/SettingScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MenuDashboard extends StatefulWidget {
  final IconData icon_1;
  final String title_1;
  void Function()? onTap1;
  final IconData icon_2;
  final String title_2;
  void Function()? onTap2;
  final IconData icon_3;
  final String title_3;
  void Function()? onTap3;
  final IconData icon_4;
  final String title_4;
  void Function()? onTap4;
  final IconData icon_5;
  final String title_5;
  void Function()? onTap5;
  final IconData icon_6;
  final String title_6;
  void Function()? onTap6;
  MenuDashboard({
    required this.icon_1,
    required this.title_1,
    this.onTap1,
    required this.icon_2,
    required this.title_2,
    this.onTap2,
    required this.icon_3,
    required this.title_3,
    this.onTap3,
    required this.icon_4,
    required this.title_4,
    this.onTap4,
    required this.icon_5,
    required this.title_5,
    this.onTap5,
    required this.icon_6,
    required this.title_6,
    this.onTap6,
    super.key,
  });

  @override
  State<MenuDashboard> createState() => _MenuDashboardState();
}

class _MenuDashboardState extends State<MenuDashboard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap1,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: Colors.grey[350]!,
                      width: 1.0,
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon_1,
                        size: 60,
                        color: Styles.primaryColor,
                      ),
                      Text(
                        widget.title_1,
                        style: Styles.black24(context),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap2,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[350]!,
                      width: 1.0,
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon_2,
                        size: 60,
                        color: Styles.primaryColor,
                      ),
                      Text(
                        widget.title_2,
                        style: Styles.black24(context),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap3,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: Colors.grey[350]!,
                      width: 1.0,
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon_3,
                        size: 60,
                        color: Styles.primaryColor,
                      ),
                      Text(
                        widget.title_3,
                        style: Styles.black24(context),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap4,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    // color: Colors.amber,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: Colors.grey[350]!,
                      width: 1.0,
                    ),
                    color: Colors.white,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          height: screenWidth / 18,
                          width: screenWidth / 18,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius.all(Radius.circular(360)),
                          ),
                          child: Center(
                            child: Text(
                              "1",
                              style: Styles.white18(context),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.icon_4,
                            size: 60,
                            color: Styles.primaryColor,
                          ),
                          Text(
                            widget.title_4,
                            style: Styles.black24(context),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap5,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[350]!,
                      width: 1.0,
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon_5,
                        size: 60,
                        color: Styles.primaryColor,
                      ),
                      Text(
                        widget.title_5,
                        style: Styles.black24(context),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap6,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: Colors.grey[350]!,
                      width: 1.0,
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon_6,
                        size: 60,
                        color: Styles.primaryColor,
                      ),
                      Text(
                        widget.title_6,
                        style: Styles.black24(context),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
