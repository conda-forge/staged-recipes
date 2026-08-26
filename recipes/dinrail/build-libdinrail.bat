@echo on
setlocal enabledelayedexpansion

cmake -S src\core -B build-libdinrail -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX% %CMAKE_ARGS%
if errorlevel 1 exit /b 1
cmake --build build-libdinrail
if errorlevel 1 exit /b 1
cmake --install build-libdinrail
if errorlevel 1 exit /b 1
