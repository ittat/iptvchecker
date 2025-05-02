# FFprobe集成方案

## 集成方式
1. 通过Process调用本地FFprobe可执行文件
2. 使用flutter_ffmpeg插件
3. 自定义FFprobe封装

## 使用示例
```dart
// 调用FFprobe获取媒体信息
Future<Map<String, dynamic>> getMediaInfo(String filePath) async {
  final result = await Process.run('ffprobe', [
    '-v', 'error',
    '-show_format',
    '-show_streams',
    '-of', 'json',
    filePath
  ]);
  
  return jsonDecode(result.stdout);
}
```

## 常见问题
- 路径配置问题
- 跨平台兼容性
- 性能优化建议

## FFprobe 调用与数据流转流程图

```mermaid
sequenceDiagram
    participant App as 应用层
    participant FFprobe as FFprobe工具
    participant Core as 核心功能
    participant Logic as 业务逻辑
    participant UI as UI界面
    App->>FFprobe: 通过Process/插件调用
    FFprobe-->>App: 返回媒体信息(JSON)
    App->>Core: 解析媒体信息
    Core->>Logic: 更新检测结果
    Logic->>UI: 展示媒体详情/状态
    Note over App,FFprobe: 路径/权限/兼容性校验
    Note over Core,Logic: 关键决策点：异常处理、数据校验
    Note over UI: 支持多种展示方式与状态反馈
```