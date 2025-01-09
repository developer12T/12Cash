import 'dart:async';

import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/card/InvoiceCard.dart';
import 'package:_12sale_app/core/components/search/CustomerDropdownSearch.dart';
import 'package:_12sale_app/core/components/table/ReportSaleTable.dart';
import 'package:_12sale_app/core/components/table/ShopTableAll.dart';
import 'package:_12sale_app/core/components/table/ShopTableNew.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isSelected = false;
  List<Store> storeAll = [];
  bool _loadingAllStore = true;

  Future<void> _getStoreDataAll() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/store/getStore?area=${User.area}&type=all', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        print(response.data['data']);
        setState(() {
          storeAll = data.map((item) => Store.fromJson(item)).toList();
        });
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loadingAllStore = false;
            });
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // _loadStoreData();
    _getStoreDataAll();
    // _pagingController.addPageRequestListener((pageKey) {
    //   _fetchPage(pageKey);
    // });
    // requestLocation();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
          Colors.transparent, // set scaffold background color to transparent
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: EdgeInsets.all(screenWidth / 45),
          width: screenWidth,
          // color: Colors.red,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ยังไม่เปิดให้บริการ ",
                style: Styles.black32(context),
              ),
            ],
          ),
        ),

        // child: LoadingSkeletonizer(
        //   loading: _loadingAllStore,
        //   child: ListView.builder(
        //     itemCount: storeAll.length,
        //     itemBuilder: (context, index) {

        //       return InvoiceCard(
        //         item: storeAll[index],
        //         onDetailsPressed: () {
        //           // Navigator.push(
        //           //   context,
        //           //   MaterialPageRoute(
        //           //     builder: (context) => DetailStoreScreen(
        //           //         initialSelectedRoute:
        //           //             RouteStore(route: storeAll[index].route),
        //           //         store: storeAll[index],
        //           //         customerNo: storeAll[index].storeId,
        //           //         customerName: storeAll[index].name),
        //           //   ),
        //           // );
        //           // print(
        //           //     'imageList for ${storeAll[index].imageList[0].path}');
        //         },
        //       );
        //     },
        //   ),
        // ),
      ),
    );
  }
}

class ReportHeader extends StatefulWidget {
  const ReportHeader({super.key});

  @override
  State<ReportHeader> createState() => _ReportHeaderState();
}

class _ReportHeaderState extends State<ReportHeader> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  // color: Colors.red,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/12TradingLogo.png'),
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                fit: FlexFit.loose,
                child: Center(
                  // margin: EdgeInsets.only(top: 10),

                  child: Column(
                    // mainAxisSize: MainAxisSize.max,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          // color: Colors.blue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.receipt_long_rounded,
                                      size: screenWidth / 15,
                                      color: Colors.white),
                                  Text(
                                    ' รายงานขาย',
                                    style: Styles.headerWhite24(context),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          // width: screenWidth / 3,
                          child: const CustomerDropdownSearch(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
