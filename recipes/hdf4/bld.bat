mkdir build
cd build

REM Configure step
set CMAKE_CUSTOM=
cmake -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE=Release -DHDF4_BUILD_HL_LIB=ON -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% %CMAKE_CUSTOM% %SRC_DIR%
if errorlevel 1 exit 1

REM Build step
devenv HDF4.sln /Build "%RELEASE_TARGET%"
if errorlevel 1 exit 1

REM Install step
devenv HDF4.sln /Build "%RELEASE_TARGET%" /Project INSTALL
if errorlevel 1 exit 1
