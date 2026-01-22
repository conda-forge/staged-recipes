setlocal EnableExtensions EnableDelayedExpansion
@echo on

cmake -B _build -S . -G Ninja -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1

cmake --build _build
if errorlevel 1 exit 1

cmake --install _build
if errorlevel 1 exit 1
