// import 'dart:async';

// import 'package:_12sale_app/core/components/Appbar.dart';
// import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
// import 'package:_12sale_app/core/components/CalendarPicker%20copy.dart';
// import 'package:_12sale_app/core/components/CalendarPicker.dart';
// import 'package:_12sale_app/core/components/Loading.dart';
// import 'package:_12sale_app/core/components/card/RouteAjustCard.dart';
// import 'package:_12sale_app/core/components/card/StoreVisitCard.dart';
// import 'package:_12sale_app/core/styles/style.dart';
// import 'package:_12sale_app/data/models/User.dart';
// import 'package:_12sale_app/data/models/route/RouteVisit.dart';
// import 'package:_12sale_app/data/service/apiService.dart';
// import 'package:easy_date_timeline/easy_date_timeline.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_date_pickers/flutter_date_pickers.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:month_picker_dialog/month_picker_dialog.dart';
// import 'package:omni_datetime_picker/omni_datetime_picker.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
// import 'package:month_year_picker/month_year_picker.dart';

// class AjustRoute extends StatefulWidget {
//   const AjustRoute({super.key});

//   @override
//   State<AjustRoute> createState() => _AjustRouteState();
// }

// class _AjustRouteState extends State<AjustRoute> {
//   bool isLoading = true;
//   List<RouteVisit> routeVisits = [];
//   String period =
//       "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

//   DateTime? _selectedDate;
//   @override
//   initState() {
//     super.initState();
//     _getRouteVisit();
//   }

//   Future<void> _getRouteVisit() async {
//     ApiService apiService = ApiService();
//     await apiService.init();

//     var response = await apiService.request(
//       endpoint: 'api/cash/route/getRoute?area=${User.area}&period=${period}',
//       method: 'GET',
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = response.data['data'];
//       // print("getRoute: ${response.data['data']}");
//       if (mounted) {
//         setState(() {
//           routeVisits = data.map((item) => RouteVisit.fromJson(item)).toList();
//         });
//       }
//       Timer(const Duration(milliseconds: 500), () {
//         if (mounted) {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       });
//       print("getRoute: $routeVisits");
//     }
//   }

//   Future<void> _updateRouteStore(
//     String storeId,
//     String fromRoute,
//     String toRoute,
//   ) async {
//     try {
//       ApiService apiService = ApiService();
//       await apiService.init();
//       var response = await apiService.request(
//         endpoint: 'api/cash/route/change',
//         method: 'POST',
//         body: {
//           "area": "${User.area}",
//           "period": "${period}",
//           "storeId": "${storeId}",
//           "fromRoute": "${fromRoute}",
//           "toRoute": "${toRoute}",
//           "changedBy": "${User.username}",
//           "changedDate": "${DateTime.now().toIso8601String()}",
//           "status": "0",
//           "approvedBy": "",
//           "approvedDate": ""
//         },
//       );

//       if (response.statusCode == 200) {
//         print("statusCode: $response.statusCode");
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: AppbarCustom(
//           title: "ปรับรูท ",
//           icon: Icons.route_outlined,
//         ),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: GestureDetector(
//                     onTap: () {
//                       showMonthPicker(
//                         context: context,
//                         initialDate: DateTime.now(),

//                         firstDate: DateTime(2025),
//                         lastDate: DateTime(2026),
//                         // headerTitle: Text(
//                         //   'กรุณาเลือกวันที่',
//                         //   style: Styles.white24(context),
//                         // ),

//                         monthPickerDialogSettings: MonthPickerDialogSettings(
//                           headerSettings: PickerHeaderSettings(
//                             headerBackgroundColor: Styles.primaryColor,
//                             headerCurrentPageTextStyle: Styles.white18(context),
//                             headerSelectedIntervalTextStyle:
//                                 Styles.white24(context),
//                           ),
//                           dialogSettings: PickerDialogSettings(
//                             dialogRoundedCornersRadius: 16,
//                             customWidth: screenWidth * 0.7,
//                             customHeight: screenWidth * 0.5,
//                           ),
//                           dateButtonsSettings: PickerDateButtonsSettings(
//                             selectedMonthBackgroundColor: Styles.primaryColor,
//                             monthTextStyle: Styles.black18(context),
//                             selectedDateRadius: 20,
//                           ),
//                           actionBarSettings: PickerActionBarSettings(
//                             confirmWidget: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 'ยืนยัน',
//                                 style: Styles.black18(context),
//                               ),
//                             ),
//                             cancelWidget: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 'ยกเลิก',
//                                 style: Styles.black18(context),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ).then(
//                         (value) {
//                           if (value != null) {
//                             String formattedMonth =
//                                 value.month.toString().padLeft(2, '0');
//                             setState(() {
//                               _selectedDate =
//                                   DateTime(value.year, value.month, 1);
//                               period = "${value.year}${formattedMonth}";
//                             });

//                             print("periodTEST $period}");
//                             _getRouteVisit();
//                           }
//                         },
//                       );
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Styles.primaryColor),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(width: 8),
//                           Text(
//                             _selectedDate != null
//                                 ? "${_selectedDate!.month}/${_selectedDate!.year}"
//                                 : "กรุณาเลือกวันที่",
//                             style: Styles.black18(context),
//                           ),
//                           const Icon(Icons.calendar_today,
//                               size: 20, color: Styles.primaryColor),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.all(8),
//                     child: GestureDetector(
//                       onTap: () {},
//                       child: BoxShadowCustom(
//                         borderColor: Colors.green[600]!,
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               color: Styles.success),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.save_outlined,
//                                 size: 40,
//                                 color: Colors.white,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 "ขออนุมัติ",
//                                 style: Styles.white18(context),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Expanded(
//               child: LoadingSkeletonizer(
//                 loading: isLoading,
//                 child: BoxShadowCustom(
//                   child: ListView.builder(
//                     itemCount: routeVisits.length,
//                     itemBuilder: (context, index) {
//                       return RouteAjustCard(
//                         RouteVisit: routeVisits[index],
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
