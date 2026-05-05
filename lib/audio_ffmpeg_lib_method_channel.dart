import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_ffmpeg_lib_platform_interface.dart';

/// An implementation of [AudioFfmpegLibPlatform] that uses method channels.
class MethodChannelAudioFfmpegLib extends AudioFfmpegLibPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audio_ffmpeg_lib');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
