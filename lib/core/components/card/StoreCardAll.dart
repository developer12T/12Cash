import 'package:_12sale_app/core/page/dashboard/DashboardScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StoreCartAll extends StatelessWidget {
  final Store item;
  final VoidCallback onDetailsPressed;
  String? textDetail;

  StoreCartAll(
      {Key? key,
      required this.item,
      required this.onDetailsPressed,
      this.textDetail = "รายละเอียด"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetailsPressed,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        // margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: Styles.headerBlack24(context),
            ),
            Text.rich(
              TextSpan(
                text:
                    '${"store.store_card_all.storeId".tr()} : ', // This is the main text style
                style: Styles.headerBlack18(context),
                children: <TextSpan>[
                  TextSpan(
                    text: item.storeId, // Inline bold text
                    style: Styles.black18(context),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text:
                    '${"store.store_card_all.route".tr()} : ', // This is the main text style
                style: Styles.headerBlack18(context),
                children: <TextSpan>[
                  TextSpan(
                    text: item.route, // Inline bold text
                    style: Styles.black18(context),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: '${"store.store_card_all.address".tr()} : ',
                    style: Styles.headerBlack18(context),
                    children: <TextSpan>[
                      TextSpan(
                        text: (item.address.length +
                                    item.subDistrict.length +
                                    item.district.length +
                                    item.province.length) >
                                25
                            ? '${item.address} ${item.province != 'กรุงเทพมหานคร' ? 'ต.' : 'แขวง'}${item.subDistrict}...' // Limit to 22 characters + ellipsis
                            : "${item.address} ${item.province != 'กรุงเทพมหานคร' ? 'ต.' : 'แขวง'}${item.subDistrict} ${item.province != 'กรุงเทพมหานคร' ? 'อ.' : 'เขต'}${item.district}  ${item.province != 'กรุงเทพมหานคร' ? 'จ.' : ''}${item.province} ${item.postCode}",
                        style: Styles.black18(context),
                      ),
                    ],
                  ),
                ),
                Skeleton.ignore(
                    child: Text('$textDetail', style: Styles.grey18(context))),
              ],
            ),
            Divider(color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
