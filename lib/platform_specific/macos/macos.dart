import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iptvChecker/platform_interface.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../models/channel_test_result.dart';
import '../../models/channel_tester.dart';

class MacosPlatform extends PlatformInterface {
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
  @override
  Future<ChannelTestResult> testChannel(String url) async {
    try {
      // 获取ffprobe路径
      final resourcePath = await MethodChannel('flutter/native').invokeMethod('getResourcePath');
      ChannelTester tester = ChannelTester(ffprobePath: '$resourcePath/ffprobe', url: url);
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
  static void showSystemUI() {
    // MacOS平台显示系统UI逻辑
    print('Showing MacOS system UI');
  }
  
  static void manageWindow() {
    // MacOS平台窗口管理逻辑
    print('Managing MacOS window');
  }
  

  /// 验证流媒体数据是否包含有效的视频或音频流
  bool _verifyStream(Map<String, dynamic> probeData) {
    // 检查是否存在流数据
    if (probeData['streams'] == null) return false;
    
    // 检查是否有视频或音频流
    return probeData['streams'].any((stream) => 
      stream['codec_type'] == 'video' || stream['codec_type'] == 'audio');
  }
  
  @override
  static Future<bool> validateFFprobePath(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      
      // 检查文件是否可执行
      final result = await Process.run('chmod', ['+x', path]);
      if (result.exitCode != 0) return false;
      
      final versionCheck = await Process.run(path, ['-version']);
      return versionCheck.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}
