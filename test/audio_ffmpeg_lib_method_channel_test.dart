import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_ffmpeg_lib/audio_ffmpeg_lib_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAudioFfmpegLib platform = MethodChannelAudioFfmpegLib();
  const MethodChannel channel = MethodChannel('audio_ffmpeg_lib');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
