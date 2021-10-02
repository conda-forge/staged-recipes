REM curl -sSLO https://github.com/frankyeh/DSI-Studio/releases/download/2021.10/dsi_studio_win.zip
REM cscript //B j_unzip.vbs dsi_studio_win.zip
REM del dsi_studio_win.zip


mkdir build
cd build
qmake ../src/dsi_studio.pro -spec win32-msvc "CONFIG+=qtquickcompiler"
jom.exe qmake_all
dir
move ./release/dsi_studio.exe $PREFIX/
cd ..

move atlas $PREFIX/
