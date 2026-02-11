@echo off
setlocal enabledelayedexpansion

mkdir build
if errorlevel 1 exit /b 1

cd build
if errorlevel 1 exit /b 1

cmake %CMAKE_ARGS% ^
    -GNinja ^
    -DWERROR=OFF ^
    %SRC_DIR%
if errorlevel 1 exit /b 1

ninja
if errorlevel 1 exit /b 1

ninja install
if errorlevel 1 exit /b 1

ninja test
if errorlevel 1 exit /b 1
