import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BitrateChart extends StatelessWidget {
  final List<double> bitrates;
  
  BitrateChart({Key? key, required this.bitrates}) : super(key: key) {
    _validateBitrateData(bitrates);
  }
  
  static void _validateBitrateData(List<double> bitrates) {
    if (bitrates.isEmpty) {
      throw ArgumentError('比特率数据不能为空');
    }
    
    final invalidValues = bitrates.where((rate) => rate <= 0 || rate > 10000000);
    if (invalidValues.isNotEmpty) {
      throw ArgumentError('发现无效比特率值: ${invalidValues.join(', ')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: bitrates.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
        ),
      ),
    );
  }
}

class ThumbnailPreview extends StatelessWidget {
  final List<String> thumbnailPaths;
  
  const ThumbnailPreview({Key? key, required this.thumbnailPaths}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: thumbnailPaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.network(thumbnailPaths[index], width: 160),
          );
        },
      ),
    );
  }
}

class SpectrogramChart extends StatelessWidget {
  final List<List<double>> data;
  
  const SpectrogramChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: data.asMap().entries.map((e) {
            final avg = e.value.reduce((a, b) => a + b) / e.value.length;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: avg,
                  color: Colors.blue,
                  width: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
        ),
      ),
    );
  }
}