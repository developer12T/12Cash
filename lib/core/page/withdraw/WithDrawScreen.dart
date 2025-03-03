import 'dart:async';
import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/card/WeightCude.dart';
import 'package:_12sale_app/core/components/card/WithDrawCard.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/switch/example_1.dart';
import 'package:_12sale_app/core/components/switch/example_10.dart';
import 'package:_12sale_app/core/components/switch/example_11.dart';
import 'package:_12sale_app/core/components/switch/example_12.dart';
import 'package:_12sale_app/core/components/switch/example_13.dart';
import 'package:_12sale_app/core/components/switch/example_14.dart';
import 'package:_12sale_app/core/components/switch/example_15.dart';
import 'package:_12sale_app/core/components/switch/example_2.dart';
import 'package:_12sale_app/core/components/switch/example_3.dart';
import 'package:_12sale_app/core/components/switch/example_4.dart';
import 'package:_12sale_app/core/components/switch/example_5.dart';
import 'package:_12sale_app/core/components/switch/example_6.dart';
import 'package:_12sale_app/core/components/switch/example_7.dart';
import 'package:_12sale_app/core/components/switch/example_8.dart';
import 'package:_12sale_app/core/components/switch/example_9.dart';
import 'package:_12sale_app/core/components/switch/second_screen.dart';
import 'package:_12sale_app/core/page/withdraw/ProductWithdrowScreen.dart';
import 'package:_12sale_app/core/page/withdraw/WithdrawDetailScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/withdraw/Withdraw.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';

class WithDrawScreen extends StatefulWidget {
  const WithDrawScreen({super.key});

  @override
  State<WithDrawScreen> createState() => _WithDrawScreenState();
}

class _WithDrawScreenState extends State<WithDrawScreen> {
  bool _loading = true;
  List<Withdraw> withdrawList = [];
  int isSelect = 1;
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  Future<void> _getDetail({String status = "pending"}) async {
    try {
      context.loaderOverlay.hide();
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/distribution/get?type=${status}&area=${User.area}&period=${period}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        setState(() {
          withdrawList = data.map((item) => Withdraw.fromJson(item)).toList();
        });
        Timer(const Duration(milliseconds: 500), () {
          setState(() {
            _loading = false;
          });
        });
      }
    } catch (e) {
      print("Error $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " เบิกสินค้า",
          icon: Icons.store_mall_directory_rounded,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Styles.primaryColor,
        child: const Icon(
          Icons.add,
          color: Styles.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductWithdrowScreen(),
            ),
          );
        },
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WeightCudeCard(),
                    const SizedBox(height: 10),
                    CustomSlidingSegmentedControl<int>(
                      initialValue: 1,
                      isStretch: true,
                      children: {
                        1: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.clock,
                              color: isSelect == 1
                                  ? Styles.primaryColorIcons
                                  : Styles.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'รอส่ง',
                              style: isSelect == 1
                                  ? Styles.headerPirmary18(context)
                                  : Styles.headerWhite18(context),
                            )
                          ],
                        ),
                        2: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description,
                              color: isSelect == 2
                                  ? Styles.primaryColorIcons
                                  : Styles.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'ประวัติ',
                              style: isSelect == 2
                                  ? Styles.headerPirmary18(context)
                                  : Styles.headerWhite18(context),
                            ),
                          ],
                        )
                      },
                      onValueChanged: (v) async {
                        setState(() {
                          isSelect = v;
                        });
                        if (v == 1) {
                          await _getDetail(status: "pending");
                        } else {
                          await _getDetail(status: "history");
                        }
                      },
                      decoration: BoxDecoration(
                        color: Styles.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      thumbDecoration: BoxDecoration(
                        color: Styles.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(milliseconds: 300),
                    ),
                    const SizedBox(height: 10),
                    BoxShadowCustom(
                      child: Container(
                        height: viewportConstraints.maxHeight * 0.4,
                        child: LoadingSkeletonizer(
                          loading: _loading,
                          child: withdrawList.length > 0
                              ? ListView.builder(
                                  itemCount: withdrawList.length,
                                  itemBuilder: (context, index) {
                                    return WithDrawCard(
                                      item: withdrawList[index],
                                      onDetailsPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                WithdrawDetailScreen(
                                                    orderId: withdrawList[index]
                                                        .orderId),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "ไม่มีข้อมูล",
                                        style: Styles.black18(context),
                                      )
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
