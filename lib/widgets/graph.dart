import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Graph widget to show live Udharo (red) and Collection (blue)
class Graph extends StatelessWidget {
  final List<double> udharoHistory;      // Red line: total udharo
  final List<double> collectionHistory;  // Blue line: total collection

  const Graph({
    super.key,
    required this.udharoHistory,
    required this.collectionHistory,
  });

  @override
  Widget build(BuildContext context) {
    int maxLength = udharoHistory.length > collectionHistory.length
        ? udharoHistory.length
        : collectionHistory.length;

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxLength > 0 ? (maxLength - 1).toDouble() : 1,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  return Text("${value.toInt() + 1}",
                      style: const TextStyle(fontSize: 12));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                udharoHistory.length,
                    (index) => FlSpot(index.toDouble(), udharoHistory[index]),
              ),
              isCurved: true,
              barWidth: 3,
              color: Colors.redAccent,
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(
              spots: List.generate(
                collectionHistory.length,
                    (index) =>
                    FlSpot(index.toDouble(), collectionHistory[index]),
              ),
              isCurved: true,
              barWidth: 3,
              color: Colors.blueAccent,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
