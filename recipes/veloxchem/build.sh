#!/usr/bin/env bash
set -ex

# clean up unwanted compiler flags
CXXFLAGS="${CXXFLAGS//-march=nocona}"
CXXFLAGS="${CXXFLAGS//-mtune=haswell}"
CXXFLAGS="${CXXFLAGS//-march=core2}"
CXXFLAGS="${CXXFLAGS//-mssse3}"

# configure!
cmake \
    -S"${SRC_DIR}" \
    -Bbuild \
    -GNinja \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_CXX_COMPILER:STRING="${CXX}" \
    -DENABLE_ARCH_FLAGS:BOOL=OFF \
    -DVLX_LA_VENDOR:STRING="Generic" \
    -DPython_EXECUTABLE:STRING="${PYTHON}" \
    -DPYMOD_INSTALL_FULLDIR:PATH="${SP_DIR#$PREFIX/}/veloxchem"

# build!
cmake --build build --parallel "${CPU_COUNT}" -- -v -d stats

# test!
# we only run unit tests here, integration tests are run later on
cd build
cmake --build . --parallel "${CPU_COUNT}" --target utests -- -v -d stats
ctest -L unit --output-on-failure --parallel "${CPU_COUNT}"

# install!
cd ..
cmake --build build --target install
