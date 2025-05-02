# Flutter桌面版示例代码

## 播放列表处理示例
```dart
// 加载并解析M3U文件
Future<void> loadPlaylist() async {
  final file = await FilePicker.platform.pickFiles();
  if (file != null) {
    final content = await File(file.paths.first!).readAsString();
    final playlist = await PlaylistParser.parse(content);
    setState(() => _channels = playlist.channels);
  }
}
```

## 流媒体检测示例
```dart
// 检测单个频道
Future<void> checkChannel(Channel channel) async {
  setState(() => channel.status = ChannelStatus.checking);
  
  try {
    final result = await StreamChecker.check(channel.url);
    setState(() => channel.status = 
      result.isAlive ? ChannelStatus.alive : ChannelStatus.dead);
  } catch (e) {
    setState(() => channel.status = ChannelStatus.error);
  }
}
```

## 结果展示示例
```dart
// 构建频道列表视图
ListView.builder(
  itemCount: channels.length,
  itemBuilder: (context, index) {
    final channel = channels[index];
    return ListTile(
      leading: _buildStatusIcon(channel.status),
      title: Text(channel.name),
      subtitle: Text(channel.url),
      onTap: () => _showDetails(channel),
    );
  },
)
```

## 设置面板示例
```dart
// FFprobe路径设置
TextFormField(
  initialValue: prefs.ffprobePath,
  decoration: InputDecoration(
    labelText: 'FFprobe路径',
    hintText: '输入FFprobe可执行文件路径',
  ),
  onChanged: (value) => prefs.ffprobePath = value,
)
```