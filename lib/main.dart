import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iptvChecker/components/app_footer.dart';
import 'package:iptvChecker/components/app_header.dart';
import 'package:iptvChecker/components/channel_list.dart';
import 'package:iptvChecker/components/control_panel.dart';
import 'package:iptvChecker/models/channel_state.dart';
import 'package:iptvChecker/platform_interface.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:iptvChecker/models/channel.dart';
import 'package:cross_file/cross_file.dart';

void main() {
  runApp(FluentApp(
    home: M3U8UploadScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class M3U8UploadScreen extends StatefulWidget {
  @override
  _M3U8UploadScreenState createState() => _M3U8UploadScreenState();
}


class _M3U8UploadScreenState extends State<M3U8UploadScreen> {
  List<Channel> channels = [];
  List<ChannelTestState> testStatuses = [];
  bool isBatchTesting = false;

  Future<void> _runTest(int index) async {
    setState(() {
      testStatuses[index]
        ..isLoading = true
        ..status = "测试中"
        ..testResult = null;
    });
    final url = _getChannelUrl(channels[index].name);
    if (url != null) {
      try {
        final result = await PlatformInterface.getPlatform().testChannel(url);
        setState(() {
          testStatuses[index]
            ..testResult = result
            ..status = result.available ? "测试成功" : "测试失败"
            ..isLoading = false;
        });
      } catch (e) {
        setState(() {
          testStatuses[index]
            ..testResult = null
            ..status = "测试失败"
            ..isLoading = false;
        });
      }
    } else {
      setState(() {
        testStatuses[index]
          ..isLoading = false
          ..status = "未测试"
          ..testResult = null;
      });
    }
  }

  Future<void> batchTest() async {
    setState(() => isBatchTesting = true);
    await Future.wait(List.generate(channels.length, (i) => _runTest(i)));
    setState(() => isBatchTesting = false);
  }

  void exportReport() async {
    final buffer = StringBuffer();
    buffer.write('\uFEFF');
    buffer.writeln('频道名称,频道URL,Logo,测试状态,可用,耗时(ms),时长(s),错误信息');
    for (int i = 0; i < channels.length; i++) {
      final c = channels[i];
      final s = testStatuses[i];
      final r = s.testResult;
      buffer.writeln('"${c.name}","${c.url}","${c.logo ?? ''}",${s.status},${r?.available == true ? "是" : "否"},${r?.elapsedMs ?? "-"},${r?.duration?.toStringAsFixed(2) ?? "-"},"${r?.error ?? ''}"');
    }
    final bytes = buffer.toString().codeUnits;
    final file = XFile.fromData(Uint8List.fromList(bytes), name: '测试报告.csv', mimeType: 'text/csv');
    await file.saveTo('测试报告.csv');
    if (mounted) {
      displayInfoBar(context, builder: (context, close) => InfoBar(title: Text('导出成功'), content: Text('测试报告已保存为 测试报告.csv'), severity: InfoBarSeverity.success));
    }
  }

  Future<void> _exportAvailableChannels() async {
    final availableChannels = channels.where((c) => testStatuses[channels.indexOf(c)].testResult?.available == true).toList();
    if (availableChannels.isEmpty) {
      displayInfoBar(context, builder: (context, close) => InfoBar(title: Text('无可用频道'), content: Text('没有找到可用的频道'), severity: InfoBarSeverity.warning));
      return;
    }
    
    final buffer = StringBuffer();
    buffer.writeln('#EXTM3U');
    for (final channel in availableChannels) {
      buffer.writeln('#EXTINF:-1 tvg-logo="${channel.logo ?? ''}",${channel.name}');
      buffer.writeln(channel.url);
    }
    
    final bytes = buffer.toString().codeUnits;
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: '保存频道列表',
      fileName: '可用频道.m3u8',
      type: FileType.custom,
      allowedExtensions: ['m3u8'],
    );
    if (savePath != null) {
      final file = XFile.fromData(Uint8List.fromList(bytes), name: path.basename(savePath), mimeType: 'application/x-mpegURL');
      await file.saveTo(savePath);
      // if (mounted) {
      //   displayInfoBar(context, builder: (context, close) => InfoBar(
      //     title: Text('导出成功'), 
      //     content: Text('可用频道已保存为 ${path.basename(savePath)}'),
      //     severity: InfoBarSeverity.success
      //   ));
      // }
    }
    
    if (mounted) {
      displayInfoBar(context, builder: (context, close) => InfoBar(title: Text('导出成功'), content: Text('可用频道已保存为 可用频道.m3u8'), severity: InfoBarSeverity.success));
    }
  }

  String? _getChannelUrl(String channelName) {
    final channel = channels.firstWhere((c) => c.name == channelName, orElse: () => Channel(name: '', url: ''));
    return channel.name.isNotEmpty ? channel.url : null;
  }

  Future<void> _handleFileDrop(List<File> files) async {
    if (files.isNotEmpty) {
      final file = files.first;
      if (path.extension(file.path) == '.m3u8') {
        try {
          final content = await file.readAsString();
          final lines = content.split('\n');
          if (!lines.any((line) => line.startsWith('#EXTM3U'))) {
            throw FormatException('无效的M3U8文件格式');
          }
          final channels = <Channel>[];
          for (int i = 0; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.startsWith('#EXTINF')) {
              if (i + 1 < lines.length && !lines[i+1].startsWith('#')) {
                final name = line.split(',').last.trim();
                final logoMatch = RegExp(r'tvg-logo="([^"]+)"').firstMatch(line);
                final logo = logoMatch?.group(1);
                final url = lines[i+1].trim();
                channels.add(Channel(
                  name: name,
                  url: url,
                  logo: logo,
                ));
              }
            }
          }
          if (channels.isEmpty) {
            throw FormatException('未找到有效的频道信息');
          }
          setState(() {
            this.channels = channels;
            this.testStatuses = channels.isNotEmpty
                ? List.generate(channels.length, (_) => ChannelTestState())
                : <ChannelTestState>[];
          });
        } on FormatException catch (e) {
          displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('解析错误'), content: Text(e.message), severity: InfoBarSeverity.error));
        } catch (e) {
          displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('读取文件失败'), content: Text(e.toString()), severity: InfoBarSeverity.error));
        }
      } else {
        displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('文件格式错误'), content: const Text('请拖放.m3u8格式的文件'), severity: InfoBarSeverity.warning));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Column(
        children: [
          AppHeader(   ),
          Expanded(
            child: Row(
              children: [
                // 左侧文件操作区
                ControlPanel(
                  onBatchTest: batchTest,
                  onExportReport: exportReport,
                  onFileDrop: _handleFileDrop,
                  onExportAvailableChannels: _exportAvailableChannels,
                 onClear: () {
              setState(() {
                channels = [];
              });
            },
                ),
                // 右侧频道列表区
                Expanded(
                  child: ChannelList(
                    channels: channels ??[],
                    getChannelUrl: _getChannelUrl,
                    testStatuses: testStatuses,
                    isBatchTesting: isBatchTesting,
                    onRunTest: _runTest,
                    onBatchTest: batchTest,
                    onExportReport: exportReport,
                  ),
                ),
              ],
            ),
          ),
          // 底部状态栏
          AppFooter(
            channels: channels,
            testStatuses: testStatuses,
          ),
        ],
      ),
    );
  }
}

