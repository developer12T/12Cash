import 'dart:async';
import 'dart:convert';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/card/StoreCardAll.dart';
import 'package:_12sale_app/core/components/card/StoreCardNew.dart';
import 'package:_12sale_app/core/components/search/CustomerDropdownSearch.dart';
import 'package:_12sale_app/core/components/table/ShopTableAll.dart';
import 'package:_12sale_app/core/components/table/ShopTableNew.dart';
import 'package:_12sale_app/core/page/store/DetailStoreScreen.dart';
import 'package:_12sale_app/core/page/store/ProcessTimelineScreen.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class StoreScreen extends StatefulWidget {
  StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with RouteAware {
  bool _loadingAllStore = true;
  bool _loadingNewStore = true;
  bool _isSelected = false;
  List<Store> storeAll = [];
  List<Store> storeNew = [];

  static const _pageSize = 3;
  final PagingController<int, Store> _pagingController =
      PagingController(firstPageKey: 0);

  // final PagingController<int, BeerSummary> _pagingController =
  //     PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    // _loadStoreData();
    _getStoreDataAll();
    // _pagingController.addPageRequestListener((pageKey) {
    //   _fetchPage(pageKey);
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register this screen as a route-aware widget
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Only subscribe if the route is a P ageRoute
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    setState(() {
      _loadingAllStore = true;
      _loadingNewStore = true;
    });
    // Called when the screen is popped back to
    _getStoreDataAll();
    _getStoreDataNew();
  }

  @override
  void dispose() {
    // Unsubscribe when the widget is disposed
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Future<void> _fetchPage(int pageKey) async {
  //   try {
  //     final newItems = await getBeerList(pageKey, _pageSize);

  //     final isLastPage = newItems.length < _pageSize;

  //     if (isLastPage) {
  //       _pagingController.appendLastPage(newItems);
  //     } else {
  //       final nextPageKey = pageKey + newItems.length;
  //       _pagingController.appendPage(newItems, nextPageKey);
  //     }
  //   } catch (error) {
  //     _pagingController.error = error;
  //   }
  // }

  // Future<List<Store>> getBeerList(int pageKey, int pageSize) async {
  //   Dio dio = Dio();
  //   String apiUrl =
  //       "https://f8c3-171-103-242-50.ngrok-free.app/api/cash/store/addStore?pageKey=$pageKey&pageSize=$pageSize";

  //   try {
  //     final response = await dio.get(
  //       apiUrl,
  //       options: Options(
  //         headers: {
  //           "Content-Type": "application/json",
  //         },
  //       ),
  //     );
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = response.data['data'];
  //       setState(() {
  //         storeAll = data
  //             .map((item) =>
  //                 Store.fromJson(item['store'] as Map<String, dynamic>))
  //             .toList();
  //       });
  //       return storeAll;
  //     } else {
  //       throw [];
  //     }
  //   } catch (e) {
  //     return [];
  //   }
  // }
  Future<void> _getStoreDataNew() async {
    // Initialize Dio
    // Dio dio = Dio();

    // // Replace with your API endpoint
    // const String apiUrl =
    //     "http://192.168.44.57:8005/api/cash/store/getStore?area=BE214&type=new";

    try {
      // final response = await dio.get(
      //   apiUrl,
      //   options: Options(
      //     headers: {
      //       "Content-Type": "application/json",
      //     },
      //   ),
      // );

      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/store/getStore?area=BE211&type=new', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        // print(response.data['data']);
        setState(() {
          storeNew = data.map((item) => Store.fromJson(item)).toList();
        });
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loadingNewStore = false;
            });
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getStoreDataAll() async {
    // Initialize Dio
    // Dio dio = Dio();

    // // Replace with your API endpoint
    // const String apiUrl =
    //     "http://192.168.44.57:8005/api/cash/store/getStore?area=BE214&type=all";

    try {
      // final response = await dio.get(
      //   apiUrl,
      //   options: Options(
      //     headers: {
      //       "Content-Type": "application/json",
      //     },
      //   ),
      // );

      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/store/getStore?area=BE211&type=all', // You only need to pass the endpoint, the base URL is handled
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // set scaffold background color to transparent
      body: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(8.0),
        // color: Colors.amber,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isSelected != false) {
                        setState(() {
                          _isSelected = !_isSelected;
                        });
                      }
                      _getStoreDataAll();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 16, // Add elevation for shadow
                      shadowColor: Colors.black
                          .withOpacity(0.5), // Shadow color with opacity
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      backgroundColor:
                          _isSelected ? Colors.white : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "store.store_all".tr(),
                      style: Styles.headerBlack32(context),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isSelected != true) {
                        setState(() {
                          _isSelected = !_isSelected;
                        });
                      }
                      _getStoreDataNew();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 16,
                      shadowColor: Colors.black.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      backgroundColor:
                          _isSelected ? Colors.grey[300] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "store.store_new".tr(),
                      style: Styles.headerBlack32(context),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16), // Add spacing between buttons and list
            _isSelected
                ? Expanded(
                    child: LoadingSkeletonizer(
                      loading: _loadingNewStore,
                      child: BoxShadowCustom(
                        child: ListView.builder(
                          itemCount: storeNew.length,
                          itemBuilder: (context, index) {
                            return StoreCartNew(
                              item: storeNew[index],
                              onDetailsPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailStoreScreen(
                                        initialSelectedRoute: RouteStore(
                                            route: storeNew[index].route),
                                        store: storeNew[index],
                                        customerNo: storeNew[index].storeId,
                                        customerName: storeNew[index].name),
                                  ),
                                );
                                print('Details for ${storeNew[index].name}');
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: LoadingSkeletonizer(
                      loading: _loadingAllStore,
                      child: BoxShadowCustom(
                        child: ListView.builder(
                          itemCount: storeAll.length,
                          itemBuilder: (context, index) {
                            return StoreCartAll(
                              item: storeAll[index],
                              onDetailsPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailStoreScreen(
                                        initialSelectedRoute: RouteStore(
                                            route: storeAll[index].route),
                                        store: storeAll[index],
                                        customerNo: storeAll[index].storeId,
                                        customerName: storeAll[index].name),
                                  ),
                                );
                                // print(
                                //     'imageList for ${storeAll[index].imageList[0].path}');
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class StoreHeader extends StatefulWidget {
  const StoreHeader({super.key});

  @override
  State<StoreHeader> createState() => _StoreHeaderState();
}

class _StoreHeaderState extends State<StoreHeader> {
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
                                  Container(
                                    child: Icon(Icons.store,
                                        size: screenWidth / 10,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    ' ${"store.title".tr()}',
                                    style: Styles.headerWhite32(context),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Flexible(
          fit: FlexFit.tight,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CustomerDropdownSearch(),
          ),
        ),
      ],
    );
  }
}
