@echo off
setlocal enabledelayedexpansion

mkdir build_sundials
cd build_sundials
set KLU_INCLUDE_DIR=%PREFIX%\include\suitesparse
set KLU_LIBRARY_DIR=%PREFIX%\lib

set "CXXFLAGS=!CXXFLAGS! -I%KLU_INCLUDE_DIR%"
set "CFLAGS=!CFLAGS! -I%KLU_INCLUDE_DIR%"

set SUNDIALS_DIR=%SRC_DIR%\sundials
cmake -DENABLE_LAPACK=ON ^
      -DSUNDIALS_INDEX_SIZE=32 ^
      -DEXAMPLES_ENABLE:BOOL=OFF ^
      -DENABLE_KLU=ON ^
      -DENABLE_OPENMP=ON ^
      -DKLU_INCLUDE_DIR=%KLU_INCLUDE_DIR% ^
      -DKLU_LIBRARY_DIR=%KLU_LIBRARY_DIR% ^
      -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
      %SRC_DIR%\sundials
cmake --build . --target install --config Release

cd %SRC_DIR%

pip install -vv --no-deps --no-build-isolation .
