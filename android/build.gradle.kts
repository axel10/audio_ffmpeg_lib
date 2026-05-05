import java.net.URL

group = "com.example.audio_ffmpeg_lib"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.2.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "com.example.audio_ffmpeg_lib"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

dependencies {
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
}

val ffmpegReleaseBaseUrl = (
    System.getenv("AUDIO_FFMPEG_LIB_RELEASE_BASE_URL")
        ?: "https://github.com/axel10/audio_ffmpeg_lib/releases/latest/download"
    ).trimEnd('/')
val audioFfmpegLibRoot = projectDir.parentFile
val androidJniLibsDir = file("src/main/jniLibs")
val ffmpegAbis = (
    System.getenv("AUDIO_FFMPEG_LIB_ANDROID_ABIS")
        ?: System.getenv("AUDIO_CONVERTER_ANDROID_ABIS")
        ?: "arm64-v8a,armeabi-v7a"
    ).split(Regex("[,\\s]+"))
    .map { it.trim() }
    .filter { it.isNotEmpty() }

val ffmpegAssetNamesByAbi = mapOf(
    "arm64-v8a" to "audio_ffmpeg_lib-ffmpeg-android-arm64-v8a.zip",
    "armeabi-v7a" to "audio_ffmpeg_lib-ffmpeg-android-armeabi-v7a.zip",
    "x86" to "audio_ffmpeg_lib-ffmpeg-android-x86.zip",
    "x86_64" to "audio_ffmpeg_lib-ffmpeg-android-x86_64.zip",
)

val ffmpegMarkerFilesByAbi = mapOf(
    "arm64-v8a" to audioFfmpegLibRoot.resolve("android/ffmpeg_lib/arm64-v8a/lib/libavformat.so"),
    "armeabi-v7a" to audioFfmpegLibRoot.resolve("android/ffmpeg_lib/armeabi-v7a/lib/libavformat.so"),
    "x86" to audioFfmpegLibRoot.resolve("android/ffmpeg_lib/x86/lib/libavformat.so"),
    "x86_64" to audioFfmpegLibRoot.resolve("android/ffmpeg_lib/x86_64/lib/libavformat.so"),
)

tasks.register("ensureFfmpegAssets") {
    doLast {
        ffmpegAbis.forEach { abi ->
            val marker = ffmpegMarkerFilesByAbi[abi]
                ?: throw GradleException("Unsupported Android ABI for ffmpeg assets: $abi")

            if (!marker.exists()) {
                val assetName = ffmpegAssetNamesByAbi[abi]
                    ?: throw GradleException("Unsupported Android ABI for ffmpeg assets: $abi")
                val assetUrl = URL("$ffmpegReleaseBaseUrl/$assetName")
                val tempDir = file("$buildDir/.ffmpeg-assets")
                tempDir.mkdirs()
                val tempZip = tempDir.resolve(assetName)

                logger.lifecycle("Downloading $assetName from $assetUrl")
                assetUrl.openStream().use { input ->
                    tempZip.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }

                logger.lifecycle("Unpacking $assetName into $audioFfmpegLibRoot")
                copy {
                    from(zipTree(tempZip))
                    into(audioFfmpegLibRoot)
                }

                if (!marker.exists()) {
                    throw GradleException(
                        "Failed to unpack expected ffmpeg marker file: $marker. " +
                            "Run the ffmpeg asset build scripts in audio_ffmpeg_lib first."
                    )
                }
            }

            val jniLibsAbiDir = androidJniLibsDir.resolve(abi)
            jniLibsAbiDir.mkdirs()
            copy {
                from(marker.parentFile)
                include("*.so")
                into(jniLibsAbiDir)
            }

            if (jniLibsAbiDir.listFiles()?.none { it.extension == "so" } != false) {
                throw GradleException("Failed to copy ffmpeg shared libraries into $jniLibsAbiDir")
            }

            logger.lifecycle("Synced ffmpeg shared libraries into $jniLibsAbiDir")
        }
    }
}

tasks.matching { it.name == "preBuild" }.configureEach {
    dependsOn(tasks.named("ensureFfmpegAssets"))
}
