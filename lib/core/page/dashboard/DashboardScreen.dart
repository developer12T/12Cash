import 'dart:convert';
import 'dart:math';
import 'package:_12sale_app/core/components/CalendarPicker.dart';
import 'package:_12sale_app/core/components/camera/CameraPreviewScreen.dart';
import 'package:_12sale_app/core/components/button/MenuButton.dart';
import 'package:_12sale_app/core/components/card/MenuDashboard.dart';
import 'package:_12sale_app/core/components/card/WeightCude.dart';
import 'package:_12sale_app/core/components/chart/BarChart.dart';
import 'package:_12sale_app/core/components/chart/ItemSummarize.dart';
import 'package:_12sale_app/core/components/chart/LineChart.dart';
import 'package:_12sale_app/core/components/chart/TrendingMusicChart.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/giveaways/GiveAwaysHistoryScreen.dart';
import 'package:_12sale_app/core/page/giveaways/GiveAwaysScreen.dart';
import 'package:_12sale_app/core/page/notification/NotificationScreen.dart';
import 'package:_12sale_app/core/page/3D_canvas/Ractangle3D.dart';
import 'package:_12sale_app/core/page/printer/ManagePrinterScreen.dart';
import 'package:_12sale_app/core/page/printer/PrinterScreen.dart';
import 'package:_12sale_app/core/page/sendmoney/SendMoneyScreen.dart';
import 'package:_12sale_app/core/page/setting/SettingScreen.dart';
import 'package:_12sale_app/core/page/stock/StockScreen.dart';
import 'package:_12sale_app/core/page/withdraw/WithDrawScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Shipping.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../components/table/TestGridTable.dart';
import 'package:timezone/standalone.dart' as tz;

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({super.key});

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  String reason = '';
  int _current = 0;
  Timer? _locationTimer;
  late Map<String, String> languages = {};
  String? selectedLanguageCode;
  final CarouselSliderController _controller = CarouselSliderController();

  void onPageChange(int index, CarouselPageChangedReason changeReason) {
    setState(() {
      reason = changeReason.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    LocationService().initialize();
    _loadData();
  }

  Future<void> _loadData() async {
    final String jsonString =
        await rootBundle.loadString('assets/locales/languages.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      languages = Map<String, String>.from(jsonData);
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void currentLocation() async {
    try {
      Position position = await getCurrentLocation();
      print('Current location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error: $e');
    }
  }

  void startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentLocation(); // Call your currentLocation function every 5 seconds
    });
  }

  Widget bottomTitleWidgets(
      double value, TitleMeta meta, BuildContext context) {
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('JAN', style: Styles.black18(context));
        break;
      case 2:
        text = Text('FEB', style: Styles.black18(context));
        break;
      case 3:
        text = Text('MAR', style: Styles.black18(context));
        break;
      case 4:
        text = Text('APR', style: Styles.black18(context));
        break;
      case 5:
        text = Text('MAY', style: Styles.black18(context));
        break;
      case 6:
        text = Text('JUN', style: Styles.black18(context));
        break;
      case 7:
        text = Text('JUL', style: Styles.black18(context));
        break;
      case 8:
        text = Text('AUG', style: Styles.black18(context));
        break;
      case 9:
        text = Text('SEP', style: Styles.black18(context));
        break;
      case 10:
        text = Text('OCT', style: Styles.black18(context));
        break;
      case 11:
        text = Text('NOV', style: Styles.black18(context));
        break;
      case 12:
        text = Text('DEC', style: Styles.black18(context));
        break;
      default:
        text = Text('', style: Styles.black18(context));
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  List<ShippingModel> shuppingList = [];

  Widget build(BuildContext context) {
    List<Widget> menuList = [
      MenuDashboard(
        title_1: "เบิกสินค้า",
        icon_1: Icons.local_shipping,
        onTap1: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WithDrawScreen(),
            ),
          );
        },
        title_2: "ส่งเงิน",
        icon_2: FontAwesomeIcons.moneyBillTransfer,
        onTap2: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SendMoneyScreen(),
            ),
          );
        },
        title_3: "สต๊อกสินค้า",
        icon_3: Icons.warehouse_rounded,
        onTap3: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StockScreen(),
            ),
          );
        },
        title_4: "แจกสินค้า",
        icon_4: Icons.campaign_rounded,
        onTap4: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => GiveawaysHistoryScreen()),
          );
        },
        title_5: "ตั้งค่าเครื่องปริ้น",
        icon_5: Icons.print_rounded,
        onTap5: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManagePrinterScreen(),
            ),
          );
        },
        title_6: "ตั้งค่า",
        icon_6: Icons.settings,
        onTap6: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingScreen()),
          );
        },
      ),
      MenuDashboard(
        title_1: "ทดสอบ Noti",
        icon_1: Icons.notifications_active,
        onTap1: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NotificationScreen()),
          );
        },
        title_2: "dashboard.menu.send_money".tr(),
        icon_2: Icons.payments,
        title_3: "dashboard.menu.mall".tr(),
        icon_3: Icons.shopping_bag,
        title_4: "dashboard.menu.credit_limit".tr(),
        icon_4: Icons.credit_card,
        title_5: "dashboard.menu.warehouse".tr(),
        icon_5: Icons.warehouse,
        title_6: "dashboard.menu.more".tr(),
        icon_6: Icons.more_horiz,
      ),
    ];
    selectedLanguageCode = context.locale.toString().split("_")[0];
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        padding: const EdgeInsets.all(10.0),
        // height: screenWidth / 2.5,
        // width: screenWidth / 1.5,
        child: Column(
          children: [
            // SizedBox(height: 300, width: screenWidth, child: LineChartSample()),
            SizedBox(height: 335, width: screenWidth, child: ItemSummarize()),
            // SizedBox(
            //   height: 50,
            //   width: screenWidth,
            //   child: CalendarPicker(
            //     label: 'dashboard.menu.calendar'.tr(),
            //     firstDate: DateTime(2025),
            //     onDateSelected: (p0) {
            //       print(p0);
            //     },
            //     lastDate: DateTime.now(),
            //     initialDate: DateTime(2025, 1, 14),
            //   ),
            // ),
            // CustomPaint(
            //   size: Size(200, 200),
            //   painter: CircularChartPainter(),
            //   child: Center(
            //     child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Text(
            //           "Share Holder",
            //           style: Styles.black24(context),
            //         ),
            //         Text(
            //           "50%",
            //           style: Styles.black32(context),
            //         ),
            //         Text(
            //           "Promoter",
            //           style: Styles.black18(context),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: menuList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: screenWidth / 37),
            CarouselSlider(
              items: menuList.map((item) => item).toList(),
              carouselController: _controller,
              options: CarouselOptions(
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
                pageSnapping: true,
                // aspectRatio: 2.0,
                // autoPlay: true,
                disableCenter: true,
                enlargeCenterPage: true,
                viewportFraction: 1.0, // Show one row fully at a time
              ),
            ),

            // const WeightCudeCard(),
            // SizedBox(height: screenWidth / 25),
            // SizedBox(height: 500, width: 400, child: LineChartSample()),
            // SizedBox(height: screenWidth / 25),
            // CalendarPicker(
            //   label: "Select Date",
            //   initialDate: DateTime.now(),
            //   firstDate: DateTime(2000),
            //   lastDate: DateTime(2100),
            //   onDateSelected: (selectedDate) {
            //     // Perform any action with the selected date
            //     debugPrint("Selected Date: $selectedDate");
            //   },
            // ),
            // SizedBox(height: screenWidth / 25),

            // Container(height: 500, width: 400, child: LineChartSample()),
            // Expanded(
            //     child: Container(
            //         height: 500, width: 500, child: TrendingMusicChart())),
            // Container(height: 500, width: 300, child: LineChartSample())
            // CameraButtonWidget()
            // ShippingDropdownSearch(),
            // SizedBox(height: screenWidth / 25),

            // CameraButtonWidget(
            //   buttonText: 'Open Camera',
            //   buttonColor: Colors.blue,
            //   textStyle: TextStyle(color: Colors.white, fontSize: 18),
            // )
            // CustomTable(data: _buildRows(), columns: [
            //   DataColumn(label: Text('วันที่')), // "Date" in Thai
            //   DataColumn(label: Text('เส้นทาง')), // "Path" in Thai
            //   DataColumn(label: Text('สถานะ')), // "Status" in Thai
            // ]),
          ],
        )
        // CustomTable(
        //   data: _buildRows(),
        //     // )
        //     Row(
        //   crossAxisAlignment: CrossAxisAlignment.stretch,
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [DropdownSearchWidget()],
        // ),
        );

    //   // SizedBox(width: 10),
    //   CustomTable(data: _buildRows2(), columns: [
    //     DataColumn(label: Text('วันที่')), // "Date" in Thai
    //     DataColumn(label: Text('เส้นทาง')), // "Path" in Thai
    //     DataColumn(label: Text('สถานะ')), // "Status" in Thai
    //     DataColumn(label: Text('adw')), // "Status" in Thai
    //   ])
    // return Container(height: 500, width: 400, child: LineChartSample());
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), // Light background color
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  late SharedPreferences sharedPreferences;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // setup();
  }

  Future<void> setup() async {
    await tz.initializeTimeZone();
    var detroit = tz.getLocation('Asia/Bangkok');
    setState(() {
      now = tz.TZDateTime.now(detroit);
    });
    // var now = tz.TZDateTime.now(detroit);
  }

  @override
  Widget build(BuildContext context) {
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
                fit: FlexFit.loose,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/12TradingLogo.png'),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        // color: Colors.blue,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${User.fullName}',
                                  style: Styles.headerWhite24(context),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat('d MMMM yyyy',
                                            'dashboard.lange'.tr())
                                        .format(DateTime
                                            .now()), // Current date and time
                                    style: Styles.headerWhite24(context),
                                  ),
                                  StreamBuilder(
                                    stream: Stream.periodic(
                                      const Duration(seconds: 1),
                                    ),
                                    builder: (context, snapshot) {
                                      return Text(
                                          ' ${'dashboard.time'.tr()}:${DateFormat('HH:mm:ss').format(DateTime.now())}',
                                          style: Styles.headerWhite24(context));
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: screenWidth / 6,
                                    // margin: EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                        color: Styles.secondaryColor,
                                        borderRadius: BorderRadius.horizontal(
                                            right: Radius.circular(50),
                                            left: Radius.circular(50))),

                                    child: Center(
                                      child: Text(
                                        '${User.role.toUpperCase()}',
                                        style: Styles.headerWhite24(context),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth / 6,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: const BoxDecoration(
                                        color: Styles.secondaryColor,
                                        borderRadius: BorderRadius.horizontal(
                                            right: Radius.circular(50),
                                            left: Radius.circular(50))),
                                    child: Center(
                                      child: Text(
                                        '${User.area.toUpperCase()}',
                                        style: Styles.headerWhite24(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
