@echo off
setlocal enabledelayedexpansion

git clone https://github.com/microsoft/vcpkg --branch 2025.01.13
SET VCPKG_ROOT=%CD%\vcpkg\

CALL %VCPKG_ROOT%\bootstrap-vcpkg.bat
if %errorlevel% NEQ 0 exit /b %errorlevel%

SET PYBAMMSOLVERS_USE_VCPKG=ON
SET VCPKG_ROOT_DIR=%VCPKG_ROOT%
SET VCPKG_DEFAULT_TRIPLET=x64-windows-static-md
SET VCPKG_FEATURE_FLAGS=manifests,registries
SET CMAKE_GENERATOR="Visual Studio 17 2022"
SET CMAKE_GENERATOR_PLATFORM=x64

python -m pip install -vv --no-deps --no-build-isolation .
