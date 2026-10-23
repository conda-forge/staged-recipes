@echo on
setlocal enabledelayedexpansion

cmake -S . -B build-tinyopt -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX% %CMAKE_ARGS% -DTINYOPT_BUILD_TESTS=OFF -DTINYOPT_BUILD_DOCS=OFF
if errorlevel 1 exit /b 1
cmake --build build-tinyopt
if errorlevel 1 exit /b 1
cmake --install build-tinyopt
if errorlevel 1 exit /b 1