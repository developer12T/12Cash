import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InvoiceCard extends StatelessWidget {
  final Store item;
  final VoidCallback onDetailsPressed;
  const InvoiceCard({
    required this.item,
    required this.onDetailsPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onDetailsPressed,
      child: Container(
        height: screenWidth / 5,
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: BoxShadowCustom(
          child: Container(
            // color: Colors.cyan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        child: FaIcon(
                          FontAwesomeIcons.fileInvoice,
                          color: Styles.primaryColor,
                          size: 35,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "21 Dec 2025 | 17:00",
                                style: Styles.black18(context),
                              ),
                              Skeleton.ignore(
                                child: Container(
                                  width: screenWidth / 7,
                                  // padding: EdgeInsets.all(4),
                                  margin: EdgeInsets.only(right: 8),
                                  // height: screenWidth / ,
                                  decoration: BoxDecoration(
                                    color: item.policyConsent.status == 'Agree'
                                        ? Styles.successTextColor
                                        : item.policyConsent.status == 'Reject'
                                            ? Styles.failTextColor
                                            : Styles.warningTextColor,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    item.policyConsent.status == 'Agree'
                                        ? 'store.store_card_new.agree'.tr()
                                        : item.policyConsent.status == 'Reject'
                                            ? 'store.store_card_new.reject'.tr()
                                            : 'store.store_card_new.pendding'
                                                .tr(),
                                    style: Styles.white18(context),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "2021452148",
                            style: Styles.black18(context),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.locationDot,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    (item.address.length +
                                                item.subDistrict.length +
                                                item.district.length +
                                                item.province.length) >
                                            25
                                        ? ' ${item.address} ${item.province != 'กรุงเทพมหานคร' ? 'ต.' : 'แขวง'}${item.subDistrict} ${item.province != 'กรุงเทพมหานคร' ? 'อ.' : 'เขต'}${item.district}...' // Limit to 22 characters + ellipsis
                                        : " ${item.address} ${item.province != 'กรุงเทพมหานคร' ? 'ต.' : 'แขวง'}${item.subDistrict} ${item.province != 'กรุงเทพมหานคร' ? 'อ.' : 'เขต'}${item.district}  ${item.province != 'กรุงเทพมหานคร' ? 'จ.' : ''}${item.province} ${item.postCode}",
                                    style: Styles.black18(context),
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 25),
                                child: FaIcon(
                                  // FontAwesomeIcons.circleXmark,
                                  FontAwesomeIcons.circleCheck,
                                  color: Colors.green,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       "21 Dec 2025 | 17:00",
                //       style: Styles.black18(context),
                //     ),
                //     Text(
                //       "21 Dec 2025 | 17:00",
                //       style: Styles.black18(context),
                //     ),
                //   ],
                // ),
                // Text.rich(
                //   TextSpan(
                //     text:
                //         '${'store.store_card_new.storeId'.tr()} : ', // This is the main text style
                //     style: Styles.headerBlack18(context),
                //     children: <TextSpan>[
                //       TextSpan(
                //         text: item.storeId, // Inline bold text
                //         style: Styles.black18(context),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Row(
//   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     Container(
//       color: Colors.red,
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(8),
//                     margin: EdgeInsets.symmetric(horizontal: 4),
//                     child: FaIcon(
//                       FontAwesomeIcons.fileInvoice,
//                       color: Styles.primaryColor,
//                       size: 50,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 color: Colors.amber,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//                     Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               "21 Dec 2025 | 17:00",
//                               style: Styles.black18(context),
//                             ),
//                             Skeleton.ignore(
//                               child: Container(
//                                 width: screenWidth / 6,
//                                 padding: EdgeInsets.all(4),
//                                 // height: screenWidth / ,
//                                 decoration: BoxDecoration(
//                                   color: item.policyConsent
//                                               .status ==
//                                           'Agree'
//                                       ? Styles.successTextColor
//                                       : item.policyConsent
//                                                   .status ==
//                                               'Reject'
//                                           ? Styles.failTextColor
//                                           : Styles
//                                               .warningTextColor,
//                                   borderRadius:
//                                       BorderRadius.circular(8.0),
//                                 ),
//                                 child: Text(
//                                   item.policyConsent.status ==
//                                           'Agree'
//                                       ? 'store.store_card_new.agree'
//                                           .tr()
//                                       : item.policyConsent
//                                                   .status ==
//                                               'Reject'
//                                           ? 'store.store_card_new.reject'
//                                               .tr()
//                                           : 'store.store_card_new.pendding'
//                                               .tr(),
//                                   style: Styles.white18(context),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           "2021452148",
//                           style: Styles.black18(context),
//                         ),
//                         Row(
//                           children: [
//                             FaIcon(
//                               FontAwesomeIcons.locationDot,
//                               color: Colors.grey,
//                             ),
//                             Text(
//                               (item.address.length +
//                                           item.subDistrict
//                                               .length +
//                                           item.district.length +
//                                           item.province.length) >
//                                       25
//                                   ? ' ${item.address} ${item.province != 'กรุงเทพมหานคร' ? 'ต.' : 'แขวง'}${item.subDistrict} ${item.province != 'กรุงเทพมหานคร' ? 'อ.' : 'เขต'}${item.district}...' // Limit to 22 characters + ellipsis
//                                   : " ${item.address} ${item.province != 'กรุงเทพมหานคร' ? 'ต.' : 'แขวง'}${item.subDistrict} ${item.province != 'กรุงเทพมหานคร' ? 'อ.' : 'เขต'}${item.district}  ${item.province != 'กรุงเทพมหานคร' ? 'จ.' : ''}${item.province} ${item.postCode}",
//                               style: Styles.black18(context),
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   ],
// ),
