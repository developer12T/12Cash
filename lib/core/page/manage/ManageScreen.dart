import 'package:_12sale_app/core/components/search/CustomerDropdownSearch.dart';
import 'package:_12sale_app/core/components/table/ShopTableNew.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  bool _isSelected = false;
  @override
  Widget build(BuildContext context) {
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
                //         style: Styles.black18(context),
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
                //       child: Text(
                //         'รายการคืน',
                //         style: Styles.black18(context),
                //       ),
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
                //     ),
                //   ),
                // )
              ],
            ),
          ),
          // _isSelected ? ShopTableNew() : Reportsaletable(),
          // Spacer(),
        ],
      ),
    );
  }
}

class ManageHeader extends StatefulWidget {
  const ManageHeader({super.key});

  @override
  State<ManageHeader> createState() => _ManageHeaderState();
}

class _ManageHeaderState extends State<ManageHeader> {
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
                                  Icon(Icons.inventory,
                                      size: screenWidth / 15,
                                      color: Colors.white),
                                  Text(
                                    ' จัดการ',
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
