setlocal EnableExtensions EnableDelayedExpansion
@echo on

cmake -B _build -S . -G Ninja -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release %CMAKE_ARGS%
if errorlevel 1 exit 1

cmake --build _build
if errorlevel 1 exit 1

cmake --install _build
if errorlevel 1 exit 1
