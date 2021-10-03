REM curl -sSLO https://github.com/frankyeh/DSI-Studio/releases/download/2021.10/dsi_studio_win.zip
REM cscript //B j_unzip.vbs dsi_studio_win.zip
REM del dsi_studio_win.zip

@echo on

move atlas %PREFIX%
move src/device.txt %PREFIX%
move src/color_map %PREFIX%
   
mkdir build
cd build

qmake QMAKE_CC=%CC% QMAKE_CXX=%CXX% QMAKE_LIBS="-lOpenGL32 -lGlu32 -lz" ../src/dsi_studio.pro
jom -j%CPU_COUNT%
jom check

copy release/dsi_studio.exe %PREFIX%



