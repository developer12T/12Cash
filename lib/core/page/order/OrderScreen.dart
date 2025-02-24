import 'dart:convert';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/button/CartButton.dart';
import 'package:_12sale_app/core/components/dropdown/DropDownStandarad.dart';
import 'package:_12sale_app/core/components/table/OrderTable.dart';
import 'package:_12sale_app/core/page/route/ShoppingCartScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Order.dart';
import 'package:_12sale_app/data/models/ProductType.dart';

class Orderscreen extends StatefulWidget {
  final String customerNo;
  final String customerName;
  final String status;

  const Orderscreen({
    super.key,
    required this.customerNo,
    required this.customerName,
    required this.status,
  });

  @override
  State<Orderscreen> createState() => _OrderscreenState();
}

class _OrderscreenState extends State<Orderscreen> with RouteAware {
  ProductType? productData;
  int cartItemCount = 0;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrdersFromStorage();
    _loadProductType();
  }

  Future<void> _loadProductType() async {
    final String jsonString =
        await rootBundle.loadString('data/product_group.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    setState(() {
      productData = ProductType.fromJson(jsonData);
    });
  }

  Future<void> _loadOrdersFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonOrders = prefs.getStringList('orders');
    print("Oreder loading...");
    setState(() {
      if (jsonOrders != null) {
        _orders = jsonOrders
            .map((jsonOrder) => Order.fromJson(jsonDecode(jsonOrder)))
            .toList();
        cartItemCount = _orders.length;
      }
    });
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
    // Called when the screen is popped back to
    _loadOrdersFromStorage();
  }

  @override
  void dispose() {
    // Unsubscribe when the widget is disposed
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // @override
  // void didUpdateWidget(covariant Orderscreen oldWidget) {
  //   // TODO: implement didUpdateWidget
  //   super.didUpdateWidget(oldWidget);
  //   _loadOrdersFromStorage();
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " ${"route.order_screen.title".tr()}",
          icon: Icons.event,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${"route.order_screen.title".tr()} ${widget.customerNo}",
                style: Styles.headerBlack24(context),
              ),
              Text(
                "ร้าน ${widget.customerName}",
                style: Styles.headerBlack24(context),
              ),
              SizedBox(height: screenWidth / 80),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      child: productData != null
                          ? BoxShadowCustom(
                              child: DropDownStandard(
                                hintText:
                                    "route.order_screen.dropdown.group".tr(),
                                selectedValue: productData!.group.first,
                                items: productData!.group,
                                onChanged: (String? newValue) {},
                              ),
                            )
                          : CircularProgressIndicator(),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      child: productData != null
                          ? BoxShadowCustom(
                              child: DropDownStandard(
                                hintText:
                                    "route.order_screen.dropdown.brand".tr(),
                                selectedValue: productData!.brand.first,
                                items: productData!.brand,
                                onChanged: (String? newValue) {},
                              ),
                            )
                          : CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth / 80),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      child: productData != null
                          ? BoxShadowCustom(
                              child: DropDownStandard(
                                hintText:
                                    "route.order_screen.dropdown.size".tr(),
                                selectedValue: productData!.size.first,
                                items: productData!.size,
                                onChanged: (String? newValue) {},
                              ),
                            )
                          : CircularProgressIndicator(),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      child: productData != null
                          ? BoxShadowCustom(
                              child: DropDownStandard(
                                hintText:
                                    "route.order_screen.dropdown.flavour".tr(),
                                selectedValue: productData!.flavour.first,
                                items: productData!.flavour,
                                onChanged: (String? newValue) {},
                              ),
                            )
                          : CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth / 80),
              OrderTable(
                customerNo: widget.customerNo,
                customerName: widget.customerName,
                status: widget.status,
              ),
              SizedBox(height: screenWidth / 80),
            ],
          ),
        ),
      ),
      floatingActionButton: Cartbutton(
        count: "${_orders.length}",
        screen: ShoppingCartScreen(
          customerNo: widget.customerNo,
          customerName: widget.customerName,
          status: widget.status,
        ),
      ),
    );
  }
}
