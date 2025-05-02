import 'package:flutter/foundation.dart';
import '../models/channel.dart';
import '../models/channel_test_result.dart';

class ChannelState extends ChangeNotifier {
  List<Channel> _channels = [];
  List<ChannelTestState> _testStatuses = [];
  
  List<Channel> get channels => _channels;
  List<ChannelTestState> get testStatuses => _testStatuses;
  
  void updateChannels(List<Channel> channels) {
    _channels = channels;
    _testStatuses = channels.map((_) => ChannelTestState()).toList();
    notifyListeners();
  }
  
  // 添加其他需要共享的方法和状态
}

class ChannelTestState {
  bool isLoading = false;
  ChannelTestResult? testResult;
  String status = "未测试";
}