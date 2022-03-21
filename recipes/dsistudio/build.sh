#!/bin/bash
set -ex


echo "COMPILE DSI STUDIO"

[[ -d build ]] || mkdir build
cd build

qmake \
    PREFIX=$PREFIX \
    NO_QT_VERSION_SUFFIX=1 \
    QMAKE_CC=${CC} \
    QMAKE_CXX=${CXX} \
    QMAKE_LINK=${CXX} \
    QMAKE_INCDIR=${BUILD_PREFIX}/include \
    QMAKE_RANLIB=${RANLIB} \
    QMAKE_OBJDUMP=${OBJDUMP} \
    QMAKE_STRIP=${STRIP} \
    QMAKE_AR="${AR} cqs" \
    ../src/dsi_studio.pro

make -j$CPU_COUNT
cd ..


echo "DOWNLOAD ATLAS PACKAGES"

if [[ "$OSTYPE" == "darwin"* ]]; then
   cd $SRC_DIR
   mv src/other/* build/dsi_studio.app/Contents/MacOS/
   mv src/dsi_studio.icns build/dsi_studio.app/Contents/Resources/
   mv atlas build/dsi_studio.app/Contents/MacOS/atlas
   mv build/dsi_studio.app $PREFIX/
   exit
fi

cd $SRC_DIR
chmod 755 build/dsi_studio
mv build/dsi_studio $PREFIX/
mv src/other/* $PREFIX/
mv src/dsi_studio.ico $PREFIX/
mv atlas $PREFIX/atlas

rm -rf src build





