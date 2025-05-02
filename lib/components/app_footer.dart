import 'package:fluent_ui/fluent_ui.dart';
import 'package:iptvChecker/colors.dart';
import 'package:iptvChecker/models/channel.dart';
import 'package:iptvChecker/models/channel_state.dart';

class AppFooter extends StatefulWidget {
  final List<Channel> channels;
  final List<ChannelTestState> testStatuses;

  const AppFooter({
    Key? key,
    required this.channels,
    required this.testStatuses,
  }) : super(key: key);

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  int get testedCount =>
      widget.testStatuses.where((s) => s.status == "测试成功").length;
  int get failedCount =>
      widget.testStatuses.where((s) => s.status == "测试失败").length;
  int get testingCount =>
      widget.testStatuses.where((s) => s.status == "测试中").length;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Colors.white,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('频道总数: ${widget.channels.length}'),
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
           
                  SizedBox(width: 16),
                  Text(
                    '成功: $testedCount',
                    style: TextStyle(
                      color: AppColors.successPrimaryColor,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '失败: $failedCount',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '测试中: $testingCount',
                    style: TextStyle(color: AppColors.warning, fontSize: 13),
                  ),
                ],
              ),
               SizedBox(width: 16),
              SizedBox(
                width: 180,
                child: ProgressBar(
                  value:
                      widget.channels.isEmpty
                          ? 0
                          : ((failedCount + testedCount) /
                                  widget.channels.length) *
                              100,
                  backgroundColor: AppColors.grey,
                  activeColor: AppColors.accent,
                  strokeWidth: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
