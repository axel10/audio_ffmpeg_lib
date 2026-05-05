import 'package:flutter_test/flutter_test.dart';
import 'package:audio_ffmpeg_lib/audio_ffmpeg_lib.dart';
import 'package:audio_ffmpeg_lib/audio_ffmpeg_lib_platform_interface.dart';
import 'package:audio_ffmpeg_lib/audio_ffmpeg_lib_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioFfmpegLibPlatform
    with MockPlatformInterfaceMixin
    implements AudioFfmpegLibPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AudioFfmpegLibPlatform initialPlatform = AudioFfmpegLibPlatform.instance;

  test('$MethodChannelAudioFfmpegLib is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAudioFfmpegLib>());
  });

  test('getPlatformVersion', () async {
    AudioFfmpegLib audioFfmpegLibPlugin = AudioFfmpegLib();
    MockAudioFfmpegLibPlatform fakePlatform = MockAudioFfmpegLibPlatform();
    AudioFfmpegLibPlatform.instance = fakePlatform;

    expect(await audioFfmpegLibPlugin.getPlatformVersion(), '42');
  });
}
