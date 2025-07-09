import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/page/notification/NotificationScreen.dart';
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

  final IconData icon_7;
  final String title_7;
  void Function()? onTap7;

  final IconData icon_8;
  final String title_8;
  void Function()? onTap8;
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
    required this.icon_7,
    required this.title_7,
    this.onTap7,
    required this.icon_8,
    required this.title_8,
    this.onTap8,
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
                  height: 80,
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
                        widget.icon_1,
                        size: 40,
                        color: Styles.primaryColorIcons,
                      ),
                      Text(
                        widget.title_1,
                        style: Styles.black16(context),
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
                    height: 80,
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
                          size: 40,
                          color: Styles.primaryColorIcons,
                        ),
                        Text(
                          widget.title_2,
                          style: Styles.black16(context),
                        )
                      ],
                    )),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap3,
                child: Container(
                  height: 80,
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
                        widget.icon_3,
                        size: 40,
                        color: Styles.primaryColorIcons,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.title_3,
                            style: Styles.black16(context),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap4,
                child: Container(
                  height: 80,
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
                        widget.icon_4,
                        size: 40,
                        color: Styles.primaryColorIcons,
                      ),
                      Text(
                        widget.title_4,
                        style: Styles.black16(context),
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
                onTap: widget.onTap5,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[350]!,
                      width: 1.0,
                    ),
                    color: Colors.white,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.icon_5,
                            size: 40,
                            color: Styles.primaryColorIcons,
                          ),
                          Text(
                            widget.title_5,
                            style: Styles.black16(context),
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
                onTap: widget.onTap6,
                child: Container(
                  height: 80,
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
                        widget.icon_6,
                        size: 40,
                        color: Styles.primaryColorIcons,
                      ),
                      Text(
                        widget.title_6,
                        style: Styles.black16(context),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap7,
                child: Container(
                  height: 80,
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
                        widget.icon_7,
                        size: 40,
                        color: Styles.primaryColorIcons,
                      ),
                      Text(
                        widget.title_7,
                        style: Styles.black16(context),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap8,
                child: Container(
                  height: 80,
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
                        widget.icon_8,
                        size: 40,
                        color: Styles.primaryColorIcons,
                      ),
                      Text(
                        widget.title_8,
                        style: Styles.black16(context),
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
