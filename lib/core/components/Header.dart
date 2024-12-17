import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/core/utils/tost_util.dart';
import 'package:_12sale_app/data/service/connectivityService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:toastification/toastification.dart';

class Header extends StatefulWidget {
  final String? title;
  final Widget? leading;
  final Widget? leading2;

  const Header({
    Key? key,
    this.title,
    this.leading,
    this.leading2,
  }) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool? lastConnectedState; // Tracks the last connectivity state

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: StreamBuilder<bool>(
                stream: ConnectivityService().connectivityStream,
                builder: (context, snapshot) {
                  bool isConnected = snapshot.data ?? true;

                  // Trigger toast only when the `isConnected` state changes
                  if (lastConnectedState != isConnected) {
                    lastConnectedState = isConnected;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showToast(
                        context: context,
                        message: isConnected
                            ? 'gobal.header.online_status'.tr()
                            : 'gobal.header.offline_status'.tr(),
                        type: isConnected
                            ? ToastificationType.success
                            : ToastificationType.error,
                        primaryColor: isConnected ? Colors.green : Colors.red,
                      );
                    });
                  }
                  //  Container(
                  //             height: screenWidth / 20,
                  //             width: screenWidth / 20,
                  //             decoration: BoxDecoration(
                  //               color:
                  //                   isConnected ? Colors.green : Colors.red,
                  //               border: Border.all(
                  //                 width: screenWidth / 200,
                  //                 color: isConnected
                  //                     ? Styles.successButtonColor
                  //                     : Styles.failTextColor,
                  //               ),
                  //               borderRadius: const BorderRadius.all(
                  //                   Radius.circular(360)),
                  //               boxShadow: const [
                  //                 BoxShadow(
                  //                   color: Colors.black26,
                  //                   blurRadius: 10,
                  //                   spreadRadius: 2,
                  //                   offset: Offset(0, -3),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  return Container(
                    color: Styles.primaryColor,
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                color: Styles.primaryColor,
                                height: screenWidth / 4,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: SizedBox(child: widget.leading2),
                              ),
                              Transform.translate(
                                offset: Offset(screenWidth - 50, -10),
                                child: Container(
                                  margin: EdgeInsets.only(right: 50, top: 20),
                                  height: screenWidth / 20,
                                  width: screenWidth / 20,
                                  decoration: BoxDecoration(
                                    color:
                                        isConnected ? Colors.green : Colors.red,
                                    border: Border.all(
                                      width: screenWidth / 200,
                                      color: isConnected
                                          ? Styles.successButtonColor
                                          : Styles.failTextColor,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(360)),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: Offset(0, -3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            flex: 4,
                            fit: FlexFit.loose,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 5),
                                    blurRadius: 100,
                                    spreadRadius: 10,
                                  ),
                                ],
                                color: Colors.grey[100],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(46),
                                ),
                              ),
                              child: widget.leading!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
