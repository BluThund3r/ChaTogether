import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/interfaces/bar_chart_entry.dart';

class CustomBarChart extends StatelessWidget {
  final List<BarChartEntry> data;

  const CustomBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxYValue = data
        .map((entry) => entry.data)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxYValue + 10,
        alignment: BarChartAlignment.spaceAround,
        barGroups: data.asMap().entries.map((entry) {
          int index = entry.key;
          BarChartEntry barEntry = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                y: barEntry.data.toDouble(),
                colors: [Colors.blue],
                width: 16,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            margin: 16,
            getTitles: (double value) {
              int index = value.toInt();
              if (index < 0 || index >= data.length) {
                return '';
              }
              return data[index].monthYear;
            },
          ),
          leftTitles: SideTitles(
            showTitles: true,
            interval: (maxYValue ~/ 5).toDouble(),
            getTextStyles: (context, value) => const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            margin: 16,
            reservedSize: 14,
          ),
        ),
      ),
    );
  }
}
