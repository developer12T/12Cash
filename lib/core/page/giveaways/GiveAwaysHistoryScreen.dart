import 'dart:isolate';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/card/giveaway/GiveAwayCard.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/page/giveaways/GiveAwaysDetailScreen.dart';
import 'package:_12sale_app/core/page/giveaways/GiveAwaysScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/giveaways/GiveAways.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class GiveawaysHistoryScreen extends StatefulWidget {
  const GiveawaysHistoryScreen({super.key});

  @override
  State<GiveawaysHistoryScreen> createState() => _GiveawaysHistoryScreenState();
}

class _GiveawaysHistoryScreenState extends State<GiveawaysHistoryScreen> {
  int isSelect = 1;
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";
  List<GiveAways> giveAwaysList = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _getGiveAways();
  }

  Future<void> _getGiveAways() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/give/all?type=give&area=${User.area}&period=${period}', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      print("Data ${response.data['data']}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          giveAwaysList = data.map((item) => GiveAways.fromJson(item)).toList();
        });
      }
    } catch (e) {
      print("Error _getGiveAways $e");
      setState(() {
        giveAwaysList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " ประวัติการแจกสินค้า",
          icon: Icons.campaign_rounded,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Styles.primaryColor,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GiveAwaysScreen(),
            ),
          );
        },
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomSlidingSegmentedControl<int>(
                  initialValue: 1,
                  isStretch: true,
                  children: {
                    1: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.clock,
                          color: isSelect == 1
                              ? Styles.primaryColorIcons
                              : Styles.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'รายการ',
                          style: isSelect == 1
                              ? Styles.headerPirmary18(context)
                              : Styles.headerWhite18(context),
                        )
                      ],
                    ),
                    2: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description,
                          color: isSelect == 2
                              ? Styles.primaryColorIcons
                              : Styles.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ประวัติ',
                          style: isSelect == 2
                              ? Styles.headerPirmary18(context)
                              : Styles.headerWhite18(context),
                        ),
                      ],
                    )
                  },
                  onValueChanged: (v) async {
                    setState(() {
                      isSelect = v;
                    });
                    // if (v == 1) {
                    //   await _getDetail(status: "pending");
                    // } else {
                    //   await _getDetail(status: "history");
                    // }
                  },
                  decoration: BoxDecoration(
                    color: Styles.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  thumbDecoration: BoxDecoration(
                    color: Styles.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(milliseconds: 300),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: isSelect == 2
                    ? Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showMonthPicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2025),
                                  lastDate: DateTime(2026),
                                  monthPickerDialogSettings:
                                      MonthPickerDialogSettings(
                                    headerSettings: PickerHeaderSettings(
                                      headerBackgroundColor:
                                          Styles.primaryColor,
                                      headerCurrentPageTextStyle:
                                          Styles.white18(context),
                                      headerSelectedIntervalTextStyle:
                                          Styles.white24(context),
                                    ),
                                    dialogSettings: PickerDialogSettings(
                                      dialogRoundedCornersRadius: 16,
                                      customWidth: screenWidth * 0.7,
                                      customHeight: screenWidth * 0.5,
                                    ),
                                    dateButtonsSettings:
                                        PickerDateButtonsSettings(
                                      selectedMonthBackgroundColor:
                                          Styles.primaryColor,
                                      monthTextStyle: Styles.black18(context),
                                      selectedDateRadius: 20,
                                    ),
                                    actionBarSettings: PickerActionBarSettings(
                                      confirmWidget: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'ยืนยัน',
                                          style: Styles.black18(context),
                                        ),
                                      ),
                                      cancelWidget: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'ยกเลิก',
                                          style: Styles.black18(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ).then(
                                  (value) {
                                    if (value != null) {
                                      String formattedMonth = value.month
                                          .toString()
                                          .padLeft(2, '0');
                                      setState(() {
                                        _selectedDate = DateTime(
                                            value.year, value.month, 1);
                                        period =
                                            "${value.year}${formattedMonth}";
                                      });

                                      print("periodTEST $period}");
                                      _getGiveAways();
                                    }
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Styles.primaryColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width: 8),
                                    Text(
                                      _selectedDate != null
                                          ? "${_selectedDate!.month}/${_selectedDate!.year}"
                                          : "${DateFormat('MM').format(DateTime.now())}/${DateTime.now().year}",
                                      style: Styles.black18(context),
                                    ),
                                    const Icon(Icons.calendar_today,
                                        size: 20, color: Styles.primaryColor),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  // controller: _scrollController,
                  itemCount: giveAwaysList.length,
                  itemBuilder: (context, index) {
                    return GiveAwayCard(
                      item: giveAwaysList[index],
                      onDetailsPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GiveAwaysDetailScreen(
                                orderId: giveAwaysList[index].orderId),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
