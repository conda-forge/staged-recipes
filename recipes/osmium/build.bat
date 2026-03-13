@echo off
REM Remove contrib folder as it contains libosmium and protozero
REM which will be provided as conda dependencies
if exist contrib (
    rmdir /s /q contrib
)

REM Set prefix for libosmium so CMake can find it
set "LIBOSMIUM_PREFIX=%PREFIX%"
set "PROTOZERO_PREFIX=%PREFIX%"

REM Tell CMake to search conda environment first before system paths
set "CMAKE_PREFIX_PATH=%PREFIX%"

REM Build and install the package
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
