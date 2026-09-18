@echo off

set "CXXFLAGS=%CXXFLAGS% /openmp:llvm"

cmake -S . -B build-conda -G Ninja ^
%CMAKE_ARGS% ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
-DCMAKE_INSTALL_BINDIR=Library\bin ^
-DCMAKE_INSTALL_LIBDIR=Library\lib ^
-DSPRING_ENABLE_COMPILER_CACHE=OFF
if errorlevel 1 exit /b 1

cmake --build build-conda --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1

cmake --install build-conda
if errorlevel 1 exit /b 1
