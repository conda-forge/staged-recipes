@echo on
setlocal enabledelayedexpansion

cmake -S src\yarp-tools -B build-dinrail-yarp-tools -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX% %CMAKE_ARGS%
if errorlevel 1 exit /b 1
cmake --build build-dinrail-yarp-tools
if errorlevel 1 exit /b 1
cmake --install build-dinrail-yarp-tools
if errorlevel 1 exit /b 1
