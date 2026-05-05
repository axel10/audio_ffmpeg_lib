#include "include/audio_ffmpeg_lib/audio_ffmpeg_lib_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "audio_ffmpeg_lib_plugin.h"

void AudioFfmpegLibPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  audio_ffmpeg_lib::AudioFfmpegLibPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
