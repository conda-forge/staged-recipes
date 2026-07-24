@echo on
setlocal enabledelayedexpansion

cmake -S src\cli -B build-dinrail-tools -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX% %CMAKE_ARGS%
if errorlevel 1 exit /b 1
cmake --build build-dinrail-tools
if errorlevel 1 exit /b 1
cmake --install build-dinrail-tools
if errorlevel 1 exit /b 1
