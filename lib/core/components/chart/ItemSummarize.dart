import 'package:_12sale_app/core/styles/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ItemSummarize extends StatefulWidget {
  ItemSummarize({
    super.key,
  });

  @override
  State<ItemSummarize> createState() => _ItemSummarizeState();
}

class _ItemSummarizeState extends State<ItemSummarize> {
  @override
  Widget build(BuildContext context) {
    final tooltipsOnBar = LineChartBarData(
        belowBarData: BarAreaData(
          color: Styles.primaryColor.withOpacity(0.2),
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
        spots: const [
          FlSpot(1, 3),
          FlSpot(2, 2),
          FlSpot(4, 5),
          FlSpot(6, 6),
          FlSpot(8, 4),
          FlSpot(10, 5),
          FlSpot(11, 6),
          FlSpot(12, 6),
        ],
        dotData: FlDotData(show: true), // Shows dots at data points
        isCurved: true,
        preventCurveOverShooting: true,
        color: Styles.primaryColor,
        isStrokeJoinRound: true,
        // isStepLineChart: true,
        isStrokeCapRound: true
        // isStrokeCapRound: true,
        );

    final showingTooltipOnSpots = [
      0,
      1,
      2,
      3,
      4,
      5,
      6,
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
                "ข้อมูลตัวอย่าง ${"chart.item_chart.title".tr()}",
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
                    axisNameSize: 25,
                    axisNameWidget: Text(
                      "chart.item_chart.count".tr(),
                      style: Styles.black18(context),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}',
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
                showingTooltipIndicators: showingTooltipOnSpots.map((index) {
                  return ShowingTooltipIndicators(
                    [
                      LineBarSpot(
                        tooltipsOnBar,
                        0, // Index of the bar in lineBarsData
                        tooltipsOnBar
                            .spots[index], // The specific spot to show tooltip
                      ),
                    ],
                  );
                }).toList(),
                // showingTooltipIndicators: showingTooltipOnSpots,
                // minY: 0,
                maxY: 8,
                maxX: 12,
                minX: 1,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      dashArray: [10, 10],
                      y: 4,
                      color: Colors.red,
                      label: HorizontalLineLabel(
                        labelResolver: (p0) => "${p0.y} AVG.",
                        alignment: Alignment.bottomCenter,
                        show: true,
                        style: Styles.red18(context),
                      ),
                    ),
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
