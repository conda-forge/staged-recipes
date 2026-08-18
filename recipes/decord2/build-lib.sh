#!/bin/bash
set -euxo pipefail

# Force CMake to use the FFmpeg from the conda host prefix only. Without an
# explicit FFMPEG_DIR, decord2's FindFFmpeg falls back to scanning system
# paths (/usr/lib, /usr/local/lib, ...) and would pick up a system FFmpeg.
cmake -G Ninja -S . -B build \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DUSE_CUDA=0 \
  -DFFMPEG_DIR="${PREFIX}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
