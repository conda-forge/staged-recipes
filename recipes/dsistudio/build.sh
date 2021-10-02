echo "COMPILE DSI STUDIO"
cd $SRC_DIR
mkdir -p build
cd build
if [[ "$OSTYPE" == "darwin"* ]]; then
    qmake ../src/dsi_studio.pro -spec macx-clang CONFIG+=qtquickcompiler
else
    qmake ../src/dsi_studio.pro
fi
make
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




