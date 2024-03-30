/// Create a chart with the given paramaters
/// TO-DO:
/// *Make sure data is periodically updated (e.g, every 30 seconds)
library;

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:syncfusion_flutter_charts/charts.dart";

class _ChartData {
  _ChartData({this.x, this.y});
  final DateTime? x;
  final int? y;
}

//Holds the data source of chart
class ChartClass extends StatefulWidget {
  final String sensor;
  const ChartClass({super.key, required this.sensor});

  @override
  State<ChartClass> createState() => _ChartClassState();
}

class _ChartClassState extends State<ChartClass> {
  List<_ChartData> chartData = <_ChartData>[];
  bool _dataFetched = false; // Flag to track whether data has been fetched

  @override
  void initState() {
    if (!_dataFetched) {
      getDataFromFirestore().then((results) {
        setState(() {});
      });
    }
    super.initState();
  }

  Future<void> getDataFromFirestore() async {
    var data = await FirebaseFirestore.instance.collection("readings").get();
    List<_ChartData> list = data.docs.map((e) {
      DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(e.id));
      int? sensorValue = e.data()[widget.sensor];
      return _ChartData(x: timestamp, y: sensorValue);
    }).toList();

    setState(() {
      chartData = list;
      _dataFetched = true; // Set flag to true after fetching data
    });
  }

  Widget createChart() {
    return SfCartesianChart(
        title: ChartTitle(text: widget.sensor),
        primaryXAxis: const DateTimeAxis(),
        primaryYAxis: const NumericAxis(),
        series: [
          LineSeries<_ChartData, DateTime>(
              dataSource: chartData,
              xValueMapper: (_ChartData data, _) => data.x,
              yValueMapper: (_ChartData data, _) => data.y),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return createChart();
  }
}
