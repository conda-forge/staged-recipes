#!/bin/bash
set -euo pipefail

case "${target_platform}" in
  linux-64) rid="linux-x64" ;;
  linux-aarch64) rid="linux-arm64" ;;
  osx-64) rid="osx-x64" ;;
  osx-arm64) rid="osx-arm64" ;;
  *)
    echo "Unsupported target_platform: ${target_platform}" >&2
    exit 1
    ;;
esac

dotnet publish tools/cli/Cascode.Cli.csproj \
  -c Release \
  -r "${rid}" \
  -p:SelfContained=true \
  -p:PublishSingleFile=true \
  -p:PublishTrimmed=false \
  -o build/out

mkdir -p "${PREFIX}/bin"
if [[ -f build/out/Cascode.Cli ]]; then
  mv build/out/Cascode.Cli "${PREFIX}/bin/cascode"
elif [[ -f build/out/cascode ]]; then
  mv build/out/cascode "${PREFIX}/bin/cascode"
else
  echo "cascode binary not found in build/out" >&2
  exit 1
fi

chmod +x "${PREFIX}/bin/cascode"
