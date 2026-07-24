@echo on
setlocal enabledelayedexpansion

cmake -S src\devices -B build-dinrail-devices -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX% %CMAKE_ARGS%
if errorlevel 1 exit /b 1
cmake --build build-dinrail-devices
if errorlevel 1 exit /b 1
cmake --install build-dinrail-devices
if errorlevel 1 exit /b 1
