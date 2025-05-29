import 'dart:async';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/card/order/InvoiceCard.dart';
import 'package:_12sale_app/core/page/order/OrderDetail.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/Orders.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OrderStoreScreen extends StatefulWidget {
  String storeId;

  OrderStoreScreen({
    super.key,
    required this.storeId,
  });

  @override
  State<OrderStoreScreen> createState() => _OrderStoreScreenState();
}

class _OrderStoreScreenState extends State<OrderStoreScreen> with RouteAware {
  List<Orders> orders = [];
  final ScrollController _scrollController = ScrollController();
  bool _loadingOrder = true;
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  @override
  void initState() {
    super.initState();
    _getOrder();
  }

  @override
  void didPopNext() {
    _getOrder();
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

  Future<void> _getOrder() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/order/all?type=sale&area=${User.area}&period=${period}&store=${widget.storeId}', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      print("Data ${response.data['data']}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _loadingOrder = false;
              orders = data.map((item) => Orders.fromJson(item)).toList();
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
            title: "รายการขายของ ${widget.storeId}",
            icon: Icons.store_mall_directory_rounded),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return Container(
            padding: EdgeInsets.all(8),
            child: LoadingSkeletonizer(
              loading: _loadingOrder,
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InvoiceCard(
                      item: orders[index],
                      onDetailsPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(
                                orderId: orders[index].orderId),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
