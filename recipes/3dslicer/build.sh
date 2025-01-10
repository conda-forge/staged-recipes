#!/usr/bin/env bash

set -xe

mkdir -p build && pushd build

cmake .. -GNinja \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DSlicer_RELEASE_TYPE="Stable" \
    -DQt5_DIR=${PREFIX} \
    -DSlicer_USE_SYSTEM_python=1 \
    -DSlicer_USE_SYSTEM_python-numpy=1 \
    -DSlicer_USE_SYSTEM_python-scipy=1 \
    -DSlicer_USE_SYSTEM_python-pip=1 \
    -DSlicer_USE_SYSTEM_python-setuptools=1 \
    -DSlicer_USE_SYSTEM_python-ensurepip=1 \
    -DSlicer_USE_SYSTEM_python-wheel=1 \
    -DSlicer_USE_SYSTEM_LZMA=1 \
    -DSlicer_USE_SYSTEM_zlib=1 \
    -DSlicer_USE_SYSTEM_bzip2=1 \
    -DSlicer_USE_SYSTEM_curl=1 \
    -DSlicer_USE_SYSTEM_sqlite=1 \
    -DSlicer_USE_SYSTEM_RapidJSON=1 \
    -DSlicer_USE_SYSTEM_LibFFI=1 \
    -DSlicer_USE_SYSTEM_DCMTK=1 \
    -DSlicer_USE_SYSTEM_OpenSSL=1 \
    -DSlicer_USE_SYSTEM_LibArchive=1 \
    -DSlicer_USE_SimpleITK_SHARED="ON" \
    -DSlicer_VTK_SMP_IMPLEMENTATION_TYPE="TBB" \
    -DBUILD_TESTING="OFF" \
    -DCMAKE_MESSAGE_LOG_LEVEL=ERROR

cmake --build . --target Slicer -- -j"${CPU_COUNT}" > build.log

# debug
ls -la

pushd Slicer-build
cmake --build . --target install

# debug
ls -la ${PREFIX}/bin

#    -DSlicer_USE_SYSTEM_ITK=1 \
#    -DSlicer_USE_SYSTEM_VTK=1 \
#    -DSlicer_FORCED_WC_LAST_CHANGED_DATE="${last_revision_date}" \
#    -DSlicer_FORCED_REVISION="${last_revision_hash}"