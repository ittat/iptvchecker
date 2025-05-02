import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iptvChecker/media_info_view.dart';

class MyAppWindows extends StatelessWidget {
  final Map<String, dynamic> demoMediaInfo;
  
  const MyAppWindows({super.key, required this.demoMediaInfo});

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

