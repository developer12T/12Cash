import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class PromotionCard extends StatelessWidget {
  final Store item;
  final VoidCallback onDetailsPressed;

  const PromotionCard({
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
                Container(
                  width: screenWidth / 6,
                  padding: EdgeInsets.all(4),
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
                        ? 'อนุมัติ'
                        : item.policyConsent.status == 'Reject'
                            ? 'ไม่อนุมัติ'
                            : 'รออนุมัติ',
                    style: Styles.white18(context),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Text.rich(
              TextSpan(
                text: 'รหัสร้าน : ', // This is the main text style
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
                text: 'เส้นทาง : ', // This is the main text style
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
                    text: 'ที่อยู่ : ', // This is the main text style
                    style: Styles.headerBlack18(context),
                    children: <TextSpan>[
                      TextSpan(
                        text: item.address.length > 25
                            ? '${item.address.substring(0, 30)}. . .' // Limit to 22 characters + ellipsis
                            : item
                                .address, // Show full address if within 25 characters
                        style: Styles.black18(context),
                      ),
                    ],
                  ),
                ),
                Text('รายละเอียด', style: Styles.grey18(context)),
              ],
            ),
            Divider(color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
