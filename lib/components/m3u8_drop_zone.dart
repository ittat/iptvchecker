import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class M3U8DropZone extends StatelessWidget {
  final Function(List<File>) onFileDrop;
  
  const M3U8DropZone({
    Key? key,
    required this.onFileDrop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<File>(
      onAccept: (files) => onFileDrop([files]),
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.green : Colors.blue,
              width: 2
            ),
            borderRadius: BorderRadius.circular(10),
            color: candidateData.isNotEmpty ? Colors.green.withOpacity(0.1) : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file, size: 48, color: candidateData.isNotEmpty ? Colors.green : Colors.blue),
                SizedBox(height: 8),
                Text('拖放M3U8文件到这里', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['m3u8'],
                    );
                    if (result != null) {
                      onFileDrop(result.paths.map((path) => File(path!)).toList());
                    }
                  },
                  child: Text('选择文件'),
                ),
                if (candidateData.isNotEmpty)
                  Text('释放以导入文件', style: TextStyle(color: Colors.green))
              ],
            ),
          ),
        );
      },
    );
  }
}