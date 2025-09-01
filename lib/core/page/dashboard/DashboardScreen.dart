import 'dart:convert';
import 'dart:math';
import 'package:_12sale_app/core/components/CalendarPicker.dart';
import 'package:_12sale_app/core/components/DateFilterType.dart';
import 'package:_12sale_app/core/components/camera/CameraPreviewScreen.dart';
import 'package:_12sale_app/core/components/button/MenuButton.dart';
import 'package:_12sale_app/core/components/card/MenuDashboard.dart';
import 'package:_12sale_app/core/components/card/WeightCude.dart';
import 'package:_12sale_app/core/components/card/dashboard/BudgetCard.dart';
import 'package:_12sale_app/core/components/chart/BarChart.dart';
import 'package:_12sale_app/core/components/chart/ItemSummarize.dart';
import 'package:_12sale_app/core/components/chart/LineChart.dart';
import 'package:_12sale_app/core/components/chart/SummarybyMonth.dart';
import 'package:_12sale_app/core/components/chart/TrendingMusicChart.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/campaign/Campaign.dart';
import 'package:_12sale_app/core/page/giveaways/GiveAwaysHistoryScreen.dart';
import 'package:_12sale_app/core/page/giveaways/GiveAwaysScreen.dart';
import 'package:_12sale_app/core/page/notification/NotificationScreen.dart';
import 'package:_12sale_app/core/page/3D_canvas/Ractangle3D.dart';
import 'package:_12sale_app/core/page/printer/ManagePrinterScreen.dart';
import 'package:_12sale_app/core/page/printer/PrinterScreen.dart';
import 'package:_12sale_app/core/page/report/CheckInReport.dart';
import 'package:_12sale_app/core/page/sendmoney/SendMoneyScreen.dart';
import 'package:_12sale_app/core/page/sendmoney/SendMoneyScreenTable.dart';
import 'package:_12sale_app/core/page/setting/SettingScreen.dart';
import 'package:_12sale_app/core/page/stock/StockScreen.dart';
import 'package:_12sale_app/core/page/stock/StockScreenTest.dart';
import 'package:_12sale_app/core/page/withdraw/WithDrawScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Shipping.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/Target.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/table/TestGridTable.dart';
import 'package:timezone/standalone.dart' as tz;

