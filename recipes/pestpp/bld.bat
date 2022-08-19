mkdir build && cd build

cmake -G "Ninja" ^
         -D CMAKE_BUILD_TYPE=Release ^
         -D BUILD_SHARED_LIBS=OFF ^
         -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
         -D INSTALL_LOCAL=OFF ^
         %SRC_DIR%
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
