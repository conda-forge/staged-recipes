#!/usr/bin/env bash

set -ex

if [[ $target_platform == osx* ]] ; then
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Workaround for no std::aligned_alloc with osx-64
# https://github.com/chriskohlhoff/asio/issues/1090
# Maybe remove when boost is updated to 1.80.0?
if [[ "${target_platform}" == "osx-64" ]]; then
  export CXXFLAGS="-DBOOST_ASIO_DISABLE_STD_ALIGNED_ALLOC ${CXXFLAGS}"
fi

mkdir forgebuild
cd forgebuild

cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DENABLE_AD9361=ON
    -DENABLE_ARRAY=OFF
    -DENABLE_BENCHMARKS=ON
    -DENABLE_CUDA=OFF
    -DENABLE_FPGA=OFF
    -DENABLE_FLEXIBAND=OFF
    -DENABLE_FMCOMMS2=ON
    -DENABLE_GPERFTOOLS=OFF
    -DENABLE_GPROF=OFF
    -DENABLE_GNSS_SIM_INSTALL=OFF
    -DENABLE_INSTALL_TESTS=OFF
    -DENABLE_LIMESDR=OFF
    -DENABLE_OPENCL=OFF
    -DENABLE_OSMOSDR=ON
    -DENABLE_PACKAGING=ON
    -DENABLE_PLUTOSDR=ON
    -DENABLE_RAW_UDP=ON
    -DENABLE_SYSTEM_TESTING=OFF
    -DENABLE_SYSTEM_TESTING_EXTRA=OFF
    -DENABLE_UHD=ON
    -DENABLE_UNIT_TESTING=OFF
    -DENABLE_UNIT_TESTING_EXTRA=OFF
    -DENABLE_UNIT_TESTING_MINIMAL=ON
    -DENABLE_ZMQ=ON
    -DGFLAGS_ROOT=$PREFIX
    -DGLOG_ROOT=$PREFIX
    -DGNSSSDR_INSTALL_DIR_DEF=\$CONDA_PREFIX
)

if [[ $target_platform == osx* ]] ; then
    cmake_config_args+=(
        -DBLAS_ROOT=$PREFIX/lib
    )
fi

cmake ${CMAKE_ARGS} -G "Ninja" .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install
