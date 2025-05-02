import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '代理地址'),
                onSaved: (value) => _proxyUrl = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'FFprobe路径'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入FFprobe路径';
                  }
                  return null;
                },
                onSaved: (value) => _ffprobePath = value ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    
                    final isValid = await PlatformInterface.validateFFprobePath(_ffprobePath);
                    if (!isValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('FFprobe路径无效'))
                      );
                      return;
                    }
                    
                    Navigator.pop(context);
                  }
                },
                child: const Text('保存设置'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}