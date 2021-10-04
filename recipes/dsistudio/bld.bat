@echo on
rd /s /q %SRC_DIR%\atlas\.git
move %SRC_DIR%\atlas %PREFIX%\atlas
move %SRC_DIR%\src\others\device.txt %PREFIX%
move %SRC_DIR%\src\others\color_map %PREFIX%\color_map
   
mkdir build
cd build

qmake QMAKE_CC=%CC% QMAKE_CXX=%CXX% QMAKE_LIBS="-lOpenGL32 -lGlu32 -lz" ../src/dsi_studio.pro
jom -j%CPU_COUNT%
jom check
jom install
cd..

copy %SRC_DIR%\build\release\dsi_studio.exe %PREFIX%
windeployqt %PREFIX%\dsi_studio.exe



