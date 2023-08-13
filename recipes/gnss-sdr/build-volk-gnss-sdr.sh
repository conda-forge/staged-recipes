#!/usr/bin/env bash

set -ex

if [[ $target_platform == osx* ]] ; then
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cd src/algorithms/libs/volk_gnsssdr_module/volk_gnsssdr
mkdir forgebuild
cd forgebuild

cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DVOLK_PYTHON_DIR="$SRC_DIR/_noinstall/site-packages"
    -DVOLK_CPU_FEATURES=OFF
    -DORCC_EXECUTABLE="$BUILD_PREFIX/bin/orcc"
    -DENABLE_ORC=ON
    -DENABLE_PROFILING=OFF
    -DENABLE_STRIP=ON
    -DENABLE_TESTING=ON
)

cmake ${CMAKE_ARGS} -G "Ninja" .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
    ctest --build-config Release --output-on-failure --timeout 120 -j${CPU_COUNT}
fi
cmake --build . --config Release --target install

# don't include volk_gnsssdr_modtool, we're skipping the modtool python lib
cmake -E rm "$PREFIX/bin/volk_gnsssdr_modtool"
