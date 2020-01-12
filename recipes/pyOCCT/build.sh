#!/usr/bin/env bash
mkdir build
cd build

if [[ ${HOST} =~ .*linux.* ]]; then
    CXXFLAGS="${CXXFLAGS} -fpermissive"
fi

cmake .. -G "Ninja" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DENABLE_SMESH=OFF \
    -DENABLE_NETGEN=OFF \
    -DENABLE_FORCE=OFF

ninja install

cd ..
${PYTHON} setup.py install
