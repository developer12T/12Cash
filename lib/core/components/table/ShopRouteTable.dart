// import 'dart:convert';

// import 'package:_12sale_app/core/page/HomeScreen.dart';
// import 'package:_12sale_app/core/page/route/DetailScreen.dart';

// import 'package:_12sale_app/core/styles/style.dart';
// import 'package:_12sale_app/data/models/Order.dart';
// import 'package:_12sale_app/data/models/SaleRoute.dart';
// import 'package:_12sale_app/function/SavetoStorage.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ShopRouteTable extends StatefulWidget {
//   final String day;
//   const ShopRouteTable({
//     super.key,
//     required this.day,
//   });

//   @override
//   State<ShopRouteTable> createState() => _ShopRouteTableState();
// }

// class _ShopRouteTableState extends State<ShopRouteTable> {
//   List<Store> stores = [];
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _loadStoreDetail();
//   }

//   Future<void> _loadStoreDetail() async {
//     List<SaleRoute> routes =
//         await loadFromStorage('saleRoutes', (json) => SaleRoute.fromJson(json));
//     List<Store> filteredStores = routes
//         .where((route) => route.day == widget.day.split(" ")[1])
//         .expand((route) => route.listStore)
//         .toList();
//     setState(() {
//       stores = filteredStores;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         // height: screenHeight / 1.5,
//         padding: const EdgeInsets.only(bottom: 10),
//         // Adds space around the entire table
//         decoration: BoxDecoration(
//           color: Colors.white, // Set background color if needed
//           borderRadius: BorderRadius.circular(
//               16), // Rounded corners for the outer container

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
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Fixed header
//             Container(
//               decoration: const BoxDecoration(
//                 color: Styles.backgroundTableColor,
//                 borderRadius: BorderRadius.vertical(
//                     top: Radius.circular(16)), // Rounded corners at the top
//               ),
//               child: Row(
//                 children: [
//                   _buildHeaderCell("route.shop_route_table.customer_no".tr()),
//                   _buildHeaderCell("route.shop_route_table.customer_name".tr()),
//                   _buildHeaderCell("route.shop_route_table.status".tr()),
//                 ],
//               ),
//             ),
//             // Scrollable content
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.vertical,
//                 child: Column(
//                   children: List.generate(stores.length, (index) {
//                     final store = stores[index];
//                     return _buildDataRow(
//                         store.storeInfo.storeId,
//                         store.storeInfo.storeName,
//                         store.storeInfo.storeAddress,
//                         store.statusText,
//                         Styles.successBackgroundColor,
//                         Styles.successTextColor,
//                         index);
//                   }),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDataRow(String customerNo, String customerName, String address,
//       String status, Color? bgColor, Color? textColor, int index) {
//     // Alternate row background color
//     Color rowBgColor =
//         (index % 2 == 0) ? Colors.white : Styles.backgroundTableColor;

//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DetailScreen(
//                 day: widget.day,
//                 customerNo: customerNo,
//                 customerName: customerName,
//                 address: address,
//                 status: status),
//           ),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: rowBgColor,
//         ),
//         child: Row(
//           children: [
//             Expanded(
//                 flex: 1,
//                 child: _buildTableCell(
//                     customerNo)), // Use Expanded to distribute space equally
//             Expanded(flex: 1, child: _buildTableCell(customerName)),

//             Expanded(
//                 flex: 1,
//                 child: _buildStatusCell(status, bgColor, textColor,
//                     context)), // Custom function for "สถานะ" column
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusCell(
//       String status, Color? bgColor, Color? textColor, BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Container(
//       alignment: Alignment.center,
//       child: Container(
//         width: screenWidth / 5, // Optional inner width for the status cell
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(
//               100), // Rounded corners for the inner container
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           status,
//           style:
//               GoogleFonts.kanit(color: textColor, fontSize: screenWidth / 35),
//         ),
//       ),
//     );
//   }

//   Widget _buildTableCell(String text) {
//     return Container(
//       alignment: Alignment.center,
//       padding: const EdgeInsets.all(8),
//       child: Text(text, style: Styles.black18(context)),
//     );
//   }

//   Widget _buildHeaderCell(String text) {
//     return Expanded(
//       child: Container(
//         alignment: Alignment.center,
//         padding: const EdgeInsets.all(8),
//         child: Text(
//           text,
//           style: Styles.grey18(context),
//         ),
//       ),
//     );
//   }
// }
