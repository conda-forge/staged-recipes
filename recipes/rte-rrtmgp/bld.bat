@echo off
:: Stop on any error
setlocal ENABLEEXTENSIONS

set BUILD_DIR=build
set BUILD_TYPE=RelWithDebInfo

set "HOST=x86_64-w64-mingw32"
set "FC=%HOST%-gfortran.exe"

set BUILD_TESTING=ON
set BUILD_SHARED_LIBS=ON
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
      -DRTE_ENABLE_SP=%RTE_ENABLE_SP% ^
      -DKERNEL_MODE=%KERNEL_MODE% ^
      -DBUILD_TESTING=%BUILD_TESTING% ^
      -DFAILURE_THRESHOLD=%FAILURE_THRESHOLD% ^
      -DBUILD_SHARED_LIBS=%BUILD_SHARED_LIBS% ^
      -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
      -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
      -G Ninja
if errorlevel 1 exit 1

:: Compile
cmake --build %BUILD_DIR% --target install -- -v
if errorlevel 1 exit 1

:: Run tests
ctest --output-on-failure --test-dir %BUILD_DIR% -V
if errorlevel 1 exit 1