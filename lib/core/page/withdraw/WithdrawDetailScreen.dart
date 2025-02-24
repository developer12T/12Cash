import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/withdraw/WithdrawDetail.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:flutter/material.dart';

class WithdrawDetailScreen extends StatefulWidget {
  final orderId;
  const WithdrawDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<WithdrawDetailScreen> createState() => _WithdrawDetailScreenState();
}

class _WithdrawDetailScreenState extends State<WithdrawDetailScreen> {
  List<WithdrawDetail> withdrawDetail = [];
  @override
  void initState() {
    super.initState();
    _getWithdrawDetail();
  }

  Future<void> _getWithdrawDetail() async {
    try {
      print("Order ID : ${widget.orderId}");
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/distribution/detail/${widget.orderId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        for (var element in response.data['data']) {
          final Map<String, dynamic> data = element;
          setState(() {
            withdrawDetail.add(WithdrawDetail.fromJson(data));
          });
        }
      }
    } catch (e) {
      print("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " รายละเอียดการเบิกสินค้า",
          icon: Icons.local_shipping_outlined,
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  BoxShadowCustom(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "เลขที่ ${withdrawDetail[0].orderId}",
                                style: Styles.black24(context),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "จากศูนย์ ${withdrawDetail[0].fromWarehouse} ไป ${withdrawDetail[0].toWarehouse}",
                                style: Styles.black18(context),
                              ),
                            ],
                          ),
                          // Text(
                          //   "เลขที่ ${withdrawDetail[0].orderTypeName}",
                          //   style: Styles.black18(context),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
