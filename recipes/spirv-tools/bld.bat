mkdir build
if %ERRORLEVEL% neq 0 exit 1
cd build

cmake %CMAKE_ARGS% ^
  -GNinja ^
  -DSPIRV-Headers_SOURCE_DIR:PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  ..
if %ERRORLEVEL% neq 0 exit 1

ninja -j%CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1
ninja install
if %ERRORLEVEL% neq 0 exit 1
