@echo on
setlocal enabledelayedexpansion

cmake -S . -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DLLHTTP_BUILD_SHARED_LIBS=ON ^
  -DLLHTTP_BUILD_STATIC_LIBS=OFF
if errorlevel 1 exit /b 1

cmake --build build --config Release
if errorlevel 1 exit /b 1

cmake --install build --config Release
if errorlevel 1 exit /b 1
