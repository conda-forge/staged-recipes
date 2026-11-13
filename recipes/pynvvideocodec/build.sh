#!/bin/bash
set -euxo pipefail

export FFMPEG_DIR="${PREFIX}"
export DLPACK_SOURCE_DIR="${PREFIX}"
export USE_NVTX=0
export CMAKE_GENERATOR=Ninja
export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT}"
export CMAKE_ARGS="${CMAKE_ARGS:-} -DCMAKE_CUDA_ARCHITECTURES=${CUDAARCHS}"

# Ensure the build cannot accidentally use the precompiled FFmpeg distribution.
rm -rf external/ffmpeg

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
