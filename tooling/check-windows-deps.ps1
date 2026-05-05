# Check Windows FFmpeg Build Dependencies (vcpkg)
$ErrorActionPreference = "Stop"

Write-Host "--- Checking Windows Build Environment ---" -ForegroundColor Cyan

# 1. Check for vcpkg
$vcpkgExe = Get-Command vcpkg -ErrorAction SilentlyContinue
if ($null -eq $vcpkgExe) {
    # Try common locations
    $commonPaths = @("D:\vcpkg\vcpkg.exe", "C:\vcpkg\vcpkg.exe", "$env:USERPROFILE\vcpkg\vcpkg.exe")
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $vcpkgPath = $path
            break
        }
    }
} else {
    $vcpkgPath = $vcpkgExe.Source
}

if ($null -eq $vcpkgPath) {
    Write-Host "[!] vcpkg not found in PATH or common locations." -ForegroundColor Red
    Write-Host "    Please install vcpkg and add it to your PATH, or set it up in D:\vcpkg."
    exit 1
} else {
    Write-Host "[+] Found vcpkg at: $vcpkgPath" -ForegroundColor Green
}

# 2. Check for FFmpeg and features
Write-Host "`n--- Checking FFmpeg Features in vcpkg ---" -ForegroundColor Cyan

$requiredFeatures = @("fdk-aac", "opus", "mp3lame", "gpl", "nonfree", "avcodec", "avformat", "avfilter", "swresample")
$missingFeatures = @()

# Get installed ffmpeg info
try {
    # We check x64-windows triplet as it's default for Flutter
    $ffmpegInfo = & $vcpkgPath list ffmpeg:x64-windows
    if ($null -eq $ffmpegInfo -or $ffmpegInfo -match "No packages matched") {
        Write-Host "[!] FFmpeg (x64-windows) is NOT installed in vcpkg." -ForegroundColor Red
        Write-Host "    Run: vcpkg install ffmpeg[$( $requiredFeatures -join "," )]:x64-windows"
        exit 1
    }

    Write-Host "[+] FFmpeg is installed. Checking features..." -ForegroundColor Green

    foreach ($feature in $requiredFeatures) {
        # vcpkg list output format for features is usually: ffmpeg[feature]:triplet
        $match = & $vcpkgPath list "ffmpeg[$feature]:x64-windows"
        if ($null -eq $match -or $match -match "No packages matched") {
            $missingFeatures += $feature
            Write-Host "[-] Missing feature: $feature" -ForegroundColor Yellow
        } else {
            Write-Host "[+] Found feature: $feature" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "[!] Error running vcpkg list." -ForegroundColor Red
    exit 1
}

if ($missingFeatures.Count -eq 0) {
    Write-Host "`n[SUCCESS] All required FFmpeg features are installed for Windows." -ForegroundColor Green
} else {
    Write-Host "`n[!] Some features are missing." -ForegroundColor Yellow
    $installCmd = "vcpkg install ffmpeg[$( $requiredFeatures -join "," )]:x64-windows"
    Write-Host "To fix, run the following command:"
    Write-Host "    $installCmd" -ForegroundColor White -BackgroundColor DarkBlue
}

Write-Host "`n--- Check Complete ---"
