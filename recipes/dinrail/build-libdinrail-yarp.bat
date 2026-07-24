@echo on
setlocal enabledelayedexpansion

cmake -S src\yarp -B build-libdinrail-yarp -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX% %CMAKE_ARGS%
if errorlevel 1 exit /b 1
cmake --build build-libdinrail-yarp
if errorlevel 1 exit /b 1
cmake --install build-libdinrail-yarp
if errorlevel 1 exit /b 1