enum PeriodType { day, month, year }

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({super.key});

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  Dashboard? data;
  String reason = '';
  int _current = 0;
  Timer? _locationTimer;
  late Map<String, String> languages = {};
  String? selectedLanguageCode;
  int totalSale = 0;

  final CarouselSliderController _controller = CarouselSliderController();
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";
  String date =
      "${DateFormat('dd').format(DateTime.now())}${DateFormat('MM').format(DateTime.now())}${DateTime.now().year}";

  List<FlSpot> spots = [];
  bool isLoading = true;

  // Dashboard
  // double percent = 100;

  final now = DateTime.now();

  PeriodType _period = PeriodType.month;
  late int _year;
  late int _month;
  late int _day;

  double _sale = 0;
  double _target = 0;
  double percent = 0;

  final _thFmt = NumberFormat.decimalPattern('th_TH');
  final _thCurrency = NumberFormat.currency(locale: 'th_TH', symbol: '฿');

  String yyyymmdd(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  Future<void> getDataSummaryChoince(String type) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/order/getSummarybyChoice',
        method: 'POST',
        body: {
          "area": "${User.area}",
          "date": "$date",
          "type": "$type",
        },
      );
      if (response.statusCode == 200) {
        print(response.data['data']['total']);
        setState(() {
          totalSale = response.data['data']['total'];
        });
      }
    } catch (e) {
      print("Error on getDataSummaryChoince is $e");
    }
  }

  Future<void> getTarget(String startDate, String endDate) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/order/getTarget?startDate=${startDate}&endDate=${endDate}&area=${User.area}',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        setState(() {
          data = Dashboard.fromJson(response.data);
          _target = response.data['target'];
          percent = response.data['targetPercent'];
        });
        print("data ${data}");
      }
    } catch (e) {
      print("Error on getTarget is $e");
    }
  }

  Future<void> getDataSummary() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/order/getSummarybyMonth?area=${User.area}&period=${period}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        // dashboard = data.map((item) => MonthlySummary.fromJson(item)).toList();
        var data = response.data['data'];
        spots = data.map<FlSpot>((item) {
          double x = (item['month'] as num).toDouble();
          double y = (item['summary'] as num).toDouble();
          return FlSpot(x, y);
        }).toList();
        setState(() {
          isLoading = false;
        });
      }
      // print(spots);
    } catch (e) {
      print("Error on getDataSummary is $e");
    }
  }

  void onPageChange(int index, CarouselPageChangedReason changeReason) {
    setState(() {
      reason = changeReason.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    getDataSummary();
    getTarget('', '');
    // getDataSummaryChoince('day');
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

  // void currentLocation() async {
  //   try {
  //     Position position = await getCurrentLocation();
  //     print('Current location: ${position.latitude}, ${position.longitude}');
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  // void startLocationUpdates() {
  //   _locationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     currentLocation(); // Call your currentLocation function every 5 seconds
  //   });
  // }

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

  Widget build(BuildContext context) {
    selectedLanguageCode = context.locale.toString().split("_")[0];
    double screenWidth = MediaQuery.of(context).size.width;
    // double percent = _target == 0 ? 0.0 : (_sale / _target).clamp(0, 1);
    return Container(
        padding: const EdgeInsets.all(10.0),
        // height: screenWidth / 2.5,
        // width: screenWidth / 1.5,
        child: Column(
          children: [
            // ในหน้าหลักของคุณ (เช่น build ของหน้า Dashboard)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DateFilter(
                  initialType: DateFilterType.day, // day | month | year
                  initialDate: DateTime.now(),
                  onRangeChanged: (range, type) async {
                    // ใช้ range.start และ range.end
                    // ตัวอย่าง: ส่งไป query backend

                    final startDate = yyyymmdd(DateTime(
                        range.start.year, range.start.month, range.start.day));

                    final endDate = yyyymmdd(DateTime(
                        range.end.year, range.end.month, range.end.day));

                    // context.loaderOverlay.show();
                    await getTarget(startDate, endDate);
                    print('startDate ${startDate} endDate ${endDate}');
                    print('type=$type start=${range.start} end=${range.end}');
                    // context.loaderOverlay.hide();
                  },
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _KpiCard(
                  title: 'ยอดขาย',
                  value: _thCurrency.format(data?.sale ?? 0),
                  qty: (data?.saleQty ?? 0).toString(),
                  icon: Icons.shopping_cart_checkout,
                ),
                _KpiCard(
                  title: 'เป้าหมาย',
                  value: _thCurrency.format(_target),
                  qty: (data?.saleQty ?? 0).toString(),
                  icon: Icons.flag,
                ),
                _PercentCard(
                  percent: percent,
                  icon: Icons.percent,
                  label: 'เปอร์เซ็น',
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _KpiCard(
                  title: 'ยอดคืนดี',
                  value: _thCurrency.format(data?.good ?? 0),
                  qty: (data?.goodQty ?? 0).toString(),
                  icon: Icons.change_circle_outlined,
                ),
                _KpiCard(
                  title: 'ยอดคืนเสีย',
                  value: _thCurrency.format(data?.damaged ?? 0),
                  qty: (data?.damagedQty ?? 0).toString(),
                  icon: Icons.change_circle_outlined,
                ),
                _KpiCard(
                  title: 'ยอดรวมคืน',
                  value: _thCurrency.format(data?.refund ?? 0),
                  qty: (data?.refundQty ?? 0).toString(),
                  icon: Icons.monetization_on_outlined,
                ),
              ],
            ),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     _KpiCard(
            //       title: 'ยอดแจกสินค้า',
            //       value: _thCurrency.format(data?.give ?? 0),
            //       qty: (data?.giveQty ?? 0).toString(),
            //       icon: FontAwesomeIcons.gift,
            //     ),
            //     _KpiCard(
            //       title: 'ยอดเบิก',
            //       value: _thCurrency.format(data?.withdraw ?? 0),
            //       qty: (data?.withdrawQty ?? 0).toString(),
            //       icon: Icons.local_shipping,
            //     ),
            //     _KpiCard(
            //       title: 'ยอดรับ',
            //       value: _thCurrency.format(data?.recieve ?? 0),
            //       qty: (data?.recieveQty ?? 0).toString(),
            //       icon: Icons.local_shipping,
            //     ),
            //   ],
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     _KpiCard(
            //       title: 'ยอดรับ',
            //       value: _thCurrency.format(data?.recieve ?? 0),
            //       qty: (data?.recieveQty ?? 0).toString(),
            //       icon: Icons.local_shipping,
            //     ),
            //   ],
            // ),
            // Flexible(
            //   child: LayoutBuilder(
            //     builder: (context, constraints) {
            //       final isWide = constraints.maxWidth > 820;
            //       return GridView.count(
            //         crossAxisCount: isWide ? 3 : 1,
            //         crossAxisSpacing: 16,
            //         mainAxisSpacing: 16,
            //         childAspectRatio: isWide ? 1.6 : 2.8,
            //         children: [

            //         ],
            //       );
            //     },
            //   ),
            // ),
            // const BudgetCard(
            //   title: 'Total Sales',
            //   icon: Icons.attach_money,
            //   color: Colors.green,
            // ),
            // SizedBox(height: 300, width: screenWidth, child: LineChartSample()),
            // isLoading
            //     ? CircularProgressIndicator()
            //     : SizedBox(
            //         height: 335,
            //         width: screenWidth,
            //         child: SummarybyMonth(
            //           spots: spots,
            //         ),
            //       ),
            SizedBox(height: screenWidth / 37),
            Column(
              children: [
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
                  title_2: "รายงานขาย/ส่งเงิน",
                  icon_2: FontAwesomeIcons.moneyBillTransfer,
                  onTap2: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SendMoneyScreenTable(),
                      ),
                    );
                  },
                  title_3: "สต๊อกสินค้า",
                  icon_3: Icons.warehouse_rounded,
                  onTap3: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StockScreenTest(),
                      ),
                    );
                  },
                  title_4: "แจกสินค้า",
                  icon_4: FontAwesomeIcons.gift,
                  onTap4: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => GiveawaysHistoryScreen()),
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
                      MaterialPageRoute(
                          builder: (context) => const SettingScreen()),
                    );
                  },
                  title_7: "ประกาศข่าวสาร",
                  icon_7: Icons.campaign_outlined,
                  onTap7: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Campaign()),
                    );
                  },
                  title_8: "รายงานยอดขาย",
                  icon_8: Icons.line_axis,
                  onTap8: () async {
                    try {
                      final url =
                          Uri.parse('https://apps.onetwotrading.co.th/');
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      print('❌ Error launching URL: $e');
                    }
                  },
                ),
                // MenuDashboard(
                //   title_1: "ประกาศข่าวสาร",
                //   icon_1: Icons.campaign_outlined,
                //   onTap1: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (context) => Campaign(),
                //       ),
                //     );
                //   },
                //   title_2: "คู่มือการใช้งาน",
                //   icon_2: Icons.book,
                //   onTap2: () async {
                //     try {
                //       final url = Uri.parse(
                //           'https://apps.onetwotrading.co.th/sale/manual');
                //       await launchUrl(
                //         url,
                //         mode: LaunchMode.externalApplication,
                //       );
                //     } catch (e) {
                //       print('❌ Error launching URL: $e');
                //     }
                //   },
                //   title_3: "เข้าเยี่ยม",
                //   icon_3: Icons.route_outlined,
                //   onTap3: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (context) => const CheckinReport(),
                //       ),
                //     );
                //   },
                //   title_4: "กำลังพัฒนา",
                //   icon_4: Icons.build_circle_outlined,
                //   onTap4: () {},
                //   title_5: "กำลังพัฒนา",
                //   icon_5: Icons.build_circle_outlined,
                //   onTap5: () {},
                //   title_6: "กำลังพัฒนา",
                //   icon_6: Icons.build_circle_outlined,
                //   onTap6: () {},
                //   title_7: "กำลังพัฒนา",
                //   icon_7: Icons.build_circle_outlined,
                //   onTap7: () {},
                //   title_8: "กำลังพัฒนา",
                //   icon_8: Icons.build_circle_outlined,
                //   onTap8: () {},
                // ),
              ],
            ),
            SizedBox(height: screenWidth / 37),
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
        ));
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value,
            style: TextStyle(fontSize: 18, color: Colors.blueAccent)),
      ),
    );
  }
}

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.qty,
    required this.icon,
  });

  final String title;
  final String value;
  final String qty;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 110,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Styles.secondaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Styles.primaryColor,
                ),
                child: Icon(
                  icon,
                  color: Styles.white,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Styles.black18(context),
                  ),
                  Text(
                    value,
                    style: Styles.black18(context),
                  ),
                  Text(
                    qty,
                    style: Styles.black18(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PercentCard extends StatelessWidget {
  const _PercentCard({
    required this.percent,
    required this.label,
    required this.icon,
  });

  final double percent; // 0..1
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 110,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Styles.secondaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Styles.primaryColor,
                ),
                child: Icon(
                  icon,
                  color: Styles.white,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: Styles.black18(context),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(percent * 100).toStringAsFixed(2)}%',
                    style: Styles.black18(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Metrics {
  final double sale;
  final double target;
  const Metrics(this.sale, this.target);
}

class FakeRepository {
// Simulate different metrics by period
  static Future<Metrics> getMetrics(
    PeriodType type, {
    required int year,
    required int month,
    required int day,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

// simple deterministic mock based on inputs
    final seed = year * 10000 + month * 100 + day;
    final base = (seed % 9 + 2) * 10000; // 20k..100k

    switch (type) {
      case PeriodType.day:
        return Metrics(base * 0.35, base * 0.5);
      case PeriodType.month:
        return Metrics(base * 8, base * 10);
      case PeriodType.year:
        return Metrics(base * 90, base * 110);
    }
  }
}

class _DashboardHeaderState extends State<DashboardHeader> {
  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  late SharedPreferences sharedPreferences;
  DateTime now = DateTime.now();

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: screenWidth / 6,
                                        // margin: EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                            color: Styles.successTextColor,
                                            borderRadius:
                                                BorderRadius.horizontal(
                                                    right: Radius.circular(50),
                                                    left: Radius.circular(50))),

                                        child: Center(
                                          child: Text(
                                            '${User.role.toUpperCase()}',
                                            style:
                                                Styles.headerWhite24(context),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth / 6,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        decoration: const BoxDecoration(
                                            color: Styles.successTextColor,
                                            borderRadius:
                                                BorderRadius.horizontal(
                                                    right: Radius.circular(50),
                                                    left: Radius.circular(50))),
                                        child: Center(
                                          child: Text(
                                            '${User.area.toUpperCase()}',
                                            style:
                                                Styles.headerWhite24(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "เวอร์ชั่น ${_packageInfo.version}",
                                          style: Styles.white16(context),
                                        ),
                                      ],
                                    ),
                                  )
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
