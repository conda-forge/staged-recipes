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
    QMAKE_LIBS=" " \
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
mv build/dsi_studio .
chmod 755 dsi_studio
mv src/dsi_studio.ico .
rm -rf src build
git clone https://github.com/frankyeh/DSI-Studio-atlas.git
mv DSI-Studio-atlas atlas
cp * $PREFIX/




