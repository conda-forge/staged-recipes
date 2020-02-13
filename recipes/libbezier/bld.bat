:: NOTE: This assumes the following environment variables have been set.
::       - `%SRC_DIR%`
::       - `%LIBRARY_PREFIX%`
:: H/T: https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html

mkdir build
cd build

:: Configure.
cmake                                              ^
    -G "MinGW Makefiles"                           ^
    -DCMAKE_Fortran_COMPILER=gfortran              ^
    -DCMAKE_BUILD_TYPE=Release                     ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON               ^
    -S "%SRC_DIR%\src\fortran"                     ^
    -B .
IF ERRORLEVEL 1 EXIT /b 1

:: Build.
cmake                ^
    --build .        ^
    --config Release ^
    --target install
IF ERRORLEVEL 1 EXIT /b 1
