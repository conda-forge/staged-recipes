:: NOTE: This assumes the following environment variables have been set.
::       - `%SUBDIR%`
::       - `%c_compiler%`
::       - `%LIBRARY_PREFIX%`
:: H/T: https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html

mkdir build
cd build

:: Configure.
cmake                                              ^
    -G "MinGW Makefiles"                           ^
    -DCMAKE_BUILD_TYPE=Release                     ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON               ^
    -DTARGET_NATIVE_ARCH:BOOL=OFF                  ^
    -S %SRC_DIR%                                   ^
    -B .
if errorlevel 1 exit /b 1

:: Build.
cmake                ^
    --build .        ^
    --config Release ^
    --target install
if errorlevel 1 exit /b 1
