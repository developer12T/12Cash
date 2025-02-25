import 'dart:convert';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Order.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartCard extends StatefulWidget {
  final VoidCallback onDetailsPressed;

  const CartCard({
    Key? key,
    required this.onDetailsPressed,
  }) : super(key: key);

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  List<Order> _orders = [];

  Future<void> _loadOrdersFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonOrders = prefs.getStringList('orders');
    if (jsonOrders != null) {
      setState(() {
        _orders = jsonOrders
            .map((jsonOrder) => Order.fromJson(jsonDecode(jsonOrder)))
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOrdersFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: widget.onDetailsPressed,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: SingleChildScrollView(
          // Outer scrollable container
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_orders.length, (index) {
              final order = _orders[index];
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${index + 1}. ${order.itemName}',
                            style: Styles.black24(context),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _orders.removeAt(index); // Optionally remove order
                          });
                        },
                        child: Container(
                          width: screenWidth / 12,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.close,
                              color: Colors.white, size: screenWidth / 15),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth / 37),
                  Container(
                    // color: Colors.amber,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            // color: Colors.blue,
                            child: Text(
                              'ราคา ${order.totalPrice} บาท',
                              style: Styles.grey18(context),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // color: Colors.red,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (order.count > 0) {
                                            order.count--;
                                          }
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: screenWidth / 15,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          color: Colors.black,
                                          size: screenWidth / 22,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          border: Border.symmetric(
                                              horizontal: BorderSide(
                                        color: Colors.grey,
                                        width: 2,
                                      ))),
                                      width: screenWidth / 15,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${order.count.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: screenWidth / 25,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          order.count++;
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: screenWidth / 15,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.black,
                                          size: screenWidth / 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${order.unitText}',
                                  style: Styles.grey18(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey.shade300),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
