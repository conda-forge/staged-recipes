#!/usr/bin/env bash

set -xe

cmake -S . -B build  \
    -DADDITIONAL_CXX_FLAGS="-fPIC -I$PREFIX/include -L$PREFIX/lib" \
    -DADDITIONAL_C_FLAGS="-fPIC -I$PREFIX/include -L$PREFIX/lib" \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DSlicer_FORCED_WC_LAST_CHANGED_DATE=$(date +%Y-%m-%d) \
    -DSlicer_FORCED_REVISION="12345678" \
    -Wno-dev \
    -DSlicer_USE_SYSTEM_LZMA=1 \
    -DSlicer_USE_SYSTEM_zlib=1 \
    -DSlicer_USE_SYSTEM_bzip2=1 \
    -DSlicer_USE_SYSTEM_curl=1 \
    -DSlicer_USE_SYSTEM_LibFFI=1 \
    -DSlicer_USE_SYSTEM_DCMTK=1 \
    -DSlicer_USE_SYSTEM_OpenSSL=1 \
    -DSlicer_USE_SYSTEM_LibArchive=1 \
    -DSlicer_USE_SimpleITK_SHARED="ON" \
    -DSlicer_VTK_SMP_IMPLEMENTATION_TYPE="TBB" \
    -DBUILD_TESTING="OFF" \
    -DCMAKE_MESSAGE_LOG_LEVEL=ERROR

cmake --build build -j"${CPU_COUNT}"

# debug
ls -la ${PREFIX}/bin

#    -DSlicer_USE_SYSTEM_ITK=1 \
#    -DSlicer_USE_SYSTEM_VTK=1 \
