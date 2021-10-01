#!/usr/bin/env bash

set -ex

cp $RECIPE_DIR/gr-iridium-LICENSE LICENSE

mkdir build
cd build

# needed for PRIu64 until glibc 2.18+ is used:
# https://sourceware.org/bugzilla/show_bug.cgi?id=15366
CXXFLAGS="$CXXFLAGS -D__STDC_FORMAT_MACROS"

# enable components explicitly so we get build error when unsatisfied
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DLIB_SUFFIX=""
    -DENABLE_DOXYGEN=OFF
)

cmake ${CMAKE_ARGS} -G "Ninja" .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install
