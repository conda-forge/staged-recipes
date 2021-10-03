REM curl -sSLO https://github.com/frankyeh/DSI-Studio/releases/download/2021.10/dsi_studio_win.zip
REM cscript //B j_unzip.vbs dsi_studio_win.zip
REM del dsi_studio_win.zip

   
@echo on
mkdir build
if errorlevel 1 exit /B 1
cd build
if errorlevel 1 exit /B 1

qmake QMAKE_CC=%CC% QMAKE_CXX=%CXX% QMAKE_LIBS="-lOpenGL32 -lGlu32 -lz" ../src/dsi_studio.pro
if errorlevel 1 exit /B 1

jom -j%CPU_COUNT%
if errorlevel 1 exit /B 1
jom check
if errorlevel 1 exit /B 1

cd ..


copy ./release/dsi_studio.exe $PREFIX/
cd ..

move atlas $PREFIX/
