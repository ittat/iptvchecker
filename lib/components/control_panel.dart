import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:iptvChecker/components/m3u8_drop_zone.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onBatchTest;
  final VoidCallback onExportReport;
  final Function(List<File>) onFileDrop;
  final VoidCallback onClear;
  final VoidCallback onExportAvailableChannels;

  const ControlPanel({
    Key? key,
    required this.onBatchTest,
    required this.onExportReport,
    required this.onFileDrop,
    required this.onClear,
    required this.onExportAvailableChannels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(children: [M3U8DropZone(onFileDrop: onFileDrop)]),
          ),
          Container(
            width: double.infinity,
            //  height: double.infinity,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),

            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20,top: 5),
                  child: Text(
                    '批量操作',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                ),
                Button(
                  onPressed: onBatchTest,
                  style: ButtonStyle(
                    backgroundColor: ButtonState.all(Colors.blue),
                    padding: ButtonState.all(EdgeInsets.all(12)),
                    shape: ButtonState.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    foregroundColor: ButtonState.all(Colors.white),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(child: Column()),
                      Icon(FluentIcons.play_solid, size: 16),
                      SizedBox(width: 8),
                      Text('一键测试'),
                      Expanded(child: Column()),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Button(
                  onPressed: onExportAvailableChannels,
                  style: ButtonStyle(
                    backgroundColor: ButtonState.all(Colors.green),
                    padding: ButtonState.all(EdgeInsets.all(12)),
                    shape: ButtonState.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    foregroundColor: ButtonState.all(Colors.white),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(child: Column()),
                      Icon(FluentIcons.save, size: 16),
                      SizedBox(width: 8),
                      Text('导出可用频道'),
                      Expanded(child: Column()),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Button(
                  onPressed: onClear,
                  style: ButtonStyle(
                    padding: ButtonState.all(EdgeInsets.all(12)),
                    shape: ButtonState.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),side: BorderSide(color: Colors.red))),
                    foregroundColor: ButtonState.all(Colors.red),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(child: Column()),
                      Icon(FluentIcons.delete, size: 16),
                      SizedBox(width: 8),
                      Text('清空频道列表'),
                      Expanded(child: Column()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
