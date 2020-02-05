:: NOTE: This assumes the following environment variables have been set.
::       - `%SRC_DIR%`
::       - `%LIBRARY_PREFIX%`
:: H/T: https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html

mkdir build
cd build

:: Workaround (somewhat AppVeyor specific) for CMake not wanting sh.exe on
:: `%PATH%` for MinGW
set PATH=%PATH:C:\Program Files (x86)\Git\bin;=%
set PATH=%PATH:C:\Program Files\Git\usr\bin;=%

:: Configure.
cmake                                              ^
    -G "MinGW Makefiles"                           ^
    -DCMAKE_Fortran_COMPILER=gfortran              ^
    -DCMAKE_BUILD_TYPE=Release                     ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON               ^
    -DTARGET_NATIVE_ARCH:BOOL=OFF                  ^
    -S "%SRC_DIR%\src\fortran"                     ^
    -B .
if errorlevel 1 exit /b 1

:: Build.
cmake                ^
    --build .        ^
    --config Release ^
    --target install
if errorlevel 1 exit /b 1
