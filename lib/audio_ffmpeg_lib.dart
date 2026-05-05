
import 'audio_ffmpeg_lib_platform_interface.dart';

class AudioFfmpegLib {
  Future<String?> getPlatformVersion() {
    return AudioFfmpegLibPlatform.instance.getPlatformVersion();
  }
}
