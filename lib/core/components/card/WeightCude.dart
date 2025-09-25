import 'dart:ui';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/layout/BuildTextRowDetailShop.dart';
import 'package:_12sale_app/core/page/3D_canvas/Ractangle3D.dart';
import 'package:_12sale_app/core/page/withdraw/UtilzeDetail.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/withdraw/Utilize.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WeightCudeCard extends StatefulWidget {
  const WeightCudeCard({super.key});

  @override
  State<WeightCudeCard> createState() => _WeightCudeCardState();
}

class _WeightCudeCardState extends State<WeightCudeCard> {
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  Utilize? utilize;

  @override
  void initState() {
    super.initState();
    _getUtilize();
  }

  Future<void> _getUtilize() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
        endpoint: 'api/cash/typetruck/utilize',
        body: {
          "area": '${User.area}',
          "period": "$period",
          "typetruck": "${User.typeTruck}",
        },
        method: 'POST',
      );
      print(response.data['data']);
      if (response.statusCode == 200) {
        setState(() {
          utilize = Utilize.fromJson(response.data['data']);
        });
      }
    } catch (e) {
      print("Error _getUtilize $e");
    }
  }

  // ฟังก์ชัน format number
  String formatNumber(double number) {
    final formatter = NumberFormat("#,###");
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return BoxShadowCustom(
      child: Container(
        height: screenWidth / 1.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "รายละเอียดของ Utilize",
                  style: Styles.black24(context),
                ),
              ],
            ),
            SizedBox(
              height: screenWidth / 15,
            ),
            Hero(
              tag: 'rectangle',
              child: GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => UtilzeDetail(),
                  //   ),
                  // );
                },
                child: WaterFilledRectangle(
                  layoutType: WaterRectLayoutType.threeSection,
                  width: screenWidth / 7,
                  height: screenWidth / 11,
                  depth: screenWidth / 8,
                  fillFreePercentage: utilize?.freePercentage ?? 0.0,
                  fillStockPercentage: utilize?.stockPercentage ?? 0.0,
                  fillWithdrawPercentage: utilize?.withdrawPercentage ?? 0.0,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BuildTextRowBetween(
                    text: "ประเภทรถ",
                    text2:
                        "รถ ${utilize?.type_name == "6W" ? "6 ล้อ" : utilize?.type_name == "4W" ? "4 ล้อ" : utilize?.type_name == "4WJ" ? "4 ล้อจัมโบ้" : ""}",
                    style: Styles.black18(context),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: BuildTextRowBetween(
                    text: "ความเร็วรถจำกัด",
                    text2:
                        "${formatNumber(utilize?.set_speed ?? 0.0)} กม./ชั่วโมง",
                    style: Styles.black18(context),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BuildTextRowBetween(
                    text: "น้ำหนักสุทธิคลัง",
                    text2: "${formatNumber(utilize?.net ?? 0.0)} กก.",
                    style: Styles.black18(context),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: BuildTextRowBetween(
                    text: "ความเร็วรถในเมือง",
                    text2:
                        "${formatNumber(utilize?.set_speed_city ?? 0.0)} กม./ชั่วโมง",
                    style: Styles.black18(context),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BuildTextRowBetween(
                    text: "น้ำหนักรถ",
                    text2: "${formatNumber(utilize?.total_weight ?? 0.0)} กก.",
                    style: Styles.black18(context),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: BuildTextRowBetween(
                    text: "น้ำหนักที่สามารถจุได้",
                    text2: "${formatNumber(utilize?.payload ?? 0.0)} กก.",
                    style: Styles.black18(context),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BuildTextRowBetween(
                    text: "พื้นที่ว่าง",
                    text2: "${formatNumber(utilize?.free ?? 0.0)} กก.",
                    style: Styles.black18(context),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: BuildTextRowBetween(
                    text: "คิดเป็น",
                    text2:
                        "${((utilize?.freePercentage ?? 0.0) * 100).toStringAsFixed(2)}%",
                    style: Styles.black18(context),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BuildTextRowBetween(
                    text: "ของที่ขอเบิก",
                    text2: "${formatNumber(utilize?.withdraw ?? 0.0)} กก.",
                    style: Styles.black18(context),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: BuildTextRowBetween(
                    text: "คิดเป็น",
                    text2:
                        "${((utilize?.withdrawPercentage ?? 0.0) * 100).toStringAsFixed(2)}%",
                    style: Styles.black18(context),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BuildTextRowBetween(
                    text: "ของในรถ",
                    text2: "${formatNumber(utilize?.stock ?? 0.0)} กก.",
                    style: Styles.black18(context),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: BuildTextRowBetween(
                    text: "คิดเป็น",
                    text2:
                        "${((utilize?.stockPercentage ?? 0.0) * 100).toStringAsFixed(2)}%",
                    style: Styles.black18(context),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BuildTextRowBetween(
                    text: "ของในรถ + ของที่ขอเบิก",
                    text2: "${formatNumber(utilize?.sum ?? 0.0)} กก.",
                    style: Styles.black18(context),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: BuildTextRowBetween(
                    text: "คิดเป็น",
                    text2:
                        "${((utilize?.sumPercentage ?? 0.0) * 100).toStringAsFixed(2)}%",
                    style: Styles.black18(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
