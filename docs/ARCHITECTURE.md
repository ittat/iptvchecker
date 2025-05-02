# Flutter桌面版架构设计

## 模块划分

1. **UI层**
   - 播放列表管理界面
   - 检查结果展示
   - 设置面板

2. **业务逻辑层**
   - 播放列表解析
   - 流媒体检查调度
   - 状态管理

3. **核心功能层**
   - FFprobe集成
   - HTTP请求处理
   - 错误处理

4. **平台适配层**
   - Linux/macOS/Windows特定实现
   - FFmpeg二进制分发

## 整体架构逻辑图

```mermaid
flowchart TD
    UI[UI层\n- 用户输入\n- 展示结果] -->|事件/数据| Logic[业务逻辑层\n- 检查流程控制\n- 状态管理]
    Logic -->|调用| Core[核心功能层\n- 播放列表解析\n- 流媒体检测\n- 结果分析]
    Core -->|平台相关操作| Adapter[平台适配层\n- Windows/macOS/Linux]
    Adapter -->|调用| FFmpeg[FFmpeg/FFprobe\n- 媒体信息提取]
    FFmpeg -.->|结果回传| Adapter
    Adapter -.->|适配反馈| Core
    Core -.->|处理反馈| Logic
    Logic -.->|状态更新| UI
    subgraph 注释
        direction LR
        UI说明[UI层：负责与用户交互，展示检测进度与结果]
        Logic说明[业务逻辑层：流程调度、状态管理]
        Core说明[核心功能层：实现主要检测与分析逻辑]
        Adapter说明[平台适配层：对接不同操作系统与底层工具]
        FFmpeg说明[FFmpeg/FFprobe：负责媒体信息提取]
    end
```

## 数据流

```mermaid
sequenceDiagram
    participant UI as UI界面
    participant Logic as 业务逻辑
    participant Core as 核心功能
    participant Adapter as 平台适配
    participant FFprobe as FFprobe
    UI->>+Logic: 用户点击“检查”
    Logic->>+Core: 解析播放列表
    Core->>+Adapter: 调用ffprobe获取媒体信息
    Adapter->>+FFprobe: 执行ffprobe命令
    FFprobe-->>-Adapter: 返回媒体信息(JSON)
    Adapter-->>-Core: 解析并返回媒体信息
    Core-->>-Logic: 检查结果与统计
    Logic-->>-UI: 更新状态与展示结果
    Note over UI,Logic: 关键决策点：异常处理、状态回滚
```

## 关键技术

- Flutter状态管理: Riverpod
- 原生交互: MethodChannel
- 跨平台存储: Hive
- UI框架: Fluent UI