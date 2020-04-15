setlocal EnableDelayedExpansion

mkdir build
cd build

:: Configure using the CMakeFiles
cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_C_COMPILER:PATH="%LIBRARY_PREFIX%"/mingw-w64/bin/gcc.exe ^
    -DCMAKE_CXX_COMPILER:PATH="%LIBRARY_PREFIX%"/mingw-w64/bin/g++.exe ^
    ..

if errorlevel 1 exit 1

:: Build!
nmake
if errorlevel 1 exit 1

:: Install!
nmake install
if errorlevel 1 exit 1

REM These are cmake flags that I tried using to set the math libraries
REM when I was using MKL. In the end, using NetLib and not specifying that
REM library location worked
REM -DBLAS_LIBRARIES="%LIBRARY_PREFIX%"\bin ^
REM -DLAPACK_LIBRARIES="%LIBRARY_PREFIX%"\bin ^
