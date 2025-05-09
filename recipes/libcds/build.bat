mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DCMAKE_BUILD_TYPE=Release %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

ctest
if errorlevel 1 exit 1
