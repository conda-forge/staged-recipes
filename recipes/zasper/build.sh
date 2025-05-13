#!/bin/bash
set -ex

cd "$SRC_DIR"

UNAME=$(uname)
ARCH=$(uname -m)

if [[ "$UNAME" == "Linux" ]]; then
  case "$ARCH" in
    x86_64) ARCHIVE="zasper-webapp-linux-amd64.tar.gz" ;;
    aarch64) ARCHIVE="zasper-webapp-linux-arm64.tar.gz" ;;
    i386|i686) ARCHIVE="zasper-webapp-linux-386.tar.gz" ;;
    *) echo "Unsupported Linux arch: $ARCH"; exit 1 ;;
  esac
  tar -xzf "$ARCHIVE"
  BINARY="zasper"

elif [[ "$UNAME" == "Darwin" ]]; then
  case "$ARCH" in
    x86_64) ARCHIVE="zasper-webapp-darwin-amd64.tar.gz" ;;
    arm64) ARCHIVE="zasper-webapp-darwin-arm64.tar.gz" ;;
    *) echo "Unsupported macOS arch: $ARCH"; exit 1 ;;
  esac
  tar -xzf "$ARCHIVE"
  BINARY="zasper"

elif [[ "$UNAME" == "MINGW"* || "$UNAME" == "MSYS"* ]]; then
  case "$PROCESSOR_ARCHITECTURE" in
    AMD64) ARCHIVE="zasper-webapp-windows-amd64.zip" ;;
    x86) ARCHIVE="zasper-webapp-windows-386.zip" ;;
    ARM64) ARCHIVE="zasper-webapp-windows-arm64.zip" ;;
    *) echo "Unsupported Windows arch: $PROCESSOR_ARCHITECTURE"; exit 1 ;;
  esac
  unzip "$ARCHIVE"
  BINARY="zasper.exe"

else
  echo "Unsupported OS: $UNAME"
  exit 1
fi

chmod +x "$SRC_DIR/$BINARY"
mkdir -p "${PREFIX}/bin"
cp "$SRC_DIR/$BINARY" "${PREFIX}/bin/zasper"
