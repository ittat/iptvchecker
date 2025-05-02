import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:iptvChecker/models/channel_tester.dart';
import 'package:iptvChecker/platform_interface.dart';
import '../../models/channel_test_result.dart';

class WindowsPlatform extends PlatformInterface {
  @override
  Future<ChannelTestResult> testChannel(String url) async {
    try {
      final resourcePath = await _getResourcePath();
      ChannelTester tester = ChannelTester(ffprobePath: '$resourcePath/ffprobe.exe', url: url);
      final testResult = await tester.testChannel();
      print('测试结果: $testResult');
      return testResult;
    } catch (e) {
      if (e.toString().contains('Operation not permitted') || 
          e.toString().contains('Permission denied')) {
        print('测试频道失败: 网络权限受限，请确保应用有网络访问权限');
        print('详细错误: $e');
        return ChannelTestResult(
          available: false,
          error: '网络权限受限: $e',
          elapsedMs: 0,
        );
      } else {
        print('测试频道失败: $e');
        return ChannelTestResult(
          available: false,
          error: e.toString(),
          elapsedMs: 0,
        );
      }
    }
  }
  Future<String> _getResourcePath() async {
    // 这里假设有类似macos的资源路径获取逻辑
    return await MethodChannel('flutter/native').invokeMethod('getResourcePath');
  }
}
