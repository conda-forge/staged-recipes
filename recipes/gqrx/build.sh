#!/usr/bin/env bash

set -ex

mkdir build
cd build

# enable components explicitly so we get build error when unsatisfied
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DBoost_NO_BOOST_CMAKE=ON
)

if [[ $target_platform == linux* ]] ; then
    cmake_config_args+=(
        -DLINUX_AUDIO_BACKEND="Pulseaudio"
    )
else
    cmake_config_args+=(
        -DOSX_AUDIO_BACKEND="Gr-audio"
    )
fi

cmake .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install
