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
  final double miny, maxy;
  final List values;
  const ChartClass(
      {super.key,
      required this.maxy,
      required this.miny,
      required this.values});

  @override
  Widget build(BuildContext context) {
    print("Values $values");
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LineChart(LineChartData(
            minX: 0,
            maxX: 24,
            minY: miny,
            maxY: maxy,
            titlesData: const FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: true,
                  interval: 4,
                  reservedSize: 30,
                )),
                topTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: false,
                )),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                )),
            borderData: FlBorderData(show: true, border: Border.all()),
            gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(
                    color: Colors.amber,
                    strokeWidth: .5,
                  );
                }),
            lineBarsData: [
              LineChartBarData(
                  dotData: const FlDotData(show: false),
                  spots: values
                      .map((value) => createSpot(values.indexOf(value), value))
                      .toList(),
                  isCurved: true,
                  gradient:
                      const LinearGradient(colors: [Colors.red, Colors.blue]),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(colors: [
                      Colors.red.withOpacity(.1),
                      Colors.blue.withOpacity(0.1)
                    ]),
                  )),
            ])),
      ),
    );
  }
}

FlSpot createSpot(index, value) {
  return FlSpot(index * 4.roundToDouble(), value.roundToDouble());
}
