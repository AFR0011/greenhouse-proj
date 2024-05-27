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
      height: MediaQuery.of(context).size.height*.5,
      width: MediaQuery.of(context).size.width * 0.9,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 24,
            minY: 10,
            maxY: 50,
            titlesData: const FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 4,
                  reservedSize: 30,
                )
              ),
              topTitles: AxisTitles(sideTitles:SideTitles(
                showTitles: false,
              )),
              rightTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: false,
                
              ),
            )
              
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all()
            ),
            gridData:FlGridData(
              show: true,
              getDrawingHorizontalLine: (value){
                return const FlLine(
                  color: Colors.amber,
                  strokeWidth:.5,

                );
              }
            ) ,
            lineBarsData: [LineChartBarData(
              spots: [
                const FlSpot(0, 23),
                const FlSpot(2, 19),
                const FlSpot(7, 25),
                const FlSpot(12, 35),
                const FlSpot(15, 40),
                const FlSpot(18, 28),
                const FlSpot(22, 25),
              ],
              isCurved: true,
              gradient: const LinearGradient(colors: [Colors.red,Colors.blue]),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(colors: [Colors.red.withOpacity(.1),Colors.blue.withOpacity(0.1)]),
              )

            ),]
          )
        ),
      ),
    );

  }
}
