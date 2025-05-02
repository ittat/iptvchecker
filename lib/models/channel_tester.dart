import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'channel_test_result.dart';

class ChannelTester {
  final String ffprobePath;
  final String url;
  ChannelTester({required this.ffprobePath, required this.url});

  /// 测试给定的电视频道URL是否有效
  ///
  /// 使用ffprobe工具检测流媒体URL的有效性
  /// 注意：需要确保应用有网络访问权限
  /// 
  /// 参数:
  ///   url - 要测试的电视频道URL
  ///
  /// 返回值:
  ///   返回Future<ChannelTestResult>，包含详细测试信息
  Future<ChannelTestResult> testChannel() async {
    bool available = false;
    int? httpStatus;
    int? ffprobeExit;
    double? duration;
    String? error;
    dynamic streams;
    dynamic ffprobeRaw;
    final stopwatch = Stopwatch()..start();
    try {
      final ffprobe = await Process.run(ffprobePath, [
        '-v', 'error',
        '-show_entries', 'format=duration',
        '-show_streams',
        '-show_error',
        '-show_format',
        '-print_format', 'json',
        '-analyzeduration', '10000000',
        '-probesize', '15000000',
        url
      ]).timeout(const Duration(seconds: 25));
      ffprobeExit = ffprobe.exitCode;
      if (ffprobe.exitCode != 0) {
        error = ffprobe.stderr.toString();
        return ChannelTestResult(
          available: false,
          httpStatus: httpStatus,
          ffprobeExit: ffprobeExit,
          duration: duration,
          error: error,
          streams: streams,
          ffprobeRaw: ffprobeRaw,
          elapsedMs: stopwatch.elapsedMilliseconds,
        );
      }
      final probeData = jsonDecode(ffprobe.stdout.toString());
      duration = double.tryParse(probeData['format']?['duration']?.toString() ?? '0') ?? 0;
      available = duration > 9.5;
      streams = probeData['streams'];
      ffprobeRaw = probeData;
    } on TimeoutException {
      error = 'ffprobe超时，网络不稳定或不可用';
    } catch (e) {
      error = e.toString();
    } finally {
      stopwatch.stop();
    }
    return ChannelTestResult(
      available: available,
      httpStatus: httpStatus,
      ffprobeExit: ffprobeExit,
      duration: duration,
      error: error,
      streams: streams,
      ffprobeRaw: ffprobeRaw,
      elapsedMs: stopwatch.elapsedMilliseconds,
    );
  }
}