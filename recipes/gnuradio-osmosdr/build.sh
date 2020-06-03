#!/bin/bash

set -ex

mkdir build
cd build

# enable components explicitly so we get build error when unsatisfied
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DLIB_SUFFIX=""
    -DPYTHON_EXECUTABLE=$PYTHON
    -DBoost_NO_BOOST_CMAKE=ON
    -DGR_PYTHON_DIR=$SP_DIR
    -DENABLE_AIRSPY=OFF
    -DENABLE_AIRSPYHF=OFF
    -DENABLE_BLADERF=OFF
    -DENABLE_DOXYGEN=OFF
    -DENABLE_FILE=ON
    -DENABLE_FREESRP=OFF
    -DENABLE_HACKRF=OFF
    -DENABLE_IQBALANCE=OFF
    -DENABLE_MIRI=OFF
    -DENABLE_NONFREE=OFF
    -DENABLE_OSMOSDR=OFF
    -DENABLE_PYTHON=ON
    -DENABLE_REDPITAYA=OFF
    -DENABLE_RFSPACE=OFF
    -DENABLE_RTL=OFF
    -DENABLE_RTL_TCP=OFF
    -DENABLE_SOAPY=ON
    -DENABLE_UHD=OFF
)

cmake .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install
