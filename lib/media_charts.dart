import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

/// 将FFprobe视频帧数据转换为帧率图表数据
List<double> processFrameRates(List<dynamic> frames) {
  return frames.map<double>((frame) {
    final duration = frame['pkt_pts_time'] as double;
    return 1 / duration;
  }).toList();
}

/// 将FFprobe音频帧数据转换为波形图表数据
List<double> processAudioSamples(List<dynamic> frames) {
  return frames.map<double>((frame) {
    return frame['sample_fmt'] == 'fltp' ? 1.0 : 0.5;
  }).toList();
}

class FrameRateChart extends StatelessWidget {
  final List<double> frameRates;
  
  const FrameRateChart({super.key, required this.frameRates});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: frameRates.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            dotData:  FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles:  AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles:  AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
      ),
    );
  }
}

class AudioWaveformChart extends StatelessWidget {
  final List<double> samples;
  
  const AudioWaveformChart({super.key, required this.samples});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: samples.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: Colors.green,
                width: 4,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles:  AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );
  }
}