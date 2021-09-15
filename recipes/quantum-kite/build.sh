#! /bin/sh

KITE_ROOT=`pwd`

# Install KITEx
sed -i.bak '/set(CMAKE_\w\+_COMPILER/d' ./CMakeLists.txt
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make -j${CPU_COUNT}
make install

# Install KITE-tools
cd $KITE_ROOT
cd tools
sed -i.bak '/set(CMAKE_\w\+_COMPILER/d' ./CMakeLists.txt
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make -j${CPU_COUNT}
make install

# Install kite.py package
cd $KITE_ROOT
PYTHON -m pip install . -vv
