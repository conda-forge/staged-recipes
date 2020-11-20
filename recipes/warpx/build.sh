#!/usr/bin/env bash

mkdir build
cd build


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
    -DCMAKE_BUILD_TYPE=RelWithDebInfo     \
    -DCMAKE_CXX_STANDARD=${CXX_STANDARD}  \
    -DCMAKE_INSTALL_LIBDIR=lib            \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}      \
    -DWarpX_amrex_branch=${PKG_VERSION}   \
    -DWarpX_openpmd_internal=OFF          \
    -DWarpX_picsar_branch=d60c72ff5aa15dbd7e225654964b6c4fb10d52e2 \
    -DWarpX_ASCENT=OFF  \
    -DWarpX_OPENPMD=OFF \
    -DWarpX_PSATD=OFF   \
    -DWarpX_QED=ON      \
    -DWarpX_DIMS=3      \
    ${SRC_DIR}

make ${VERBOSE_CM} -j${CPU_COUNT}

# future:
#CTEST_OUTPUT_ON_FAILURE=1 make ${VERBOSE_CM} test

# future:
#make install
mkdir -p ${PREFIX}/bin
cp bin/warpx.3d.MPI.OMP.DP.QED ${PREFIX}/bin/

