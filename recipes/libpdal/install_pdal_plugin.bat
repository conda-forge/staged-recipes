echo ON

pushd plugins\%PDAL_PLUGIN_NAME%

rmdir /s /q build
mkdir -p build
pushd build

cmake -G Ninja ^
  %CMAKE_ARGS% ^
  -DSTANDALONE=ON ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DPDAL_DIR:PATH=%LIBRARY_PREFIX%/lib/cmake/PDAL ^
  ..
if %ERRORLEVEL% neq 0 exit 1

ninja -j%CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

ninja install
if %ERRORLEVEL% neq 0 exit 1
