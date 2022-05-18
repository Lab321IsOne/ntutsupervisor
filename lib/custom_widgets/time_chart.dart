import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TimeChart extends StatelessWidget {
  final List _times;
  const TimeChart({Key key, List times})
      : _times = times,
        super(key: key);

  // Lerps between a [LinearGradient] colors, based on [t]
  Color lerpGradient(List<Color> colors, List<double> stops, double t) {
    if (stops == null || stops.length != colors.length) {
      stops = [];

      // provided gradientColorStops is invalid and we calculate it here
      colors.asMap().forEach((index, color) {
        final percent = 1.0 / colors.length;
        stops.add(percent * index);
      });
    }

    for (var s = 0; s < stops.length - 1; s++) {
      final leftStop = stops[s], rightStop = stops[s + 1];
      final leftColor = colors[s], rightColor = colors[s + 1];
      if (t <= leftStop) {
        return leftColor;
      } else if (t < rightStop) {
        final sectionT = (t - leftStop) / (rightStop - leftStop);
        return Color.lerp(leftColor, rightColor, sectionT);
      }
    }
    return colors.last;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    List<DateTime> _timeData = [];
    _times.forEach((timestamp) {
      // print(timestamp);
      _timeData.add(timestamp.toDate());
    });
    print(_timeData);

    List<int> indicatorList = [];
    _timeData.forEach((time) {
      indicatorList.add(time.hour * 60 + time.minute);
    });

    int count = 0;
    List<FlSpot> allSpots = List<FlSpot>.generate(24 * 60, (index) {
      if (count < _timeData.length && index == indicatorList[count]) count++;
      // print('x = $index, y = $count');
      return FlSpot(index.toDouble(), count.toDouble());
    });

    final lineBars = [
      LineChartBarData(
        spots: allSpots,
        showingIndicators: indicatorList,
        dotData: FlDotData(show: false),
        // 顯示點點
        barWidth: 2,
        isCurved: false,
        colors: [
          Colors.blue,
          Colors.indigo,
          Colors.deepPurple,
        ],
        belowBarData: BarAreaData(
          show: true,
          colors: [
            Colors.blue.withOpacity(0.25),
            Colors.indigo.withOpacity(0.25),
            Colors.deepPurple.withOpacity(0.25),
          ],
        ),
        shadow: Shadow(
          blurRadius: 8,
          color: Colors.black,
        ),
        colorStops: [0.4, 0.8, 0.9],
      ),
    ];

    return Container(
      height: 280.0,
      width: 400.0,
      child: LineChart(
        LineChartData(
          lineBarsData: lineBars,
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: true,
              getTitles: (value) => value.toInt().toString(),
              // getTextStyles: (value) => TextStyle(
              //   fontWeight: FontWeight.bold,
              //   color: Colors.blue,
              //   fontSize: 16,
              // ),
            ),
            bottomTitles: SideTitles(
              showTitles: true,
              interval: 10, // 10 minutes
              getTitles: (value) {
                if (value == 1430) return '24';
                if (value % 240 == 0) return (value ~/ 60).toString();
                return '';
              },
              // getTextStyles: (value) => TextStyle(
              //   fontWeight: FontWeight.bold,
              //   color: Colors.indigo,
              //   fontSize: 16,
              // ),
            ),
          ),
          axisTitleData: FlAxisTitleData(
            leftTitle: AxisTitle(
              showTitle: true,
              titleText: '更換次數',
            ),
            bottomTitle: AxisTitle(
              showTitle: true,
              titleText: '時間',
            ),
            topTitle: AxisTitle(
              showTitle: true,
              titleText: '${now.month}/${now.day}',
              textAlign: TextAlign.left,
              textStyle:
                  TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.indigo,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                return lineBarsSpot.map((lineBarSpot) {
                  int _hours = (lineBarSpot.x) ~/ 60;
                  int _minutes = (lineBarSpot.x.toInt()) % 60;
                  String hours = (_hours < 10 ? '0$_hours' : '$_hours');
                  String minutes = (_minutes < 10 ? '0$_minutes' : '$_minutes');

                  return LineTooltipItem(
                    '$hours:$minutes',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(color: Colors.indigo),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 4.5,
                      color: lerpGradient(
                          barData.colors, barData.colorStops, percent / 100),
                      strokeWidth: 1.5,
                      strokeColor: Colors.black,
                    ),
                  ),
                );
              }).toList();
            },
          ),
          showingTooltipIndicators: indicatorList.map((index) {
            return ShowingTooltipIndicators([
              LineBarSpot(lineBars[0], 1, lineBars[0].spots[index]),
            ]);
          }).toList(),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.indigo),
          ),
        ),
      ),
    );
  }
}
