import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StoreCartNew extends StatelessWidget {
  final Store item;
  final VoidCallback onDetailsPressed;

  const StoreCartNew({
    Key? key,
    required this.item,
    required this.onDetailsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name,
                  style: Styles.headerBlack24(context),
                ),
                Skeleton.ignore(
                  child: Container(
                    width: screenWidth / 6,
                    padding: EdgeInsets.all(4),
                    // height: screenWidth / ,
                    decoration: BoxDecoration(
                      color: item.status == '10'
                          ? Styles.warningTextColor
                          : item.status == '90'
                              ? Styles.failTextColor
                              : Styles.successTextColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      item.status == '10'
                          ? 'store.store_card_new.pendding'.tr()
                          : item.status == '90'
                              ? 'store.store_card_new.reject'.tr()
                              : 'อนุมัติ',
                      style: Styles.white18(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            Text.rich(
              TextSpan(
                text:
                    '${'store.store_card_new.storeId'.tr()} : ', // This is the main text style
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
                    '${'store.store_card_new.route'.tr()} : ', // This is the main text style
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
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '${"store.store_card_all.address".tr()} : ',
                        style: Styles.headerBlack18(context),
                      ),
                      Expanded(
                        child: Text(
                          item.address,
                          style: Styles.black18(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Skeleton.ignore(
                    child: Text('store.store_card_all.detail'.tr(),
                        style: Styles.grey18(context))),
              ],
            ),
            Divider(color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
