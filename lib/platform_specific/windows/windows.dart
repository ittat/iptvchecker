import 'package:flutter/material.dart';
import 'package:iptvChecker/platform_interface.dart';
import 'dart:io';
import 'dart:convert';

class WindowsPlatform extends PlatformInterface {
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
    // Windows平台显示系统UI逻辑
    print('Showing Windows system UI');
  }
  
  static void manageWindow() {
    // Windows平台窗口管理逻辑
    print('Managing Windows window');
  }
  
  @override
   Future<Map<String, dynamic>> getMediaInfo(String filePath) async {
    if (filePath.isEmpty) {
      throw ArgumentError('文件路径不能为空');
    }
    
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('文件不存在', filePath);
    }
    try {
      print('正在执行FFprobe命令，文件路径: $filePath');
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
      
      print('FFprobe命令执行完成，退出码: ${result.exitCode}');
      if (result.exitCode != 0) {
        print('FFprobe错误输出: ${result.stderr}');
        throw Exception('FFprobe执行失败: ${result.stderr}');
      }
      
      final videoData = jsonDecode(result.stdout);
      
      // 获取缩略图
      final thumbResult = await Process.run('ffmpeg', [
        '-i', filePath,
        '-vf', 'thumbnail,scale=320:-1',
        '-frames:v', '5',
        '-f', 'image2',
        '-y', 'C:\\Temp\\thumb-%03d.jpg'
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
        '-show_entries', 'stream=codec_name,sample_rate,channels',
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
        final ptsTime = frame['pkt_pts_time'] ?? 1;
        return ptsTime > 0 ? (frame['pkt_size'] * 8) / ptsTime : 0;
      }).toList();
      
      return {
        'video': videoData,
        'audio': audioData,
        'format': videoData['format'],
        'thumbnails': thumbResult.exitCode == 0 ? 
          List.generate(5, (i) => 'C:\\Temp\\thumb-${i.toString().padLeft(3, '0')}.jpg') : null,
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
      final result = await Process.run(path, ['-version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}