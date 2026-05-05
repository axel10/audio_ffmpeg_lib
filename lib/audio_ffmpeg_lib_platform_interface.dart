import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'audio_ffmpeg_lib_method_channel.dart';

abstract class AudioFfmpegLibPlatform extends PlatformInterface {
  /// Constructs a AudioFfmpegLibPlatform.
  AudioFfmpegLibPlatform() : super(token: _token);

  static final Object _token = Object();

  static AudioFfmpegLibPlatform _instance = MethodChannelAudioFfmpegLib();

  /// The default instance of [AudioFfmpegLibPlatform] to use.
  ///
  /// Defaults to [MethodChannelAudioFfmpegLib].
  static AudioFfmpegLibPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AudioFfmpegLibPlatform] when
  /// they register themselves.
  static set instance(AudioFfmpegLibPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
