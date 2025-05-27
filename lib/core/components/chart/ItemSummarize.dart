import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/dashboard/MothlySummary.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ItemSummarize extends StatefulWidget {
  ItemSummarize({
    super.key,
    required this.storeId,
  });
  String storeId;

  @override
  State<ItemSummarize> createState() => _ItemSummarizeState();
}

class _ItemSummarizeState extends State<ItemSummarize> {
  List<FlSpot> spots = [];
  List<MonthlySummary> dashboard = [];
  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataSummary();
  }

  Future<void> getDataSummary() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/order/getSummarybyMonth?area=${User.area}&period=${period}&storeId=${widget.storeId}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        print(response.data['data']);
        // dashboard = data.map((item) => MonthlySummary.fromJson(item)).toList();
        var data = response.data['data'];
        spots = data.map<FlSpot>((item) {
          double x = (item['month'] as num).toDouble();
          double y = (item['summary'] as num).toDouble();
          return FlSpot(x, y);
        }).toList();
      }
      print(spots);
    } catch (e) {
      print("Error on getDataSummary is $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final tooltipsOnBar = LineChartBarData(
        belowBarData: BarAreaData(
          color: Styles.primaryColorIcons.withOpacity(0.2),
          show: true,
        ),
        // dotData: FlDotData(
        //     show: true,
        //     getDotPainter: (spot, percent, barData, index) {
        //       return FlDotCirclePainter(
        //         radius: 6,
        //         color: Colors.white,
        //         strokeWidth: 3,
        //         strokeColor: Styles.primaryColor,
        //       );
        //     },),
        show: true,
        spots: spots,
        dotData: FlDotData(show: true), // Shows dots at data points
        isCurved: true,
        preventCurveOverShooting: true,
        color: Styles.primaryColorIcons,
        isStrokeJoinRound: true,
        // isStepLineChart: true,
        isStrokeCapRound: true
        // isStrokeCapRound: true,
        );

    final showingTooltipOnSpots = [
      7,
    ]; // Valid indices for 'spots'
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ข้อมูลตัวอย่างการขายสินค้ารายเดือน",
                style: Styles.black18(context),
              )
            ],
          ),
          // SizedBox(
          //   height: 15,
          // ),
          AspectRatio(
            aspectRatio: 2,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    axisNameSize: 30,
                    axisNameWidget: Text(
                      "จำนวน",
                      style: Styles.black18(context),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70,
                      getTitlesWidget: (value, meta) {
                        return Text(
                            NumberFormat.compactCurrency(
                                    locale: 'en', symbol: '฿')
                                .format(value),
                            style: Styles.black18(context));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameSize: 25,
                    axisNameWidget: Text(
                      "chart.item_chart.month".tr(),
                      style: Styles.black18(context),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      // getTitlesWidget: (value, meta) =>
                      //     bottomTitleWidgets(value, meta, context),
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}',
                            style: Styles.black18(context));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineTouchData: LineTouchData(
                  enabled:
                      false, // Tooltips are static; no need for interaction
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.transparent,
                    tooltipRoundedRadius: 1,
                    maxContentWidth: 50,
                    tooltipPadding: EdgeInsets.only(top: 8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map(
                        (spot) {
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(0)}',
                            Styles.black18(context),
                          );
                        },
                      ).toList();
                    },
                  ),
                ),
                lineBarsData: [tooltipsOnBar],
                // showingTooltipIndicators: showingTooltipOnSpots.map((index) {
                //   return ShowingTooltipIndicators(
                //     [
                //       LineBarSpot(
                //         tooltipsOnBar,
                //         0, // Index of the bar in lineBarsData
                //         tooltipsOnBar
                //             .spots[index], // The specific spot to show tooltip
                //       ),
                //     ],
                //   );
                // }).toList(),
                // showingTooltipIndicators: showingTooltipOnSpots,
                // minY: 0,
                // maxY: 8,
                // maxX: 12,
                minX: 1,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    // HorizontalLine(
                    //   dashArray: [10, 10],
                    //   y: 4,
                    //   color: Colors.red,
                    //   label: HorizontalLineLabel(
                    //     labelResolver: (p0) => "${p0.y} AVG.",
                    //     alignment: Alignment.bottomCenter,
                    //     show: true,
                    //     style: Styles.red18(context),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
