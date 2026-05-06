@echo on
setlocal enabledelayedexpansion

cmake -S . -B build -G Ninja ^
    %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DOIDN_DEVICE_CPU=ON ^
    -DOIDN_FILTER_RT=ON ^
    -DOIDN_FILTER_RTLIGHTMAP=ON ^
    -DOIDN_APPS=ON ^
    -DOIDN_APPS_OPENIMAGEIO=OFF ^
    -DOIDN_INSTALL_DEPENDENCIES=OFF
if %ERRORLEVEL% neq 0 exit /b 1

cmake --build build --parallel %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit /b 1

cmake --install build
if %ERRORLEVEL% neq 0 exit /b 1
