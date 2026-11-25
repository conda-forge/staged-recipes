#!/usr/bin/env bash
set -euxo pipefail

# path_home (the espeak-ng-data path) defaults to 160 bytes, which is shorter than
# conda's padded build prefix; all derived path buffers scale with it.
path_home_flag="-DN_PATH_HOME=1024"
export CFLAGS="${CFLAGS:-} ${path_home_flag}"

common_args=(
  -G Ninja
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
  -DBUILD_TESTING=OFF
  -DUSE_LIBPCAUDIO=OFF
  -DUSE_MBROLA=OFF
  -DESPEAK_BUILD_MANPAGES=OFF
  # use the vendored sonic source instead of a git clone at configure time
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON
  "-DFETCHCONTENT_SOURCE_DIR_SONIC-GIT=${SRC_DIR}/sonic"
)

extra_args=()
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
  # The data step runs espeak-ng itself, so build a static one for the build machine first.
  (
    unset CXXFLAGS CPPFLAGS LDFLAGS CMAKE_ARGS
    export CFLAGS="${path_home_flag}"
    native_args=()
    if [[ "${build_platform}" == osx-* ]]; then
      native_args+=("-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}")
    fi
    cmake -S . -B build-native "${common_args[@]}" ${native_args[@]+"${native_args[@]}"} \
      -DCMAKE_C_COMPILER="${CC_FOR_BUILD}" \
      -DCMAKE_CXX_COMPILER="${CXX_FOR_BUILD}" \
      -DBUILD_SHARED_LIBS=OFF
    cmake --build build-native --target espeak-ng-bin
  )
  extra_args+=("-DESPEAK_NG_NATIVE_EXECUTABLE=${SRC_DIR}/build-native/src/espeak-ng")
fi

cmake -S . -B build ${CMAKE_ARGS} "${common_args[@]}" ${extra_args[@]+"${extra_args[@]}"} \
  -DBUILD_SHARED_LIBS=ON
cmake --build build
cmake --install build
