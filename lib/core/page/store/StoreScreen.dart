import 'dart:async';
import 'dart:convert';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/card/store/StoreCardAll.dart';
import 'package:_12sale_app/core/components/card/store/StoreCardNew.dart';
import 'package:_12sale_app/core/components/search/CustomerDropdownSearch.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchCustom.dart';
import 'package:_12sale_app/core/components/search/StoreSearch.dart';
import 'package:_12sale_app/core/page/store/DetailNewStoreScreen.dart';
import 'package:_12sale_app/core/page/store/DetailStoreScreen.dart';
import 'package:_12sale_app/core/page/store/ProcessTimelineScreen.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/search/StoreFilterLocal.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/requestPremission.dart';
import 'package:_12sale_app/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

List<Store> storeAll = [];
List<Store> storeNew = [];
RouteStore selectedRoute = RouteStore(route: 'R01');
String filterRoute = 'R01';
bool _isSelected = false;
bool _loadingAllStore = true;
bool _loadingNewStore = true;

class StoreScreen extends StatefulWidget {
  StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with RouteAware {
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
    // requestLocation();
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

  Future<void> _getStoreDataNew() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/store/getStore?area=${User.area}&type=new',
        method: 'GET',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          storeNew = data.map((item) => Store.fromJson(item)).toList();
          // storeNewFilter = data.map((item) => Store.fromJson(item)).toList();
        });
        // setState(() {
        //   storeNew = [
        //     ...storeNewFilter
        //         .where((store) => store.route == selectedRoute.route)
        //   ];
        // });
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
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/store/getStore?area=${User.area}&type=all&route=${selectedRoute.route}',
        method: 'GET',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];

        // print(response.data['data']);
        setState(() {
          storeAll = data.map((item) => Store.fromJson(item)).toList();
          // storeAllFilter = data.map((item) => Store.fromJson(item)).toList();
        });
        // setState(() {
        //   storeAll = [
        //     ...storeAllFilter
        //         .where((store) => store.route == selectedRoute.route)
        //   ];
        // });
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
    final storeState = Provider.of<StoreLocal>(context);
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
                                    builder: (context) => DetailNewStoreScreen(
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
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              filterRoute = 'R01';
                              selectedRoute = RouteStore(route: 'R01');
                            });
                            ApiService apiService = ApiService();
                            await apiService.init();
                            var response = await apiService.request(
                              endpoint:
                                  'api/cash/store/getStore?area=${User.area}&type=all&route=${selectedRoute.route}',
                              method: 'GET',
                            );
                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              final List<dynamic> data = response.data['data'];
                              storeState.updateValue(data
                                  .map((item) => Store.fromJson(item))
                                  .toList());
                            }
                          },
                          edgeOffset: 0,
                          color: Colors.white,
                          backgroundColor: Styles.primaryColor,
                          child: ListView.builder(
                            itemCount: storeState.storeList.length > 0
                                ? storeState.storeList.length
                                : storeAll.length,
                            itemBuilder: (context, index) {
                              return StoreCartAll(
                                item: storeState.storeList.length > 0
                                    ? storeState.storeList[index]
                                    : storeAll[index],
                                onDetailsPressed: () {
                                  if (storeState.storeList.length > 0) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailStoreScreen(
                                            initialSelectedRoute: RouteStore(
                                                route: storeState
                                                    .storeList[index].route),
                                            store: storeState.storeList[index],
                                            customerNo: storeState
                                                .storeList[index].storeId,
                                            customerName: storeState
                                                .storeList[index].name),
                                      ),
                                    );
                                  } else {
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
                                  }
                                  // print(
                                  //     'imageList for ${storeAll[index].imageList[0].path}');
                                },
                              );
                            },
                          ),
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
  List<StoreFavoriteLocal> _storeFavoriteLocal = [];
  Future<void> _saveStoreFavoriteStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the list of Order objects to a list of maps (JSON)
    List<String> jsonOrders =
        _storeFavoriteLocal.map((store) => jsonEncode(store.toJson())).toList();

    // Save the JSON string list to SharedPreferences
    await prefs.setStringList('StoreFavoriteLocal', jsonOrders);
  }

  Future<List<RouteStore>> getRoutes(String filter) async {
    try {
      // Load the JSON file for districts
      final String response = await rootBundle.loadString('data/route.json');
      final data = json.decode(response);
      // Filter and map JSON data to District model based on selected province and filter
      final List<RouteStore> route =
          (data as List).map((json) => RouteStore.fromJson(json)).toList();
      // Group districts by amphoe
      return route;
    } catch (e) {
      print("Error occurred: $e");
      return [];
    }
  }

  Future<List<Store>> getStores(String filter) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/store/getStore?area=${User.area}&type=all', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      // print("ApiService: $response}");

      // // Checking if data is not null and returning the list of CustomerModel
      if (response != null) {
        return Store.fromJsonList(response.data['data']);
      }
      return [];
    } catch (e) {
      print("Error occurred: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeState = Provider.of<StoreLocal>(context);
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
        Flexible(
          fit: FlexFit.tight,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white,
                    ),
                    child: StoreSearch(
                      key: ValueKey(filterRoute),
                      onStoreSelected: (data) {
                        if (data != null) {
                          storeState.updateValue([data]);
                          print(
                              "storeState.storeList :${storeState.storeList}");
                          setState(
                            () {
                              selectedRoute = RouteStore(route: data.route);
                              _storeFavoriteLocal =
                                  storeState.storesFavoriteList;
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    // padding: EdgeInsets.all(8.0), // Add padding.
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white,
                    ),
                    child: DropdownSearchCustom<RouteStore>(
                      key: ValueKey('RouteSearch-${selectedRoute.route}'),
                      initialSelectedValue:
                          selectedRoute.route == '' ? null : selectedRoute,
                      label: "",
                      titleText:
                          "${"store.store_data_screen.input_route.name".tr()}",
                      fetchItems: (filter) => getRoutes(filter),
                      filterFn: (RouteStore product, String filter) {
                        return product.route != "R" &&
                            product.route
                                .toLowerCase()
                                .contains(filter.toLowerCase());
                      },
                      onChanged: (RouteStore? selected) async {
                        if (selected != null) {
                          setState(() {
                            filterRoute = selected.route;
                            selectedRoute = RouteStore(route: selected.route);
                          });
                          print("_isSelected ${_isSelected}");
                          if (_isSelected) {
                            // storeAll = [
                            //   ...storeAllFilter.where(
                            //       (store) => store.route == selected.route)
                            // ];
                          } else {
                            ApiService apiService = ApiService();
                            await apiService.init();
                            var response = await apiService.request(
                              endpoint:
                                  'api/cash/store/getStore?area=${User.area}&type=all&route=${selected.route}',
                              method: 'GET',
                            );
                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              final List<dynamic> data = response.data['data'];
                              storeState.updateValue(data
                                  .map((item) => Store.fromJson(item))
                                  .toList());
                            }
                            // storeAll = [
                            //   ...storeAllFilter.where(
                            //       (store) => store.route == selected.route)
                            // ];
                          }
                        }
                      },
                      itemAsString: (RouteStore data) => data.route,
                      itemBuilder: (context, item, isSelected) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                " ${item.route}",
                                style: Styles.black18(context),
                              ),
                              selected: isSelected,
                            ),
                            Divider(
                              color:
                                  Colors.grey[200], // Color of the divider line
                              thickness: 1, // Thickness of the line
                              indent: 16, // Left padding for the divider line
                              endIndent:
                                  16, // Right padding for the divider line
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
