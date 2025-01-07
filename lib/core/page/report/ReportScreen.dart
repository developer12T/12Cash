import 'package:_12sale_app/core/components/search/CustomerDropdownSearch.dart';
import 'package:_12sale_app/core/components/table/ReportSaleTable.dart';
import 'package:_12sale_app/core/components/table/ShopTableAll.dart';
import 'package:_12sale_app/core/components/table/ShopTableNew.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isSelected = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            child: Row(
              children: [
                // Expanded(
                //   child: Container(
                //     margin: const EdgeInsets.symmetric(horizontal: 16),
                //     child: ElevatedButton(
                //       onPressed: () {
                //         setState(() {
                //           _isSelected = !_isSelected;
                //         });
                //       },
                //       style: ElevatedButton.styleFrom(
                //         elevation: 16, // Add elevation for shadow
                //         shadowColor: Colors.black
                //             .withOpacity(0.5), // Shadow color with opacity

                //         padding: const EdgeInsets.symmetric(
                //             vertical: 16, horizontal: 10),
                //         backgroundColor:
                //             _isSelected ? Colors.white : Colors.grey[300],

                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //       ),
                //       child: Text(
                //         'รายการขาย',
                //         style: Styles.headerBlack24(context),
                //       ),
                //     ),
                //   ),
                // ),
                // Expanded(
                //   child: Container(
                //     margin: const EdgeInsets.symmetric(horizontal: 16),
                //     child: ElevatedButton(
                //       onPressed: () {
                //         setState(() {
                //           _isSelected = !_isSelected;
                //         });
                //       },
                //       style: ElevatedButton.styleFrom(
                //         elevation: 16, // Add elevation for shadow
                //         shadowColor: Colors.black
                //             .withOpacity(0.5), // Shadow color with opacity
                //         padding: const EdgeInsets.symmetric(
                //             vertical: 16, horizontal: 10),
                //         backgroundColor:
                //             _isSelected ? Colors.grey[300] : Colors.white,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //       ),
                //       child: Text(
                //         'รายการคืน',
                //         style: Styles.headerBlack24(context),
                //       ),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
          // _isSelected ? const ShopTableNew() : const Reportsaletable(),
          // const Spacer(),
        ],
      ),
    );
  }
}

class ReportHeader extends StatefulWidget {
  const ReportHeader({super.key});

  @override
  State<ReportHeader> createState() => _ReportHeaderState();
}

class _ReportHeaderState extends State<ReportHeader> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),

                  // color: Colors.red,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/12TradingLogo.png'),
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                fit: FlexFit.loose,
                child: Center(
                  // margin: EdgeInsets.only(top: 10),

                  child: Column(
                    // mainAxisSize: MainAxisSize.max,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          // color: Colors.blue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.receipt_long_rounded,
                                      size: screenWidth / 15,
                                      color: Colors.white),
                                  Text(
                                    ' รายงานขาย',
                                    style: Styles.headerWhite24(context),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          // width: screenWidth / 3,
                          child: const CustomerDropdownSearch(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
