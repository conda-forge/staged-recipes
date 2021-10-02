
if [[ "$OSTYPE" == "darwin"* ]]; then
  curl -sSLO 'https://github.com/frankyeh/DSI-Studio/releases/download/2021.10/dsi_studio_mac.dmg'
  hdiutil mount dsi_studio_64_mac.dmg
  cp /Volumes/dsi_studio/dsi_studio.app $PREFIX
  exit
fi

conda install -y -c conda-forge qt=5.12 gcc=9 gxx=9 boost libglu mesa-libgl-devel-cos7-x86_64
cp $BUILD_PREFIX/lib/libQt* $PREFIX/lib 
echo "COMPILE DSI STUDIO"
cd $SRC_DIR
mkdir -p build
cd build
qmake ../src/dsi_studio.pro
make
cd ..

echo "DOWNLOAD ATLAS PACKAGES"

curl -sSLO 'https://github.com/frankyeh/DSI-Studio/releases/download/2021.10/dsi_studio_win.zip'
unzip dsi_studio_win.zip
rm dsi_studio_win.zip
cd dsi_studio_64
rm *.dll
rm *.exe
rm -rf iconengines
rm -rf imageformats
rm -rf platforms
rm -rf styles
mv ../build/dsi_studio .
mv ../src/dsi_studio.ico .

cd ..
rm -rf src build

mv dsi_studio_64/* $PREFIX/




