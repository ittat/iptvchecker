# Flutter桌面版API参考

## 核心API

### 播放列表处理
```dart
/// 解析M3U播放列表
Future<List<Channel>> parsePlaylist(String m3uContent);

/// 验证播放列表URL有效性
Future<bool> validatePlaylistUrl(String url);
```

### 流媒体检测
```dart
/// 检测单个流媒体URL
Future<StreamStatus> checkStream(String url);

/// 批量检测流媒体URL列表
Future<List<StreamStatus>> checkStreams(List<String> urls);
```

### 结果处理
```dart
/// 获取检测结果统计
StreamStats getStatistics(List<StreamStatus> results);

/// 导出结果为CSV文件
Future<void> exportToCsv(List<StreamStatus> results, String filePath);
```

## 工具类API

### FFprobe封装
```dart
/// 获取媒体文件信息
Future<MediaInfo> getMediaInfo(String filePath);

/// 获取流媒体信息
Future<MediaInfo> getStreamInfo(String url);
```

### 平台工具
```dart
/// 打开系统文件选择器
Future<String?> openFilePicker();

/// 显示原生通知
void showNotification(String title, String message);
```