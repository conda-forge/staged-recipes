#!/usr/bin/env bash
mkdir build
cd build

if [ `uname` = "Darwin" ]; then
    sed -i '' 's/Xcode-9.app/Xcode.app/g' $PREFIX/lib/cmake/opencascade/OpenCASCADEVisualizationTargets.cmake
fi

cmake .. -G "Ninja" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DPTHREAD_INCLUDE_DIRS=$PREFIX \
    -DENABLE_SMESH=ON \
    -DENABLE_NETGEN=ON

ninja install

cd ..
python setup.py install
