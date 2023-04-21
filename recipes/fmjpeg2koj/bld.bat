mkdir build
cd build

REM See notes in build.sh
cmake ^
    -G Ninja ^
    -D CMAKE_BUILD_TYPE:STRING=Release ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    ..
if errorlevel 1 exit 1

cmake --build . --config Release --target install --parallel
if errorlevel 1 exit 1