import 'package:flutter/material.dart';
import 'package:iptvChecker/components/channel_list.dart';
import 'package:iptvChecker/components/m3u8_drop_zone.dart';
import 'package:iptvChecker/components/settings_screen.dart';
import 'package:iptvChecker/media_info_view.dart';
import 'package:iptvChecker/platform_apps/linux_app.dart';
import 'package:iptvChecker/platform_apps/macos_app.dart';
import 'package:iptvChecker/platform_apps/windows_app.dart';
import 'dart:io';
import 'package:iptvChecker/platform_interface.dart';
import 'package:iptvChecker/platform_specific/linux/linux.dart';
import 'package:iptvChecker/platform_specific/macos/macos.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

import 'platform_specific/windows/windows.dart';


void main() {

  runApp(MaterialApp(
    home: M3U8UploadScreen(),
  ));
}

class M3U8UploadScreen extends StatefulWidget {
  @override
  _M3U8UploadScreenState createState() => _M3U8UploadScreenState();
}

class _M3U8UploadScreenState extends State<M3U8UploadScreen> {
  List<String> channels = [];
  List<String> channelUrls = [];

  String? _getChannelUrl(String channelInfo) {
    final index = channels.indexOf(channelInfo);
    return index >= 0 && index < channelUrls.length ? channelUrls[index] : null;
  }

  // 流媒体验证重试机制
  Future<bool> _verifyStream(String url, {int maxRetries = 3, Duration timeout = const Duration(seconds: 10), String? proxy}) async {
    int retryCount = 0;
    final httpClient = HttpClient();
    
    if (proxy != null) {
      final proxyParts = proxy.split(':');
      if (proxyParts.length == 2) {
        httpClient.findProxy = (uri) => 'PROXY ${proxyParts[0]}:${proxyParts[1]}';
      }
    }
    
    while (retryCount < maxRetries) {
      try {
        final request = await httpClient.getUrl(Uri.parse(url))
          .timeout(timeout);
        final response = await request.close();
        if (response.statusCode == 200) {
          return true;
        }
      } catch (e) {
        if (retryCount == maxRetries - 1) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
      retryCount++;
    }
    return false;
  }

  Future<void> _handleFileDrop(List<File> files) async {
    if (files.isNotEmpty) {
      final file = files.first;
      if (path.extension(file.path) == '.m3u8') {
        try {
          final content = await file.readAsString();
          final lines = content.split('\n');
          
          // 验证M3U8文件有效性
          if (!lines.any((line) => line.startsWith('#EXTM3U'))) {
            throw FormatException('无效的M3U8文件格式');
          }
          
          // 解析频道信息
          final parsedChannels = <String>[];
          final parsedUrls = <String>[];
          
          for (int i = 0; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.startsWith('#EXTINF')) {
              if (i + 1 < lines.length && !lines[i+1].startsWith('#')) {
                parsedChannels.add(line);
                parsedUrls.add(lines[i+1].trim());
              }
            }
          }
          
          if (parsedChannels.isEmpty) {
            throw FormatException('未找到有效的频道信息');
          }
          
          setState(() {
            channels = parsedChannels;
            channelUrls = parsedUrls;
          });
          
        } on FormatException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('解析错误: ${e.message}'))
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('读取文件失败: ${e.toString()}'))
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请拖放.m3u8格式的文件'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IPTV频道检查器'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                channels = [];
                channelUrls = [];
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          
          if (channels.isEmpty)
            Expanded(
              child: M3U8DropZone(
                onFileDrop: _handleFileDrop,
              ),
            ),
          if (channels.isNotEmpty)
            Expanded(
              child: ChannelList(
                channels: channels,
                channelUrls: channelUrls,
                getChannelUrl: _getChannelUrl,
              ),
            ),
        ],
      ),
    );
  }


}

