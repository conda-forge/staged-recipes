@echo on
setlocal enabledelayedexpansion

cmake -S . -B build-docs -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX% %CMAKE_ARGS% -DTINYOPT_BUILD_TESTS=OFF -DTINYOPT_BUILD_DOCS=ON
if errorlevel 1 exit /b 1
cmake --build build-docs --target docs
if errorlevel 1 exit /b 1
cmake --build build-docs
if errorlevel 1 exit /b 1
cmake --install build-docs
if errorlevel 1 exit /b 1