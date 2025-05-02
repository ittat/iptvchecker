
import 'package:fluent_ui/fluent_ui.dart';
import 'package:iptvChecker/colors.dart';

class AppHeader extends StatelessWidget {


  const AppHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(FluentIcons.t_v_monitor, color: AppColors.accent),
                SizedBox(width: 8),
                Text('M3U8 测试平台', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            children: [
             
            ],
          ),
        ],
      ),
    );
  }
}