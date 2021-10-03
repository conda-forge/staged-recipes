@echo on
move %SRC_DIR%\atlas %PREFIX%\atlas
move %SRC_DIR%\src\device.txt %PREFIX%
move %SRC_DIR%\src\color_map %PREFIX%\color_map
   
mkdir build
cd build

qmake QMAKE_CC=%CC% QMAKE_CXX=%CXX% QMAKE_LIBS="-lOpenGL32 -lGlu32 -lz" ../src/dsi_studio.pro
jom -j%CPU_COUNT%
jom check

copy %SRC_DIR%\build\release\dsi_studio.exe %PREFIX%



