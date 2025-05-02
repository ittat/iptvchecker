import 'package:flutter/material.dart';
import 'package:iptvChecker/platform_interface.dart';
import 'dart:io';
import 'dart:convert';

class LinuxPlatform extends PlatformInterface {
  static void showSystemUI() {
    // Linux平台显示系统UI逻辑
    print('Showing Linux system UI');
  }
  
  static void manageWindow() {
    // Linux平台窗口管理逻辑
    print('Managing Linux window');
  }
  
  @override
  Future<Map<String, dynamic>> getMediaInfo(String filePath) async {
    try {
      final result = await Process.run('ffprobe', [
        '-v', 'error',
        '-show_format',
        '-show_streams',
        '-show_frames',
        '-select_streams', 'v',
        '-show_entries', 'frame=pkt_pts_time,pict_type',
        '-show_entries', 'format=bit_rate,duration,size',
        '-show_entries', 'stream=codec_name,width,height,avg_frame_rate',
        '-of', 'json',
        filePath
      ]);
      
      if (result.exitCode != 0) {
        throw Exception('FFprobe执行失败: ${result.stderr}');
      }
      
      return jsonDecode(result.stdout);
    } catch (e) {
      throw Exception('获取媒体信息失败: $e');
    }
  }
  
  @override
  Future<bool> validateFFprobePath(String path) async {
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
  
   @override
  Future<bool> testChannel(String url) async {
    try {

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      
      // Check HTTP status code, 2xx and 3xx are considered valid
      return response.statusCode >= 200 && response.statusCode < 400;
  
    
    } catch (e) {
      return false;
    }
  }

}