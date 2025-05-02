import 'dart:typed_data';

import 'package:iptvChecker/models/channel.dart';
import 'package:iptvChecker/models/channel_state.dart';
import 'package:iptvChecker/platform_interface.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../colors.dart';
import '../models/channel_test_result.dart';

class ChannelList extends StatefulWidget {
  final List<Channel> channels;
  final String? Function(String) getChannelUrl;
  final List<ChannelTestState> testStatuses;
  final bool isBatchTesting;
  final Future<void> Function(int) onRunTest;
  final Future<void> Function() onBatchTest;
  final void Function() onExportReport;

  const ChannelList({
    Key? key,
    required this.channels,
    required this.getChannelUrl,
    required this.testStatuses,
    required this.isBatchTesting,
    required this.onRunTest,
    required this.onBatchTest,
    required this.onExportReport,
  }) : super(key: key);

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  int currentPage = 1;
  int pageSize = 8;
  String filterText = "";
  bool? filterAvailable;
  String? filterStatus;
  late TextEditingController _filterController;

  @override
  void initState() {
    super.initState();
    _filterController = TextEditingController(text: filterText);
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChannelList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 状态管理已移到父组件
  }

  List<int> get pagedIndexes {
    final minLen = widget.channels.length;
    final filtered = List.generate(minLen, (i) => i).toList();
    if (filtered.isEmpty) return [];
    final start = (currentPage - 1) * pageSize;
    if (start >= filtered.length) return [];
    final end = (start + pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get totalPages {
    final minLen = widget.channels.length;
    print("minLen: $minLen");
    final filtered = List.generate(minLen, (i) => i).length;
    return (filtered / pageSize).ceil().clamp(1, 999);
  }

  // 测试方法已移到父组件

  @override
  Widget build(BuildContext context) {
    final testStatuses = widget.testStatuses;
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.2,
            ),
            itemCount: pagedIndexes.length,
            itemBuilder: (context, idx) {
              final index = pagedIndexes[idx];
              final channel = widget.channels[index];
              final status = testStatuses[index];
              final testResult = status.testResult;
              return Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChannelLogo(logoUrl: channel.logo),
                    SizedBox(height: 12),
                    Expanded(
                      
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  channel.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    ChannelTestStatus(status: status.status),
                                    if (testResult != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Icon(
                                          testResult.available
                                              ? FluentIcons.check_mark
                                              : FluentIcons.status_error_full,
                                          color:
                                              testResult.available
                                                  ? AppColors
                                                      .successPrimaryColor
                                                  : AppColors.error,
                                          size: 18,
                                        ),
                                      ),
                                  ],
                                ),
                                // SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '耗时: ${testResult?.elapsedMs?.toString() ?? '-'}ms',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                    // SizedBox(width: 12),
                                    // Text(
                                    //   '时长: ${testResult?.duration?.toStringAsFixed(2) ?? '-'}s',
                                    //   style: TextStyle(
                                    //     fontSize: 12,
                                    //     color: AppColors.grey,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          status.isLoading
                              ? Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: ProgressRing(strokeWidth: 2),
                                ),
                              )
                              : ChannelTestButton(
                                isLoading: status.isLoading,
                                onPressed: () => widget.onRunTest(index),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8),
        // 分页控件
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(FluentIcons.chevron_left),
              onPressed:
                  currentPage > 1 ? () => setState(() => currentPage--) : null,
            ),
            Text('第$currentPage/$totalPages页', style: TextStyle(fontSize: 13)),
            IconButton(
              icon: Icon(FluentIcons.chevron_right),
              onPressed:
                  currentPage < totalPages
                      ? () => setState(() => currentPage++)
                      : null,
            ),
          ],
        ),
      ],
    );
  }
}

class ChannelLogo extends StatelessWidget {
  final String? logoUrl;
  const ChannelLogo({Key? key, this.logoUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (logoUrl == null) return SizedBox.shrink();
    return Image.network(
      logoUrl!,
      width: 90,
      color: AppColors.grey,
      // height: 90,
      errorBuilder: (context, error, stackTrace) => Icon(FluentIcons.error),
    );
  }
}

class ChannelTestStatus extends StatelessWidget {
  final String status;
  const ChannelTestStatus({Key? key, required this.status}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case "测试成功":
        color = AppColors.successPrimaryColor;
        break;
      case "测试失败":
        color = AppColors.error;
        break;
      case "测试中":
        color = AppColors.warning;
        break;
      default:
        color = AppColors.grey;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ChannelTestButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const ChannelTestButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Button(onPressed: isLoading ? null : onPressed, child: Text('测试'));
  }
}
