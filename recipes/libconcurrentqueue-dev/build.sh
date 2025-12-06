#!/usr/bin/env bash
set -ex

# Find the extracted source folder (GitHub archives vary!)
src_dir=$(find . -maxdepth 1 -type d -name "concurrentqueue*" | head -n 1)

echo "Using source dir: $src_dir"
cd "$src_dir"

# Install headers
mkdir -p "$PREFIX/include/concurrentqueue"
cp *.h "$PREFIX/include/concurrentqueue/"

# Install internal headers (directory may vary)
if [ -d internal ]; then
    mkdir -p "$PREFIX/include/concurrentqueue/internal"
    cp -r internal/* "$PREFIX/include/concurrentqueue/internal/"
fi
