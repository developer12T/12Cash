// import 'dart:convert';

// import 'package:_12sale_app/core/components/Appbar.dart';
// import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
// import 'package:_12sale_app/core/components/TossAnimation.dart';
// import 'package:_12sale_app/core/page/order/OrderScreen.dart';

// import 'package:_12sale_app/core/styles/style.dart';
// import 'package:_12sale_app/core/utils/tost_util.dart';
// import 'package:_12sale_app/data/models/Order.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:toastification/toastification.dart';

// class OrderDetail extends StatefulWidget {
//   final String itemCode;
//   final String itemName;
//   final String price;
//   String? customerNo;
//   String? customerName;
//   String? status;

//   OrderDetail(
//       {super.key,
//       required this.itemCode,
//       required this.itemName,
//       required this.price,
//       this.customerNo,
//       this.customerName,
//       this.status});

//   @override
//   State<OrderDetail> createState() => _OrderDetailState();
// }

// class _OrderDetailState extends State<OrderDetail>
//     with TickerProviderStateMixin, RouteAware {
//   String selectedLabel = "";
//   double count = 1.0; // Initialized with 1
//   double unit = 1.0;
//   double qtyConvert = 0;
//   late double price = 15.0;
//   late double qty;
//   late double totalPrice;
//   List<Order> _orders = []; // List to hold orders as Order objects
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

//   late AnimationController _controller;
//   late Animation<Offset> _animation;
//   final GlobalKey _cartKey = GlobalKey();
//   OverlayEntry? _overlayEntry;
//   bool _isAnimating = false;
//   final ScrollController _animatedListController = ScrollController();
//   final ScrollController _listViewController = ScrollController();

//   // ----------------------------Animations-----------------------------
//   int _cartItemCount = 0;
//   bool _isAnimating2 = false;
//   // late AnimationController _controller2;
//   late Animation<Offset> _positionAnimation;
//   late Animation<double> _scaleAnimation;
//   final GlobalKey _cartKey2 = GlobalKey();
//   final GlobalKey _buttonKey = GlobalKey();

//   late AnimationController _buttonAnimationController;
//   late Animation<double> _buttonScaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     price = double.parse(widget.price);
//     qty = double.parse(widget.price);
//     totalPrice = price; // Initialize the totalPrice

//     _buttonAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );

//     _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(
//           parent: _buttonAnimationController, curve: Curves.easeInOut),
//     );
//     _controller = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     );
//     //-------------------------------------------------

//     // -------------------------------------------------
//     _loadOrdersFromStorage();
//   }

//   // Function to add a new order
//   void _addOrder() async {
//     if (qty >= count * unit && selectedLabel != "") {
//       // Trigger button scale animation
//       await _buttonAnimationController.forward();
//       await _buttonAnimationController.reverse();

//       // Rest of your add order logic
//       Order? existingOrder;
//       try {
//         existingOrder = _orders.firstWhere(
//           (order) => order.itemCode == widget.itemCode && order.unit == unit,
//         );
//       } catch (e) {
//         existingOrder = null;
//       }

//       if (existingOrder != null) {
//         setState(() {
//           existingOrder?.count += count;
//           existingOrder?.totalPrice = existingOrder.count *
//               existingOrder.unit *
//               existingOrder.pricePerUnit;
//           qty -= (count * unit);
//         });
//         int existingIndex = _orders.indexOf(existingOrder);
//         _listKey.currentState?.setState(() {
//           _listKey.currentState?.removeItem(
//             existingIndex,
//             (context, animation) =>
//                 _buildOrderItem(existingOrder!, animation, existingIndex),
//           );
//           _listKey.currentState?.insertItem(existingIndex);
//         });
//       } else {
//         final newOrder = Order(
//           textShow:
//               "${_orders.length + 1}. ${widget.itemName} $count $selectedLabel ราคา ${totalPrice.toStringAsFixed(2)}",
//           itemName: widget.itemName,
//           itemCode: widget.itemCode,
//           count: count,
//           unit: unit,
//           unitText: selectedLabel,
//           pricePerUnit: price,
//           qty: _orders.length + 1,
//         );
//         _orders.insert(0, newOrder);
//         _listKey.currentState?.insertItem(0);
//         print("Success $_orders");
//         setState(() {
//           qty -= (count * unit);
//         });
//       }
//       _saveOrdersToStorage();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('จํานวนสินค้าไม่เพียงพอ'),
//         ),
//       );
//     }
//   }

