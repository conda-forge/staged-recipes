curl -sSLO https://github.com/frankyeh/DSI-Studio/releases/download/2021.10/dsi_studio_win.zip
cscript //B j_unzip.vbs dsi_studio_win.zip
del dsi_studio_win.zip


echo compile DSI Studio atlas
echo 
echo 
echo 

cd %SRC_DIR%
mkdir build
cd build
qmake ../src/dsi_studio.pro -spec win32-msvc "CONFIG+=qtquickcompiler"
jom.exe qmake_all
dir
move ./release/dsi_studio.exe $PREFIX/

echo copy DSI Studio atlas
echo 
echo 
echo 

git clone https://github.com/frankyeh/DSI-Studio-atlas.git
move DSI-Studio-atlas atlas
move atlas $PREFIX/
