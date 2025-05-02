import 'package:flutter/material.dart';
import 'package:iptvChecker/platform_interface.dart';

class ChannelList extends StatelessWidget {
  final List<String> channels;
  final List<String> channelUrls;
  final Function(String) getChannelUrl;
  
  const ChannelList({
    Key? key,
    required this.channels,
    required this.channelUrls,
    required this.getChannelUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: channels.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(channels[index]),
          trailing: StatefulBuilder(
            builder: (context, setState) {
              bool isLoading = false;
              bool? testResult;
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  if (testResult != null)
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        testResult ? Icons.check_circle : Icons.error,
                        color: testResult ? Colors.green : Colors.red,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      if (isLoading) return;
                      
                      setState(() {
                        isLoading = true;
                        testResult = null;
                      });
                      
                      final url = getChannelUrl(channels[index]);
                      if (url != null) {
                        try {
                          final result = await PlatformInterface.getPlatform().testChannel(url);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result ? '频道测试成功' : '频道测试失败'))
                          );
                          setState(() {
                            testResult = result;
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('测试出错: ${e.toString()}'))
                          );
                          setState(() {
                            testResult = false;
                          });
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
                    child: Text('测试'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}