//   Future<void> _clearOrders() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('orders'); // Clear orders from SharedPreferences

//     setState(() {
//       _orders.clear(); // Clear orders in the UI
//     });
//   }

//   void _startAddToCartAnimation(BuildContext context, Offset startPosition) {
//     if (_isAnimating) return;

//     final cartPosition = _getWidgetPosition(_cartKey);
//     if (cartPosition == null) return;

//     final endPosition = cartPosition - startPosition;
//     _animation = Tween<Offset>(begin: Offset.zero, end: endPosition).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );

//     _overlayEntry = OverlayEntry(
//       builder: (context) => TossAnimationOverlay(
//         animation: _animation,
//         startPosition: startPosition,
//         onComplete: () {
//           _overlayEntry?.remove();
//           setState(() {
//             _isAnimating = false;
//           });
//         },
//       ),
//     );

//     setState(() {
//       _isAnimating = true;
//     });

//     Overlay.of(context)?.insert(_overlayEntry!);
//     _controller.forward(from: 0);
//   }

//   Offset? _getWidgetPosition(GlobalKey key) {
//     final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
//     return renderBox?.localToGlobal(Offset.zero);
//   }

//   // Function to delete an order with animation
//   void _deleteOrder(int index) async {
//     final removedOrder = _orders[index];
//     _orders.removeAt(index);
//     _listKey.currentState?.removeItem(
//       index,
//       (context, animation) => _buildOrderItem(removedOrder, animation, index),
//     );
//     setState(() {
//       qty = qty + (removedOrder.count * removedOrder.unit);
//     });
//     await _saveOrdersToStorage();
//   }

//   Future<void> _saveOrdersToStorage() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Convert the list of Order objects to a list of maps (JSON)
//     List<String> jsonOrders =
//         _orders.map((order) => jsonEncode(order.toJson())).toList();

//     // Save the JSON string list to SharedPreferences
//     await prefs.setStringList('orders', jsonOrders);
//   }

//   Future<void> _loadOrdersFromStorage() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Get the JSON string list from SharedPreferences
//     List<String>? jsonOrders = prefs.getStringList('orders');

//     if (jsonOrders != null) {
//       setState(() {
//         // Decode each JSON string and convert it to an Order object
//         _orders = jsonOrders
//             .map((jsonOrder) => Order.fromJson(jsonDecode(jsonOrder)))
//             .toList();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();

//     _buttonAnimationController.dispose();
//     // _controller2.dispose();
//     _animatedListController.dispose();
//     _listViewController.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: AppbarCustom(
//           title: " ${"route.order_detail_screen.title".tr()}",
//           icon: Icons.inventory_2_outlined,
//         ),
//       ),
//       body: Container(
//         color: Colors.grey[100],
//         child: Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               // Product Info Section
//               BoxShadowCustom(
//                 child: Container(
//                   margin: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Flexible(
//                         flex: 1,
//                         child: Container(
//                           height: screenWidth / 3,
//                           width: screenWidth / 3,
//                           decoration: const BoxDecoration(
//                             image: DecorationImage(
//                               image:
//                                   AssetImage('assets/images/12TradingLogo.png'),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                                 "${"route.order_detail_screen.title".tr()} ${widget.itemCode}",
//                                 style: Styles.black18(context)),
//                             Text(widget.itemName,
//                                 style: Styles.black18(context)),
//                             Text(
//                                 "${"route.order_detail_screen.item_qty".tr()} $qty",
//                                 style: Styles.black18(context)),
//                             Text(
//                                 "${"route.order_detail_screen.item_price".tr()} $price",
//                                 style: Styles.black18(context)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: screenWidth / 50),
//               // Unit Selection Buttons
//               Row(
//                 children: [
//                   _buildCustomButton("หีบ", 24.00),
//                   _buildCustomButton("กล่อง", 12.00),
//                   _buildCustomButton("ชิ้น", 1.00),
//                 ],
//               ),
//               SizedBox(height: screenWidth / 50),
//               Expanded(
//                 child: BoxShadowCustom(
//                   child: Container(
//                     margin: const EdgeInsets.all(8.0),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Text("route.order_detail_screen.promotion".tr(),
//                                     style: Styles.black18(context)),

