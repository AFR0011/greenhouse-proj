/// Create a chart with the given paramaters
/// TO-DO:
/// *Make sure data is periodically updated (e.g, every 30 seconds)
library;

import 'package:fl_chart/fl_chart.dart';
import "package:flutter/material.dart";

// class _ChartData {
//   _ChartData({this.x, this.y});
//   final DateTime? x;
//   final int? y;
// }

class ChartClass extends StatelessWidget {
  const ChartClass({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.9,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.teal.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.teal.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 4,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toString(),
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}°C',
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.teal.shade700, width: 2),
            ),
            minX: 0,
            maxX: 24,
            minY: 0,
            maxY: 6,
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 3),
                  FlSpot(1, 1),
                  FlSpot(2, 4),
                  FlSpot(3, 3),
                  FlSpot(4, 2),
                  FlSpot(5, 5),
                  FlSpot(6, 3),
                ],
                isCurved: true,
                color: Colors.teal.shade700,
                barWidth: 4,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.teal.shade400.withOpacity(0.2),
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.shade400.withOpacity(0.4),
                      Colors.teal.shade100.withOpacity(0.2),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Colors.teal.shade700,
                      strokeWidth: 3,
                      strokeColor: Colors.teal.shade100,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
