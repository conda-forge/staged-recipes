@echo off
setlocal enabledelayedexpansion

:: Abort on error
set "ERROR_CODE=0"

:: Clean and create build directory
if exist build rmdir /s /q build
mkdir build
cd build

:: Configure with CMake
cmake ^
    %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBOX2D_BUILD_DOCS=OFF ^
    -DGLFW_BUILD_WAYLAND=OFF ^
    -GNinja ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DBOX2D_SAMPLES=OFF ^
    "%SRC_DIR%"

if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed
    exit /b %ERRORLEVEL%
)

:: Build
cmake --build . -j %CPU_COUNT%

if %ERRORLEVEL% neq 0 (
    echo Build failed
    exit /b %ERRORLEVEL%
)

:: Install
cmake --build . --target install

if %ERRORLEVEL% neq 0 (
    echo Installation failed
    exit /b %ERRORLEVEL%
)

cd .. 