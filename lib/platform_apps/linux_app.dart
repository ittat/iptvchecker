import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iptvChecker/media_info_view.dart';

class MyAppLinux extends StatelessWidget {
  final Map<String, dynamic> demoMediaInfo;
  
  const MyAppLinux({super.key, required this.demoMediaInfo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('IPTV Checker')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: MediaInfoView(filePath: demoMediaInfo?['filePath'] ?? ''),
          ),
        ),
      ),
    );
  }
}

class LinuxNotification {
  static void showNotification(String title, String message) {
    if (Platform.isLinux) {
      Process.run('notify-send', [title, message]);
    }
  }
}