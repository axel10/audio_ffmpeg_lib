#ifndef FLUTTER_PLUGIN_AUDIO_FFMPEG_LIB_PLUGIN_H_
#define FLUTTER_PLUGIN_AUDIO_FFMPEG_LIB_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace audio_ffmpeg_lib {

class AudioFfmpegLibPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AudioFfmpegLibPlugin();

  virtual ~AudioFfmpegLibPlugin();

  // Disallow copy and assign.
  AudioFfmpegLibPlugin(const AudioFfmpegLibPlugin&) = delete;
  AudioFfmpegLibPlugin& operator=(const AudioFfmpegLibPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace audio_ffmpeg_lib

#endif  // FLUTTER_PLUGIN_AUDIO_FFMPEG_LIB_PLUGIN_H_
