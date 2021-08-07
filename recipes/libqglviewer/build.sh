#!/bin/bash

[[ -d build ]] || mkdir build
cd build

if [[ ${HOST} =~ .*linux.* ]]; then
  # Missing g++ workaround.
  ln -s ${GXX} g++ || true
  chmod +x g++
  export PATH=${PWD}:${PATH}
fi

qmake \
    PREFIX=$PREFIX \
    NO_QT_VERSION_SUFFIX=1 \
    QMAKE_CC=${CC} \
    QMAKE_CXX=${CXX} \
    QMAKE_LINK=${CXX} \
    QMAKE_RANLIB=${RANLIB} \
    QMAKE_OBJDUMP=${OBJDUMP} \
    QMAKE_STRIP=${STRIP} \
    QMAKE_AR="${AR} cqs" \
    ../libQGLViewer-$PKG_VERSION.pro

make -j$CPU_COUNT
sed -i "s:(INSTALL_ROOT)/usr:(INSTALL_ROOT)$PREFIX:g" Makefile
make install
