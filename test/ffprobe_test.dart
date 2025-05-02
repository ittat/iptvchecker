import 'package:flutter/services.dart';
import 'package:iptvChecker/platform_interface.dart';
import 'package:iptvChecker/platform_specific/macos/macos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('FFprobe功能测试', () {
    final macosPlatform = MacosPlatform();
    
    // test('测试ffprobe路径验证', () async {
    //   final isValid = await MacosPlatform.validateFFprobePath(
    //     '/Users/hardy/Documents/iptvchecker/macos/Runner/Resources/ffprobe' // 直接指定ffprobe路径
    //   );
    //   expect(isValid, isTrue);
    // });
    
    // test('测试媒体信息获取', () async {
    //   try {
    //     final info = await macosPlatform.getMediaInfo('/Users/hardy/Documents/iptvchecker/test.m3u8'); // 确保test.m3u8文件存在
    //     print('获取到媒体信息: $info');
    //     expect(info, isNotNull);
    //     expect(info['video'], isNotNull);
    //     expect(info['audio'], isNotNull);
    //     print('测试通过，获取到媒体信息: $info');
    //   } catch (e) {
    //     fail('获取媒体信息失败: $e');
    //   }
    // });
    
    // test('测试缩略图生成', () async {
    //   try {
    //     final info = await macosPlatform.getMediaInfo('test.m3u8'); // 确保test.m3u8文件存在
    //     expect(info['thumbnails'], isNotNull);
    //     print('缩略图路径: ${info['thumbnails']}');
    //   } catch (e) {
    //     fail('生成缩略图失败: $e');
    //   }
    // });
    
    test('ChannelTester功能测试', () async {
      final tester = ChannelTester(
        ffprobePath: '/Users/hardy/Documents/iptvchecker/macos/Runner/Resources/ffprobe',
        url: 'https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/hls/xgplayer-demo.m3u8',
      );
      final result = await tester.testChannel();
      print('ChannelTester结果: ${result.available}, ${result.elapsedMs}, ${result.error}, ${result.duration}, ${result.httpStatus}, ${result.ffprobeExit}');
      expect(result.available, isTrue);
      expect(result.elapsedMs, isNotNull);
      expect(result.error, isNull);
      expect(result.duration, isNotNull);
      expect(result.ffprobeExit, 0);
    });

        test('ChannelTester功能测试- 报错', () async {
      final tester = ChannelTester(
        ffprobePath: '/Users/hardy/Documents/iptvchecker/macos/Runner/Resources/ffprobe',
                url: 'http://ottrrs.hl.chinamobile.com/PLTV/88888888/224/3221226007/index.m3u8',
      );
      final result = await tester.testChannel();
         expect(result.available, isFalse);
      expect(result.elapsedMs, isNotNull);
      expect(result.error, isNotNull);
      expect(result.duration, isNull);
      expect(result.ffprobeExit, 1);
    });
  });
}