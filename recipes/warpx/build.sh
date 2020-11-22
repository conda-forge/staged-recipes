#!/usr/bin/env bash

# find out toolchain C++ standard
CXX_STANDARD=14
if [[ ${CXXFLAGS} == *"-std=c++14"* ]]; then
    echo "14"
    CXX_STANDARD=14
elif [[ ${CXXFLAGS} == *"-std=c++17"* ]]; then
    echo "17"
    CXX_STANDARD=17
elif [[ ${CXXFLAGS} == *"-std="* ]]; then
    echo "ERROR: unknown C++ standard in toolchain!"
    echo ${CXXFLAGS}
    exit 1
fi

cmake \
    -S . -B build                         \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo     \
    -DCMAKE_VERBOSE_MAKEFILE=ON           \
    -DCMAKE_CXX_STANDARD=${CXX_STANDARD}  \
    -DCMAKE_INSTALL_LIBDIR=lib            \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}      \
    -DWarpX_amrex_branch=${PKG_VERSION}   \
    -DWarpX_openpmd_internal=OFF          \
    -DWarpX_picsar_branch=d60c72ff5aa15dbd7e225654964b6c4fb10d52e2 \
    -DWarpX_ASCENT=OFF  \
    -DWarpX_OPENPMD=ON  \
    -DWarpX_PSATD=OFF   \
    -DWarpX_QED=ON      \
    -DWarpX_DIMS=3      \
    ${SRC_DIR}

cmake --build build --parallel ${CPU_COUNT}

# future:
#CTEST_OUTPUT_ON_FAILURE=1 make ${VERBOSE_CM} test

# future:
#make install
mkdir -p ${PREFIX}/bin
cp build/bin/warpx.3d.MPI.OMP.DP.OPMD.QED ${PREFIX}/bin/