//                                 // Text("ราคา", style: Styles.black18(context)),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Text("route.order_detail_screen.qty".tr(),
//                                     style: Styles.black18(context)),
//                                 Text("route.order_detail_screen.price".tr(),
//                                     style: Styles.black18(context)),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Text("$count", style: Styles.black18(context)),
//                                 Text("$totalPrice",
//                                     style: Styles.black18(context)),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Text("$count", style: Styles.black18(context)),
//                                 Text("$totalPrice",
//                                     style: Styles.black18(context)),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Text("$count", style: Styles.black18(context)),
//                                 Text("$totalPrice",
//                                     style: Styles.black18(context)),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Text("$count", style: Styles.black18(context)),
//                                 Text("$totalPrice",
//                                     style: Styles.black18(context)),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: screenWidth / 50),
//               Expanded(
//                 child: BoxShadowCustom(
//                   child: Container(
//                     margin: const EdgeInsets.all(8.0),
//                     child: Scrollbar(
//                       controller: _animatedListController,
//                       thumbVisibility: true,
//                       child: Column(
//                         children: [
//                           Expanded(
//                             child: AnimatedList(
//                               key: _listKey,
//                               controller: _animatedListController,
//                               initialItemCount: _orders.length,
//                               itemBuilder: (context, index, animation) {
//                                 return _buildOrderItem(
//                                     _orders[index], animation, index);
//                               },
//                             ),
//                           ),
//                           // Expanded(
//                           //   child: Scrollbar(
//                           //     controller:
//                           //         _listViewController, // Scrollbar attached to ListView
//                           //     thumbVisibility: true,
//                           //     child: ListView.builder(
//                           //       controller: _listViewController,
//                           //       itemCount: _orders.length,
//                           //       itemBuilder: (context, index) {
//                           //         return Text(_orders[index].textShow);
//                           //       },
//                           //     ),
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: screenWidth / 50),
//               // Bottom Add Button
//               BoxShadowCustom(
//                 child: Container(
//                   margin: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () => setState(() {
//                                 if (count > 0) {
//                                   count--;
//                                   totalPrice = price * count * unit;
//                                 }
//                               }),
//                               child: Container(
//                                 alignment: Alignment.center,
//                                 width: screenWidth / 15,
//                                 margin: const EdgeInsets.all(8.0),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey,
//                                   borderRadius: BorderRadius.circular(180),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(
//                                           0.2), // Shadow color with transparency
//                                       spreadRadius: 2, // Spread of the shadow
//                                       blurRadius:
//                                           8, // Blur radius of the shadow
//                                       offset: Offset(0,
//                                           4), // Offset of the shadow (horizontal, vertical)
//                                     ),
//                                   ],
//                                 ),
//                                 child: Icon(
//                                   Icons.remove,
//                                   color: Colors.white,
//                                   size: screenWidth / 15,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 border: Border.all(
//                                   color: Colors.grey,
//                                   width: 2,
//                                 ),
//                               ),
//                               width: screenWidth / 8,
//                               alignment: Alignment.center,
//                               child: Text(
//                                 '${count.toStringAsFixed(0)}',
//                                 style: Styles.black18(context),
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () => setState(() {
//                                 count++;
//                                 totalPrice = price * count * unit;
//                               }),
//                               child: Container(
//                                 alignment: Alignment.center,
//                                 width: screenWidth / 15,
//                                 margin: const EdgeInsets.all(8.0),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey,
//                                   borderRadius: BorderRadius.circular(180),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(
//                                           0.2), // Shadow color with transparency
//                                       spreadRadius: 2, // Spread of the shadow
//                                       blurRadius:
//                                           8, // Blur radius of the shadow
//                                       offset: Offset(0,
//                                           4), // Offset of the shadow (horizontal, vertical)
//                                     ),
//                                   ],
//                                 ),
//                                 child: Icon(
//                                   Icons.add,
//                                   color: Colors.white,
//                                   size: screenWidth / 15,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Styles.successButtonColor,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(
//                                     0.2), // Shadow color with transparency
//                                 spreadRadius: 2, // Spread of the shadow
//                                 blurRadius: 8, // Blur radius of the shadow
//                                 offset: const Offset(0,
//                                     4), // Offset of the shadow (horizontal, vertical)
//                               ),
//                             ],
//                           ),
//                           margin: const EdgeInsets.all(8.0),
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: ScaleTransition(
//                             scale: _buttonScaleAnimation,
//                             child: TextButton(
//                               onPressed: () async {
//                                 // Start the scale animation
//                                 await _buttonAnimationController.forward();
//                                 await _buttonAnimationController.reverse();

//                                 // Call the add order function
//                                 _addOrder();

//                                 showToast(
//                                   context: context,
//                                   message:
//                                       '${"route.order_detail_screen.toasting_success".tr()}!',
//                                   type: ToastificationType.success,
//                                   primaryColor: Colors.green,
//                                 );
//                               },
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     "route.order_detail_screen.add_button".tr(),
//                                     style: Styles.headerWhite24(context),
//                                   ),
//                                   Text(
//                                     totalPrice.toStringAsFixed(2),
//                                     style: Styles.headerWhite24(context),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Custom Button Builder
//   Widget _buildCustomButton(String label, double uint) {
//     bool isSelected = label == selectedLabel;
//     qtyConvert = (qty / unit);
//     // print("qtyConvert ${qtyConvert.toStringAsFixed(0)}");
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.all(8.0),
//         height: 100,
//         decoration: BoxDecoration(
//           color: isSelected ? Styles.successButtonColor : Colors.green[100],
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black
//                   .withOpacity(0.2), // Shadow color with transparency
//               spreadRadius: 2, // Spread of the shadow
//               blurRadius: 8, // Blur radius of the shadow
//               offset: const Offset(
//                   0, 4), // Offset of the shadow (horizontal, vertical)
//             ),
//           ],
//         ),
//         child: TextButton(
//           onPressed: () {
//             setState(() {
//               selectedLabel = label;
//               unit = uint;

//               totalPrice = price * count * unit;
//             });
//           },
//           child: Text(
//             isSelected
//                 ? '${qtyConvert.floor().toStringAsFixed(0)} $label'
//                 : label,
//             style: isSelected
//                 ? Styles.headerWhite32(context)
//                 : Styles.headerBlack32(context),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderItem2(Order order, int index) {
//     return ListTile(
//       title: Text(
//         order.textShow,
//         style: TextStyle(fontSize: 18, color: Colors.black),
//       ),
//       tileColor: const Color.fromARGB(255, 3, 3, 3).withOpacity(0.1),
//       trailing: IconButton(
//         icon: const Icon(Icons.delete, color: Colors.red),
//         onPressed: () => _deleteOrder(index),
//       ),
//     );
//   }

//   // Function to build an animated order item
//   Widget _buildOrderItem(Order order, Animation<double> animation, int index) {
//     return SlideTransition(
//       position: Tween<Offset>(
//         begin: const Offset(1, 0),
//         end: const Offset(0, 0),
//       ).animate(animation),
//       child: FadeTransition(
//         opacity: animation,
//         child: ListTile(
//           title: Text(
//             order.textShow,
//             style: Styles.black18(context),
//           ),
//           tileColor: const Color.fromARGB(255, 3, 3, 3).withOpacity(0.1),
//           trailing: IconButton(
//             icon: const Icon(Icons.delete, color: Colors.red),
//             onPressed: () => _deleteOrder(index),
//           ),
//         ),
//       ),
//     );
//   }
// }
