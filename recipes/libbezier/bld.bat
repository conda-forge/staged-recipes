@echo on
:: EnableDelayedExpansion is needed for the `IF "%APPVEYOR%"` lines.
setlocal EnableDelayedExpansion

:: NOTE: This assumes the following environment variables have been set.
::       - `%SRC_DIR%`
::       - `%LIBRARY_PREFIX%`
:: H/T: https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html

mkdir build
cd build

IF "%APPVEYOR%" == "True" (
    IF "%ARCH%" == "32" (
        set PATH=%PATH%;C:\mingw-w64\i686-6.3.0-posix-dwarf-rt_v5-rev1\mingw32\bin
    ) ELSE (
        set PATH=%PATH%;C:\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin
    )
)

:: Workaround for `git bash`; CMake errors with
::   For MinGW make to work correctly sh.exe must NOT be in your path.
:: when using the "MinGW Makefiles" generator.
set PATH=%PATH:C:\Program Files (x86)\Git\bin;=%
set PATH=%PATH:C:\Program Files\Git\usr\bin;=%

:: Configure.
cmake                                              ^
    -G "MinGW Makefiles"                           ^
    -DCMAKE_Fortran_COMPILER=gfortran              ^
    -DCMAKE_BUILD_TYPE=Release                     ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON               ^
    -S "%SRC_DIR%\src\fortran"                     ^
    -B .
if errorlevel 1 exit /b 1

:: Build.
cmake                ^
    --build .        ^
    --config Release ^
    --target install
if errorlevel 1 exit /b 1
