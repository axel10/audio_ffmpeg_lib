# Check Windows FFmpeg Build Dependencies
$ErrorActionPreference = "Stop"

Write-Host "--- Checking Windows Build Environment ---" -ForegroundColor Cyan

# Check for the custom FFmpeg build
Write-Host "`n--- Checking custom FFmpeg build ---" -ForegroundColor Cyan

$installHint = @"
Copy the 'ffmpeg-vibeflow-audio' folder to an overlay directory such as:
  D:\vcpkg\overlay-ports\ffmpeg-vibeflow-audio

Then install it with vcpkg using the custom triplet:
  New-Item -ItemType Directory -Force D:\vcpkg\overlay-ports | Out-Null
  Copy-Item -Recurse -Force .\ffmpeg-vibeflow-audio D:\vcpkg\overlay-ports\ffmpeg-vibeflow-audio
  `$env:VCPKG_OVERLAY_PORTS='D:\vcpkg\overlay-ports'
  `$env:VCPKG_OVERLAY_TRIPLETS='D:\vcpkg\overlay-ports\ffmpeg-vibeflow-audio\triplets'
  vcpkg install ffmpeg-vibeflow-audio:x64-windows-audio --overlay-ports=`$env:VCPKG_OVERLAY_PORTS --overlay-triplets=`$env:VCPKG_OVERLAY_TRIPLETS
"@

$ffmpegRoot = "D:\vcpkg\installed\x64-windows-audio"
$requiredLibs = @("avcodec.lib", "avformat.lib", "avfilter.lib", "swresample.lib", "avutil.lib")
$requiredDlls = @("avcodec-62.dll", "avformat-62.dll", "avfilter-11.dll", "swresample-6.dll", "avutil-60.dll")

if (-not (Test-Path $ffmpegRoot)) {
    Write-Host "[!] Custom FFmpeg root not found: $ffmpegRoot" -ForegroundColor Red
    Write-Host $installHint
    exit 1
}

Write-Host "[+] Found custom FFmpeg root: $ffmpegRoot" -ForegroundColor Green

$missingItems = @()
foreach ($item in $requiredLibs + $requiredDlls) {
    $path = if ($item.EndsWith(".lib")) {
        Join-Path "$ffmpegRoot\lib" $item
    } else {
        Join-Path "$ffmpegRoot\bin" $item
    }
    if (-not (Test-Path $path)) {
        $missingItems += $path
    } else {
        Write-Host "[+] Found: $path" -ForegroundColor Gray
    }
}

if ($missingItems.Count -gt 0) {
    Write-Host "`n[!] Missing required FFmpeg files:" -ForegroundColor Red
    $missingItems | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
    Write-Host "`n$installHint"
    exit 1
}

Write-Host "`n[SUCCESS] Custom FFmpeg build is present for Windows." -ForegroundColor Green

Write-Host "`n--- Check Complete ---"
