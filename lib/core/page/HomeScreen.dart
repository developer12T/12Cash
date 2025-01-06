import 'dart:async';
import 'dart:convert';

import 'package:_12sale_app/core/components/card/StoreCardAll.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchCustom.dart';
import 'package:_12sale_app/core/page/dashboard/DashboardScreen.dart';
import 'package:_12sale_app/core/page/manage/ManageScreen.dart';
import 'package:_12sale_app/core/page/report/ReportScreen.dart';
import 'package:_12sale_app/core/page/route/OrderScreen.dart';
import 'package:_12sale_app/core/page/route/RouteScreen.dart';
import 'package:_12sale_app/core/page/setting/SettingScreen.dart';
import 'package:_12sale_app/core/page/store/ProcessTimelineScreen.dart';
import 'package:_12sale_app/core/page/store/StoreScreen.dart';
// import 'package:_12sale_app/page/TestTabel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:_12sale_app/core/components/Header.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Order.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/requestPremission.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
  int _selectedIndex = 0;
  bool _loading = true;
  List<Store> storeItem = [];

  List<Store> allStores = [];

  List<String> filteredItems = [];
  TextEditingController searchController = TextEditingController();

  static const List<Widget> _widgetOptionsHeader = <Widget>[
    DashboardHeader(),
    RouteHeader(),
    StoreHeader(),
    ReportHeader(),
    ManageHeader(),
    // SettingHeader(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Order> _orders = <Order>[];

  Future<void> _clearOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('orders'); // Clear orders from SharedPreferences
    // await prefs.remove('ท'); // Clear orders from SharedPreferences
    setState(() {
      _orders.clear(); // Clear orders in the UI
    });
  }

  Future<void> _getStoreAll() async {
    // Initialize Dio
    Dio dio = Dio();

    // Replace with your API endpoint
    const String apiUrl =
        "https://f8c3-171-103-242-50.ngrok-free.app/api/cash/store/getStore?area=BE214&type=all";

    try {
      final response = await dio.get(
        apiUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        // print(response.data['data']);
        setState(() {
          storeItem = data.map((item) => Store.fromJson(item)).toList();
        });
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loading = false;
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
    // TODO: implement initState
    super.initState();
    _selectedIndex = widget.index; //_selectedIndex
    _clearOrders();
    searchController.addListener(() {
      _filterItems(searchController.text);
    });
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

  void _getFuction() {
    switch (_selectedIndex) {
      case 0:
        return () {}();
      case 1:
        return () {}();
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
        return () {
          _showSearchModal();
        }();
      default:
        return () {}();
    }
  }

  Icon _getIcon() {
    switch (_selectedIndex) {
      case 0:
        return const Icon(
          Icons.home,
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
        return const Icon(
          Icons.add_shopping_cart,
          size: 40,
          color: Styles.primaryColor,
        );
      default:
        return const Icon(Icons.shopping_basket, size: 30);
    }
  }

  void _showSearchModal() {
    _getStoreAll();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Make modal take full screen if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          color: Colors.transparent,
          child: Column(
            children: [
              // Container(
              //   color: Styles.primaryColor,
              //   height: 100,
              // ),
              Container(
                height: MediaQuery.of(context).size.height / 7,
                decoration: const BoxDecoration(
                  color: Styles.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child:
                    Text("เลือกร้านค้า ", style: Styles.headerWhite32(context)),
              ),
              Padding(
                padding:
                    MediaQuery.of(context).viewInsets, // Adjust for keyboard
                child: Container(
                  padding: const EdgeInsets.all(16),
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: searchController,
                        style: Styles.black18(context),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintStyle: Styles.black18(context),
                          hintText: 'ค้นหา...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (query) {
                          print(query);
                          _filterItems(
                              query); // Filter items on every keystroke
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Skeletonizer(
                          effect: const PulseEffect(
                              from: Colors.grey,
                              to: Color.fromARGB(255, 211, 211, 211),
                              duration: Duration(seconds: 1)),
                          enabled: _loading,
                          enableSwitchAnimation: true,
                          child: ListView.builder(
                            itemCount: storeItem.length,
                            itemBuilder: (context, index) {
                              return StoreCartAll(
                                textDetail: 'ขายสินค้า',
                                item: storeItem[index],
                                onDetailsPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Orderscreen(
                                          customerNo: storeItem[index].storeId,
                                          customerName: storeItem[index].name,
                                          status: storeItem[index].status),
                                    ),
                                  );
                                },
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
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Dashboardscreen(),
      Routescreen(),
      StoreScreen(),
      ReportScreen(),
      ManageScreen(),
      SettingScreen(),
    ];
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Header(
        leading: _widgetOptions.elementAt(_selectedIndex),
        leading2: _widgetOptionsHeader.elementAt(_selectedIndex),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
      floatingActionButton: Container(
        width: screenWidth / 9,
        height: screenWidth / 9,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Styles.secondaryColor,
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
            _getFuction();
            // setState(() {
            //   _selectedIndex = 2; // Update to the cart index
            // });
          },
          backgroundColor: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [_getIcon()],
          ),
        ),
      ),
      // body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Styles.primaryColor, // Primary color of the navigation bar
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26, // Shadow color
              blurRadius: 10, // Soft blur effect
              spreadRadius: 2, // Spread of the shadow
              offset: Offset(0, -3), // Shadow positioned upwards
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
            selectedItemColor: Styles.white,
            backgroundColor: Styles.primaryColor,
            unselectedItemColor: Styles.grey,
            unselectedLabelStyle: Styles.grey12(context),
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
