mkdir build
cd build

cmake -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

type CMakeCache.txt

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
