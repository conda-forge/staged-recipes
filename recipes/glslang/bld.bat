mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1
:REM hmaarrfk - 2023/06
:REM I'm really not sure why I am not able to utilize the shared libraries
:REM maybe they just never tested shared libraries upstream
cmake -GNinja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DBUILD_SHARED_LIBS=OFF ^
  ..
if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
