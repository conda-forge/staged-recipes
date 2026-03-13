@echo off
setlocal enabledelayedexpansion

:: ---- Step 1: clone and bootstrap vcpkg (for casadi only) ----
git clone https://github.com/microsoft/vcpkg --branch 2025.01.13
SET VCPKG_ROOT=%CD%\vcpkg\

CALL %VCPKG_ROOT%\bootstrap-vcpkg.bat
if %errorlevel% NEQ 0 exit /b %errorlevel%

:: ---- Step 2: build SUNDIALS 7.3.0 from the source tarball ---
SET KLU_INCLUDE_DIR=%LIBRARY_INC%
SET KLU_LIBRARY_DIR=%LIBRARY_LIB%
SET SUNDIALS_INSTALL_DIR=%LIBRARY_PREFIX%

md build_sundials
cd build_sundials

cmake -G "Ninja" ^
      -DENABLE_LAPACK=ON ^
      -DSUNDIALS_INDEX_SIZE=32 ^
      -DEXAMPLES_ENABLE:BOOL=OFF ^
      -DENABLE_KLU=ON ^
      -DENABLE_OPENMP=OFF ^
      -DKLU_INCLUDE_DIR=%KLU_INCLUDE_DIR%\suitesparse ^
      -DKLU_LIBRARY_DIR=%KLU_LIBRARY_DIR% ^
      -DCMAKE_INSTALL_PREFIX=%SUNDIALS_INSTALL_DIR% ^
      -DCMAKE_BUILD_TYPE=Release ^
      %SRC_DIR%\sundials
if %errorlevel% NEQ 0 exit /b %errorlevel%

ninja install
if %errorlevel% NEQ 0 exit /b %errorlevel%

cd %SRC_DIR%

:: ---- Step 3: build pybammsolvers extension using vcpkg for casadi ----
SET PYBAMMSOLVERS_USE_VCPKG=ON
SET VCPKG_ROOT_DIR=%VCPKG_ROOT%
SET VCPKG_DEFAULT_TRIPLET=x64-windows-static-md
SET VCPKG_FEATURE_FLAGS=manifests,registries
SET CMAKE_GENERATOR=Visual Studio 17 2022
SET CMAKE_GENERATOR_PLATFORM=x64

:: Tell FindSuiteSparse.cmake (module mode) where conda installed suitesparse/libklu
SET SuiteSparse_ROOT=%LIBRARY_PREFIX%

python -m pip install -vv --no-deps --no-build-isolation .
if %errorlevel% NEQ 0 exit /b %errorlevel%
