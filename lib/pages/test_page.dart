import 'package:firevisor/custom_widgets/time_chart.dart';
//import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TimeCurvePage extends StatefulWidget {
  static const sName = "/test_page";

  @override
  _TimeCurvePageState createState() => _TimeCurvePageState();
}

class _TimeCurvePageState extends State<TimeCurvePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('機器狀態列表'),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 40.0),
            TimeChart(),
          ],
        ),
      ),
    );
  }
}
