import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BuildTextRowDetailShop.dart';
import 'package:_12sale_app/core/components/table/VerifyTable.dart';
import 'package:_12sale_app/core/styles/style.dart';

import 'package:flutter/material.dart';

class DetailReportScreen extends StatefulWidget {
  final String date;
  final String orderNo;
  final String customerNo;
  final String customerName;

  const DetailReportScreen(
      {super.key,
      required this.date,
      required this.orderNo,
      required this.customerNo,
      required this.customerName});

  @override
  State<DetailReportScreen> createState() => _DetailReportScreenState();
}

class _DetailReportScreenState extends State<DetailReportScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
            title: " รายละเอียดรายการ", icon: Icons.receipt_long_rounded),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.all(8.0),
        // color: Colors.red,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BuildTextRowDetailShop(
                text: "วันที่",
                value: widget.date,
                left: 3,
                right: 7,
              ),
              BuildTextRowDetailShop(
                text: "เลขที่ใบสั่งซื้อ",
                value: "699091322301",
                left: 3,
                right: 7,
              ),
              BuildTextRowDetailShop(
                text: "พนักงานขาย",
                value: "จิตรีน เชียงเหิน",
                left: 3,
                right: 7,
              ),
              BuildTextRowDetailShop(
                text: "รหัสร้านค้า",
                value: widget.customerNo,
                left: 3,
                right: 7,
              ),
              BuildTextRowDetailShop(
                text: "ชื่อร้านค้า",
                value: widget.customerName,
                left: 3,
                right: 7,
              ),
              BuildTextRowDetailShop(
                text: "ที่อยู่",
                value:
                    "99/บ้าน 99 ถนน 99 ต.99 อ.99 จ.99 รหัสไปรษณีย์ 99 โทร 99 โทรศัพท์ 99",
                left: 3,
                right: 7,
              ),
              BuildTextRowDetailShop(
                text: "เบอร์ร้าน",
                value: "09999999999",
                left: 3,
                right: 7,
              ),
              BuildTextRowDetailShop(
                text: "เลขที่ผู้เสียภาษี",
                value: "-",
                left: 3,
                right: 7,
              ),
              BuildTextRowDetailShop(
                text: "สถานนะรายการ",
                value: "สำเร็จ",
                left: 3,
                right: 7,
              ),
              VerifyTable(),
              SizedBox(height: screenWidth / 7),
              Divider(
                color: Colors.grey,
              ),
              BuildTextRowBetweenCurrency(
                  text: "ยอดรวม",
                  price: 800.00,
                  style: Styles.black18(context)),
              BuildTextRowBetweenCurrency(
                  text: "ส่วนลดท้ายบิล",
                  price: 8430.00,
                  style: Styles.black18(context)),
              BuildTextRowBetweenCurrency(
                  text: "ราคาไม่รวมภาษี",
                  price: 00.00,
                  style: Styles.black18(context)),
              BuildTextRowBetweenCurrency(
                  text: "ภาษี 7% (VAT)",
                  price: 7878.50,
                  style: Styles.black18(context)),
              BuildTextRowBetweenCurrency(
                  text: "ยอดชำระสุทธิ",
                  price: 8430.00,
                  style: Styles.black18(context)),
            ],
          ),
        ),
      ),
    );
  }
}
