import 'package:fluent_ui/fluent_ui.dart';
import 'package:iptvChecker/platform_interface.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _proxyUrl = '';
  String _ffprobePath = '';
  String? _error;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: ScaffoldPage(
        header: PageHeader(title: Text('设置')),
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoLabel(
                  label: '代理地址',
                  child: TextFormBox(
                    placeholder: '请输入代理地址',
                    onSaved: (value) => _proxyUrl = value ?? '',
                  ),
                ),
                SizedBox(height: 16),
                InfoLabel(
                  label: 'FFprobe路径',
                  child: TextFormBox(
                    placeholder: '请输入FFprobe路径',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入FFprobe路径';
                      }
                      return null;
                    },
                    onSaved: (value) => _ffprobePath = value ?? '',
                  ),
                ),
                SizedBox(height: 24),
                FilledButton(
                  child: Text('保存设置'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final isValid = await PlatformInterface.validateFFprobePath(_ffprobePath);
                      if (!isValid) {
                        setState(() {
                          _error = 'FFprobe路径无效';
                        });
                        return;
                      }
                      setState(() {
                        _error = null;
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: InfoBar(
                      title: Text(_error!),
                      severity: InfoBarSeverity.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}