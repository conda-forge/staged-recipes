:: Configure
mkdir cmake-build && cd cmake-build
if errorlevel 1 exit 1

if "%ARCH%" == "64" (
  set "CMAKE_GENERATOR=Visual Studio %VS_MAJOR% %VS_YEAR% Win64"
) else (
  set "CMAKE_GENERATOR=Visual Studio %VS_MAJOR% %VS_YEAR%"
)

cmake -G "%CMAKE_GENERATOR%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_INSTALL_LIBDIR=%LIBRARY_LIB% ^
  -DCMAKE_C_FLAGS="-I%LIBRARY_INC%" ^
  -DBUILD_SHARED_LIBS=ON ^
  -DLZFSE_BUNDLE_MODE=OFF ^
  -Wno-dev ^
  %SRC_DIR%
if errorlevel 1 exit 1

:: Build
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: dll gets installed in bin.
move %LIBRARY_BIN%\lzfse.dll %LIBRARY_LIB%
