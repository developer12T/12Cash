import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/DuplicateStore.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:flutter/material.dart';

class DuplicateCardStore extends StatelessWidget {
  final DuplicateStore item;
  final VoidCallback onDetailsPressed;
  String? textDetail;

  DuplicateCardStore(
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
                text: 'Zone : ', // This is the main text style
                style: Styles.headerBlack18(context),
                children: <TextSpan>[
                  TextSpan(
                    text: item.zone, // Inline bold text
                    style: Styles.black18(context),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'Area : ', // This is the main text style
                style: Styles.headerBlack18(context),
                children: <TextSpan>[
                  TextSpan(
                    text: item.area, // Inline bold text
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
                Text('$textDetail', style: Styles.grey18(context)),
              ],
            ),
            Divider(color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
