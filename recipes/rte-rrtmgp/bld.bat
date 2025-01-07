@echo off
:: Stop on any error
setlocal ENABLEEXTENSIONS

set BUILD_DIR=build
set BUILD_TYPE=Debug

set "HOST=x86_64-w64-mingw32"
set "FC=%HOST%-gfortran.exe"
set FCFLAGS="-ffree-line-length-none -m64 -std=f2008 -march=native -fbounds-check -fmodule-private -fimplicit-none -finit-real=nan -fbacktrace"

set BUILD_TESTING=ON
set RTE_ENABLE_SP=OFF
set KERNEL_MODE=default
set FAILURE_THRESHOLD='7.e-4'

:: Ensure the directories exist
if not exist %BUILD_DIR% mkdir %BUILD_DIR%
if not exist %PREFIX%/lib mkdir %PREFIX%/lib
if not exist %PREFIX%/include mkdir %PREFIX%/include

:: Note: $CMAKE_ARGS is automatically provided by conda-forge. 
:: It sets default paths and platform-independent CMake arguments.
cmake -S . -B %BUILD_DIR% ^
      %CMAKE_ARGS% ^
      -DCMAKE_Fortran_COMPILER=%FC% ^
      -DCMAKE_Fortran_FLAGS=%FCFLAGS% ^
      -DRTE_ENABLE_SP=%RTE_ENABLE_SP% ^
      -DKERNEL_MODE=%KERNEL_MODE% ^
      -DBUILD_TESTING=%BUILD_TESTING% ^
      -DFAILURE_THRESHOLD=%FAILURE_THRESHOLD% ^
      -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
      -G Ninja

:: Compile
cmake --build %BUILD_DIR% --parallel

:: Install the necessery files into the package
cmake --install %BUILD_DIR% --prefix %PREFIX%

:: Run tests
ctest --output-on-failure --test-dir %BUILD_DIR% -V
