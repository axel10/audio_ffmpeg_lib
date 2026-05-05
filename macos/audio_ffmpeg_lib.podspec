#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint audio_ffmpeg_lib.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  ffmpeg_lib_root = '$(PODS_ROOT)/../Flutter/ephemeral/.symlinks/plugins/audio_ffmpeg_lib/macos/ffmpeg_lib'
  s.name             = 'audio_ffmpeg_lib'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'audio_ffmpeg_lib_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.script_phase = {
    :name => 'Ensure FFmpeg assets',
    :script => 'bash "$PODS_TARGET_SRCROOT/../tooling/ensure_ffmpeg_assets.sh" macos $ARCHS',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    :output_files => [
      "#{ffmpeg_lib_root}/arm64/lib/libavformat.a",
      "#{ffmpeg_lib_root}/amd64/lib/libavformat.a",
    ],
  }

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
