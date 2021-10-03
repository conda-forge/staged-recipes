#!/bin/bash
set -ex


echo "COMPILE DSI STUDIO"

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
    ../src/dsi_studio.pro

make -j$CPU_COUNT
cd ..


echo "DOWNLOAD ATLAS PACKAGES"

cd $SRC_DIR
chmod 755 build/dsi_studio
mv build/dsi_studio $PREFIX/
mv src/other/* $PREFIX/
mv src/dsi_studio.ico $PREFIX/
git clone https://github.com/frankyeh/DSI-Studio-atlas.git
mv DSI-Studio-atlas $PREFIX/atlas

rm -rf src build





