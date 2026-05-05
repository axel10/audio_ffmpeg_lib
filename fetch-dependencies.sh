#!/bin/bash

# Exit on error
set -e

# Version definitions
FDK_AAC_VERSION="2.0.3"
LAME_VERSION="3.100"
OPUS_VERSION="1.5.2"
FFMPEG_VERSION="8.1"

# URLs
FDK_AAC_URL="https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-${FDK_AAC_VERSION}.tar.gz"
LAME_URL="https://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION}/lame-${LAME_VERSION}.tar.gz"
OPUS_URL="https://github.com/xiph/opus/releases/download/v${OPUS_VERSION}/opus-${OPUS_VERSION}.tar.gz"
FFMPEG_URL="https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz"

# Working directory (script location)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Working directory: $ROOT_DIR"

# Function to download and extract
download_and_extract() {
    local url=$1
    local filename=$2
    local folder_name=$3

    echo "--------------------------------------------------"
    echo "Processing $folder_name..."

    if [ -d "$folder_name" ]; then
        echo "Directory $folder_name already exists. Skipping download."
        return
    fi

    echo "Downloading from $url..."
    if command -v curl >/dev/null 2>&1; then
        curl -L "$url" -o "$filename"
    elif command -v wget >/dev/null 2>&1; then
        wget "$url" -O "$filename"
    else
        echo "Error: curl or wget not found. Please install one of them."
        exit 1
    fi

    echo "Extracting $filename..."
    tar -xzf "$filename"

    echo "Cleaning up $filename..."
    rm "$filename"

    echo "Successfully setup $folder_name"
}

# Execute downloads
download_and_extract "$FDK_AAC_URL" "fdk-aac-${FDK_AAC_VERSION}.tar.gz" "fdk-aac-${FDK_AAC_VERSION}"
download_and_extract "$LAME_URL" "lame-${LAME_VERSION}.tar.gz" "lame-${LAME_VERSION}"
download_and_extract "$OPUS_URL" "opus-${OPUS_VERSION}.tar.gz" "opus-${OPUS_VERSION}"
download_and_extract "$FFMPEG_URL" "ffmpeg-${FFMPEG_VERSION}.tar.gz" "ffmpeg-${FFMPEG_VERSION}"

echo "--------------------------------------------------"
echo "All dependencies have been downloaded and extracted to $ROOT_DIR"
