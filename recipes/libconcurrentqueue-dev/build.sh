#!/usr/bin/env bash
set -ex

# Find extracted source directory (GitHub archives vary)
src_dir=$(find . -maxdepth 1 -type d -name "concurrentqueue*" | sort | head -n 1)

if [ -z "$src_dir" ]; then
    echo "ERROR: Could not find extracted source dir!"
    find . -maxdepth 2 -type d
    exit 1
fi

echo "Using source dir: $src_dir"
cd "$src_dir"

# Install headers
mkdir -p "$PREFIX/include/concurrentqueue"
cp -v *.h "$PREFIX/include/concurrentqueue/"

if [ -d internal ]; then
    mkdir -p "$PREFIX/include/concurrentqueue/internal"
    cp -vr internal/* "$PREFIX/include/concurrentqueue/internal/"
fi
