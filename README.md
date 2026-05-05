# audio_ffmpeg_lib

FFmpeg 资产承载插件。

这个项目负责构建、打包和分发 FFmpeg 的动态库或静态库，供同级的 `audio_converter` 只做转码使用。

## 用法

如果你在本地维护这套仓库，先在这里生成 ffmpeg 资产，再让 `audio_converter` 读取这些产物。

常用脚本：

```bash
tooling/ensure_ffmpeg_assets.sh ios
tooling/ensure_ffmpeg_assets.sh macos
tooling/ensure_ffmpeg_assets.sh android
tooling/package_ffmpeg_assets.sh
```

默认发布地址：

`https://github.com/axel10/audio_ffmpeg_lib/releases/latest/download`

如果你需要自定义发布源，可以设置：

`AUDIO_FFMPEG_LIB_RELEASE_BASE_URL`

如果你需要本地指定 ffmpeg 资产根目录，可以设置：

`AUDIO_FFMPEG_LIB_ROOT`

