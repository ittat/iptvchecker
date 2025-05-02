import 'package:flutter/material.dart';
import 'package:iptvChecker/media_charts.dart';
import 'package:iptvChecker/platform_interface.dart';
import 'package:iptvChecker/platform_specific/windows/windows.dart';
import 'package:iptvChecker/platform_specific/linux/linux.dart';
import 'package:iptvChecker/platform_specific/macos/macos.dart';
import 'package:iptvChecker/components/media_charts.dart';
import 'package:flutter_image/network.dart';

class MediaInfoView extends StatefulWidget {
  final String filePath;
  
  const MediaInfoView({Key? key, required this.filePath}) : super(key: key);

  @override
  _MediaInfoViewState createState() => _MediaInfoViewState();
}

class _MediaInfoViewState extends State<MediaInfoView> {
  Map<String, dynamic>? mediaInfo;
  String? error;
  
  @override
  void initState() {
    super.initState();
    _loadMediaInfo();
  }
  
  Future<void> _loadMediaInfo() async {
    try {
      final info = await PlatformInterface.getPlatform().getMediaInfo(widget.filePath);
      setState(() {
        mediaInfo = info;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(child: Text('错误: $error'));
    }
    
    if (mediaInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (mediaInfo!['thumbnailPaths'] != null)
              ThumbnailPreview(thumbnailPaths: List<String>.from(mediaInfo!['thumbnailPaths'])),
            if (mediaInfo!['format'] != null)
              Column(
                children: [
                  Text('格式信息:', style: Theme.of(context).textTheme.titleLarge),
                  Text('格式名称: ${mediaInfo!['format']['format_name']}'),
                  Text('时长: ${mediaInfo!['format']['duration']}秒'),
                  Text('大小: ${mediaInfo!['format']['size']}字节'),
                ],
              ),
            if (mediaInfo!['bitrate_history'] != null) ...[              
              BitrateChart(bitrates: mediaInfo!['bitrate_history']),
              const SizedBox(height: 16),
            ],
            if (mediaInfo!['thumbnails'] != null) ...[
              ThumbnailPreview(thumbnailPaths: mediaInfo!['thumbnails']),
              const SizedBox(height: 16),
            ],
            if (mediaInfo!['format'] != null) ...[
              Text('格式信息:', style: Theme.of(context).textTheme.titleLarge),
              Text('格式名称: ${mediaInfo!['format']['format_name']}'),
              Text('时长: ${mediaInfo!['format']['duration']}秒'),
              Text('大小: ${mediaInfo!['format']['size']}字节'),
              const SizedBox(height: 16),
            ],
            if (mediaInfo!['streams'] != null) ...[
              Text('流信息:', style: Theme.of(context).textTheme.titleLarge),
              ...mediaInfo!['streams'].map<Widget>((stream) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('类型: ${stream['codec_type']}'),
                    if (stream['codec_type'] == 'video') ...[
                      Text('分辨率: ${stream['width']}x${stream['height']}'),
                      Text('帧率: ${stream['avg_frame_rate']}'),
                    ],
                    if (stream['codec_type'] == 'audio') ...[
                      Text('采样率: ${stream['sample_rate']}Hz'),
                      Text('声道: ${stream['channels']}'),
                      if (stream['waveform_samples'] != null)
                        AudioWaveformChart(samples: List<double>.from(stream['waveform_samples'])),
                      if (stream['spectrogram'] != null)
                        SpectrogramChart(data: List<List<double>>.from(stream['spectrogram'])),
                    ],
                    if (stream['codec_type'] == 'video' && stream['frame_rates'] != null)
                      FrameRateChart(frameRates: List<double>.from(stream['frame_rates'])),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}