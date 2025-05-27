import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld.dart';
import 'package:_12sale_app/core/components/camera/IconButtonWithLabelOld2.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  String storeImagePath = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " ส่งเงิน",
          icon: Icons.payments_rounded,
        ),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ยอดส่งเงินประจำวันที่ ${DateFormat('d MMMM yyyy', 'dashboard.lange'.tr()).format(DateTime.now())}",
              style: Styles.black24(context),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(10000)}",
              style: Styles.headerGreen32(context),
              textAlign: TextAlign.end,
            ),
            Text(
              "สถานะ : ยังไม่ส่งเงิน",
              style: Styles.headerRed24(context),
              textAlign: TextAlign.end,
            ),
            SizedBox(
              height: 16,
            ),
            IconButtonWithLabelOld2(
              icon: Icons.photo_camera,
              imagePath: storeImagePath != "" ? storeImagePath : null,
              label: "ใบเงินฝาก",
              onImageSelected: (String imagePath) async {
                // await uploadFormDataWithDio(imagePath, 'store', context);
              },
            ),
            SizedBox(
              height: 16,
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                "กดเพื่อส่งเงิน",
                style: "dw" == "dw"
                    ? Styles.pirmary18(context)
                    : Styles.grey18(context),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: "dw" == "dw" ? Styles.primaryColor : Colors.grey,
                    width: 1,
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
