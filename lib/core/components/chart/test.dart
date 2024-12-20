import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWithCustomTooltips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Data points for the chart
    final tooltipsOnBar = LineChartBarData(
      isCurved: true,
      spots: [
        FlSpot(0, 1),
        FlSpot(2, 3),
        FlSpot(4, 7),
        FlSpot(6, 4),
        FlSpot(8, 6),
      ],
      isStrokeCapRound: true,
      // colors: [Colors.blue],
      barWidth: 3,
      dotData: FlDotData(show: true), // Show dots on points
    );

    // Indices of points to show tooltips for
    final showingTooltipOnSpots = [
      0,
      2,
      4
    ]; // Show tooltips on 1st, 3rd, and 5th points

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: 8,
          minY: 0,
          maxY: 10,
          lineBarsData: [tooltipsOnBar],
          showingTooltipIndicators: showingTooltipOnSpots.map((index) {
            return ShowingTooltipIndicators([
              LineBarSpot(
                tooltipsOnBar,
                0, // Index of the bar in lineBarsData
                tooltipsOnBar.spots[index], // The specific spot to show tooltip
              ),
            ]);
          }).toList(),
          lineTouchData: LineTouchData(
            enabled: false, // Tooltips are static; no need for interaction
            touchTooltipData: LineTouchTooltipData(
              // tooltipBgColor: Colors.grey.withOpacity(0.8),
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    'X: ${spot.x}, Y: ${spot.y}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: LineChartWithCustomTooltips()));
