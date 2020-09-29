#!/usr/bin/env bash

mkdir build
cd build


# find out toolchain C++ standard
CXX_STANDARD=11
CXX_EXTENSIONS=OFF
if [[ ${CXXFLAGS} == *"-std=c++11"* ]]; then
    echo "11"
    CXX_STANDARD=11
elif [[ ${CXXFLAGS} == *"-std=c++14"* ]]; then
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
    -DCMAKE_BUILD_TYPE=Release                \
    -DBUILD_SHARED_LIBS=ON                    \
    -DCMAKE_CXX_STANDARD=${CXX_STANDARD}      \
    -DCMAKE_CXX_STANDARD_REQUIRED=ON          \
    -DCMAKE_CXX_EXTENSIONS=${CXX_EXTENSIONS}  \
    -DCMAKE_INSTALL_LIBDIR=lib        \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}  \
    ${SRC_DIR}

make ${VERBOSE_CM} -j${CPU_COUNT}
CTEST_OUTPUT_ON_FAILURE=1 make ${VERBOSE_CM} test
make install
