import 'package:flutter/material.dart';
import 'package:iptvChecker/platform_interface.dart';
import 'dart:io';
import 'dart:convert';

class MacosPlatform extends PlatformInterface {
  @override
  Future<bool> testChannel(String url) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      
      // 检查HTTP状态码，2xx和3xx视为有效
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      return false;
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
        '-of', 'json',
        filePath
      ]);
      
      if (result.exitCode != 0) {
        throw Exception('FFprobe执行失败: ${result.stderr}');
      }
      
      final videoData = jsonDecode(result.stdout);
      
      // 获取缩略图
      final thumbResult = await Process.run('ffmpeg', [
        '-i', filePath,
        '-vf', 'thumbnail,scale=320:-1',
        '-frames:v', '5',
        '-f', 'image2',
        '-y', '/tmp/thumb-%03d.jpg'
      ]);
      
      // 获取比特率历史
      final bitrateResult = await Process.run('ffprobe', [
        '-v', 'error',
        '-show_frames',
        '-select_streams', 'v',
        '-show_entries', 'frame=pkt_size,pkt_pts_time',
        '-of', 'json',
        filePath
      ]);
      
      final audioResult = await Process.run('ffprobe', [
        '-v', 'error',
        '-show_frames',
        '-select_streams', 'a',
        '-show_entries', 'frame=pkt_pts_time,sample_fmt',
        '-of', 'json',
        filePath
      ]);
      
      if (audioResult.exitCode != 0) {
        throw Exception('FFprobe音频分析失败: ${audioResult.stderr}');
      }
      
      final audioData = jsonDecode(audioResult.stdout);
      
      // 计算比特率历史
      final bitrateData = jsonDecode(bitrateResult.stdout);
      final bitrateHistory = bitrateData['frames']?.map<double>((frame) {
        return (frame['pkt_size'] * 8) / (frame['pkt_pts_time'] ?? 1);
      }).toList();
      
      return {
        'video': videoData,
        'audio': audioData,
        'format': videoData['format'],
        'thumbnails': thumbResult.exitCode == 0 ? 
          List.generate(5, (i) => '/tmp/thumb-${i.toString().padLeft(3, '0')}.jpg') : null,
        'bitrate_history': bitrateHistory,
      };
    } catch (e) {
      throw Exception('获取媒体信息失败: $e');
    }
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