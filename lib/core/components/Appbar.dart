import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/core/utils/tost_util.dart';
import 'package:_12sale_app/data/service/connectivityService.dart';
import 'package:flutter/material.dart';

class AppbarCustom extends StatefulWidget {
  final String title;
  final IconData? icon;

  AppbarCustom({
    Key? key,
    required this.title,
    this.icon,
  }) : super(key: key);

  @override
  State<AppbarCustom> createState() => _AppbarCustomState();
}

class _AppbarCustomState extends State<AppbarCustom> {
  bool isConnected = true; // Default connectivity state

  @override
  void initState() {
    super.initState();
    // Subscribe to connectivity changes
    ConnectivityService().connectivityStream.listen((connectionState) {
      if (mounted) {
        setState(() {
          isConnected = connectionState;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 50,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(15),
        ),
        child: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              size: screenWidth / 20,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                widget.icon,
                size: screenWidth / 15,
              ),
              Text(widget.title),
            ],
          ),
          // actions: [
          //   Container(
          //     margin: const EdgeInsets.only(right: 30),
          //     height: screenWidth / 20,
          //     width: screenWidth / 20,
          //     decoration: BoxDecoration(
          //       color: isConnected ? Colors.green : Colors.red,
          //       border: Border.all(
          //         width: 4,
          //         color: isConnected
          //             ? Styles.successButtonColor
          //             : Styles.failTextColor,
          //       ),
          //       borderRadius: const BorderRadius.all(Radius.circular(360)),
          //       boxShadow: const [
          //         BoxShadow(
          //           color: Colors.black26,
          //           blurRadius: 10,
          //           spreadRadius: 2,
          //           offset: Offset(0, -3),
          //         ),
          //       ],
          //     ),
          //   ),
          // ],
          centerTitle: true,
          foregroundColor: Colors.white,
          titleTextStyle: Styles.headerWhite32(context),
          backgroundColor: Styles.primaryColor,
        ),
      ),
    );
  }
}
