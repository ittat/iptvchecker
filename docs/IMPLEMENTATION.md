# Flutter桌面版功能实现指南

## 播放列表检查

1. **播放列表输入**
   - 支持本地文件选择
   - 支持URL输入
   - 支持粘贴M3U内容

2. **解析实现**
```dart
class PlaylistParser {
  Future<List<Channel>> parse(String content) async {
    // 解析M3U格式
  }
}
```

## 流媒体验证

1. **FFprobe集成**
```dart
class FFprobeWrapper {
  static Future<Map> checkStream(String url) async {
    // 调用平台特定ffprobe
  }
}
```

2. **验证参数**
   - 超时设置
   - 重试机制
   - 代理配置

## 平台适配

1. **FFmpeg分发**
   - 各平台预编译二进制
   - 自动下载机制

2. **原生交互**
```dart
class NativeBridge {
  static const MethodChannel _channel = 
    MethodChannel('com.example/ffprobe');
}
```

## 错误处理

参考原项目的错误代码体系，实现对应Flutter版本。