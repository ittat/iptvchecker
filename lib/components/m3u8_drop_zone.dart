import 'package:fluent_ui/fluent_ui.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../colors.dart';

class M3U8DropZone extends StatefulWidget {
  final Function(List<File>) onFileDrop;
  const M3U8DropZone({Key? key, required this.onFileDrop}) : super(key: key);

  @override
  State<M3U8DropZone> createState() => _M3U8DropZoneState();
}

class _M3U8DropZoneState extends State<M3U8DropZone> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (details) {
        setState(() {
          _dragging = false;
        });
      },
      onDragDone: (details) {
        setState(() {
          _dragging = false;
        });
        final files =
            details.files
                .where((x) => path.extension(x.path).toLowerCase() == '.m3u8')
                .map((x) => File(x.path))
                .toList();
        if (files.isNotEmpty) {
          widget.onFileDrop(files);
        }
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 10, top: 10,bottom: 10),
            child: Text(
              '文件上传',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
          ),
          DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(10),
            dashPattern: [6, 3],
            color: _dragging ? AppColors.successPrimaryColor : AppColors.grey,
            strokeWidth: 1,
            padding: EdgeInsets.only(top: 40, bottom: 30, left: 20, right: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:
                    _dragging
                        ? AppColors.successPrimaryColor.withOpacity(0.1)
                        : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FluentIcons.upload,
                      size: 28,
                      color:
                          _dragging
                              ? AppColors.successPrimaryColor
                              : AppColors.accent,
                    ),
                    SizedBox(height: 8),
                    Text('拖放M3U8文件到这里', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 16),
                    Button(
                      style: ButtonStyle(
                        backgroundColor: ButtonState.all(Colors.blue),
                        padding: ButtonState.all(EdgeInsets.all(12)),
                        shape: ButtonState.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                       
                        foregroundColor: ButtonState.all(Colors.white),
                      ),
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['m3u8'],
                            );
                        if (result != null) {
                          widget.onFileDrop(
                            result.paths.map((path) => File(path!)).toList(),
                          );
                        }
                      },
                      child: Text('选择文件'),
                    ),
                    if (_dragging)
                      Text(
                        '释放以导入文件',
                        style: TextStyle(color: AppColors.successPrimaryColor),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
