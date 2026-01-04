import 'dart:async';
import 'package:_12sale_app/core/page/dashboard/DashboardScreen.dart';
import 'package:_12sale_app/core/page/refund/RefundScreen.dart';
import 'package:_12sale_app/core/page/report/ReportScreen.dart';
import 'package:_12sale_app/core/page/route/AjustRoute.dart';
import 'package:_12sale_app/core/page/order/OrderOutRouteScreen.dart';
import 'package:_12sale_app/core/page/route/RouteScreen.dart';
import 'package:_12sale_app/core/page/store/ProcessTimelineScreen.dart';
import 'package:_12sale_app/core/page/store/SearchStore.dart';
import 'package:_12sale_app/core/page/store/StoreScreen.dart';
import 'package:_12sale_app/data/models/CartAll.dart';
import 'package:_12sale_app/data/models/RefundFilter.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/sockertService.dart';
// import 'package:_12sale_app/page/TestTabel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:_12sale_app/core/components/Header.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Order.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class HomeScreen extends StatefulWidget {
  final int index;
  final String? imagePath;

  const HomeScreen({
    super.key,
    required this.index,
    this.imagePath,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedIndex = widget.index; //_selectedIndex
    // _clearOrders();
    searchController.addListener(() {
      _filterItems(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;
  List<Store> storeItem = [];
  List<Store> allStores = [];
  List<String> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  List<CartAll> cartList = [];
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  static const List<Widget> _widgetOptionsHeader = <Widget>[
    DashboardHeader(),
    RouteHeader(),
    StoreHeader(),
    ReportHeader(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _getCartAll() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/cart/getAll?area=${User.area}&period=${period}', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      print("Data ${response.data['data']}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];

        if (mounted) {
          setState(() {
            // _loadingCart = false;
            cartList = data.map((item) => CartAll.fromJson(item)).toList();
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _clearCart() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
          endpoint:
              'api/cash/cart/clearcart', // You only need to pass the endpoint, the base URL is handled
          method: 'POST',
          body: {
            "period": period,
            "cartAll": cartList,
          });
      if (response.statusCode == 200 || response.statusCode == 201) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "เคลียตะกร้าเรียบร้อย",
            style: Styles.green18(context),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void _filterItems(String query) {
    setState(
      () {
        if (query.isEmpty) {
          storeItem = allStores; // Reset to the original full list
        } else {
          storeItem = allStores
              .where((item) => item.name.toLowerCase().contains(query
                  .toLowerCase())) // Assuming `name` is the field to filter
              .toList();
        }
      },
    );
  }

  void _getFuction(int isSelect) async {
    switch (_selectedIndex) {
      case 0:
        return () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchStore(),
            ),
          );
        }();
      case 1:
        return () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SearchStore(),
          //   ),
          // );
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => AjustRoute(),
          //   ),
          // );
        }();
      case 2:
        return () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProcessTimelinePage(),
            ),
          );
        }();
      case 3:
        return () async {
          if (isSelect == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderOutRouteScreen(),
              ),
            );
          } else if (isSelect == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RefundScreen(),
              ),
            );
          } else {
            await _getCartAll();
            await _clearCart();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(
                  index: 3,
                ),
              ),
            );
          }
        }();
      default:
        return () {}();
    }
  }

  Icon _getIcon(int isSelect) {
    switch (_selectedIndex) {
      case 0:
        return const Icon(
          Icons.search_outlined,
          size: 40,
          color: Styles.primaryColor,
        );
      case 1:
        return const Icon(
          Icons.add_location_alt_outlined,
          size: 40,
          color: Styles.primaryColor,
        );
      case 2:
        return const Icon(
          Icons.add_business,
          size: 40,
          color: Styles.primaryColor,
        );
      case 3:
        return isSelect == 1
            ? const Icon(
                Icons.add_shopping_cart,
                size: 40,
                color: Styles.primaryColor,
              )
            : isSelect == 2
                ? const Icon(
                    Icons.change_circle_outlined,
                    size: 40,
                    color: Styles.primaryColor,
                  )
                : const Icon(
                    Icons.cleaning_services,
                    size: 40,
                    color: Styles.primaryColor,
                  );
      default:
        return const Icon(Icons.shopping_basket, size: 30);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // final socketService = Provider.of<SocketService>(context);
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) {
    //     print(
    //         '${socketService.updateStoreStatus} socketService.updateStoreStatus');
    //     if (socketService.updateStoreStatus != '') {
    //       toastification.show(
    //         context: context,
    //         title: Text(
    //           socketService.updateStoreStatus,
    //           style: Styles.green18(context),
    //         ),
    //         style: ToastificationStyle.flatColored,
    //         primaryColor: Colors.green,
    //         autoCloseDuration: Duration(seconds: 5),
    //       );
    //     }
    //   },
    // );

    // // Listen for updates and show toast
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (socketService.latestMessage != '') {
    //     toastification.show(
    //       context: context,
    //       title: Text(
    //         socketService.latestMessage,
    //         style: Styles.green18(context),
    //       ),
    //       style: ToastificationStyle.flatColored,
    //       primaryColor: Colors.green,
    //       autoCloseDuration: Duration(seconds: 5),
    //     );
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final isSelect = Provider.of<RefundfilterLocal>(context);
    List<Widget> _widgetOptions = <Widget>[
      Dashboardscreen(),
      Routescreen(),
      StoreScreen(),
      ReportScreen(),
    ];
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Header(
          leading: _widgetOptions.elementAt(_selectedIndex),
          leading2: _widgetOptionsHeader.elementAt(_selectedIndex),
        ),
        // backgroundColor: Colors.amber,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        floatingActionButton: Container(
          width: screenWidth / 8,
          height: screenWidth / 8,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Styles.primaryColor,
            borderRadius: BorderRadius.circular(360),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.2), // Shadow color with transparency
                spreadRadius: 2, // Spread of the shadow
                blurRadius: 8, // Blur radius of the shadow
                offset: const Offset(
                    0, 4), // Offset of the shadow (horizontal, vertical)
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: 'homeTag1', // Unique tag for this FloatingActionButton
            shape: const CircleBorder(),
            onPressed: () {
              _getFuction(isSelect.isSelect);
              // setState(() {
              //   _selectedIndex = 2; // Update to the cart index
              // });
            },
            backgroundColor: Colors.white,
            child: Stack(
              alignment: Alignment.center,
              children: [_getIcon(isSelect.isSelect)],
            ),
          ),
        ),
        // body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            // color: Styles.primaryColor, // Primary color of the navigation bar
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // Shadow color
                spreadRadius: 2, // Spread of the shadow
                blurRadius: 8, // Blur radius of the shadow
                offset: Offset(0, 4), //
                blurStyle: BlurStyle.normal,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: FaIcon(
                    FontAwesomeIcons.house,
                  ),
                  label: "menu".tr(gender: "home"),
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(
                    FontAwesomeIcons.route,
                  ),
                  label: "menu".tr(gender: "route"),
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(
                    FontAwesomeIcons.shop,
                  ),
                  label: "menu".tr(gender: "shop"),
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(
                    FontAwesomeIcons.clipboardList,
                  ),
                  label: "menu".tr(
                    gender: "manage",
                  ),
                ),
              ],
              selectedLabelStyle: Styles.white18(context),
              iconSize: screenWidth / 20,
              currentIndex: _selectedIndex,
              selectedItemColor: Styles.primaryColor,
              backgroundColor: Styles.white,
              unselectedItemColor: Styles.grey,
              unselectedLabelStyle: Styles.grey12(context),
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            ),
          ),
        ),
      ),
    );
  }
}
