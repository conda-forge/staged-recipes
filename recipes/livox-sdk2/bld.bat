rmdir /S /Q build

cmake ^
    -B build ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1

:: Build.
cmake --build build --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build build --config Release --target install
if errorlevel 1 exit 1
