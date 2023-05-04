#!/bin/sh

set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
#   -DSOFA_EXTERNAL_DIRECTORIES=$SOFA_SRC_DIR/plugins \
#   -DPLUGIN_SOFAPYTHON3=ON \
#   -DPLUGIN_BEAMADAPTER=ON \
#   -DPLUGIN_STLIB=ON \
#   -DPLUGIN_SOFTROBOTS=ON \
#   -DPLUGIN_MODELORDERREDUCTION=ON \

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# install 
cmake --build . --parallel ${CPU_COUNT} --verbose --target install

# test
ctest --parallel ${CPU_COUNT} --verbose