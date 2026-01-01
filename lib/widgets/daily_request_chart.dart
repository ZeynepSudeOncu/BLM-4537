import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyRequestChart extends StatelessWidget {
  const DailyRequestChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 5),
              FlSpot(2, 2),
              FlSpot(3, 6),
              FlSpot(4, 4),
              FlSpot(5, 7),
              FlSpot(6, 5),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}
