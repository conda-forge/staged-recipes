REM Install library with ADIOS2Config.cmake files with cmake

:: remove -GL (whole program optimization) from CXXFLAGS
:: causes a fatal error when linking our .dll
echo "%CXXFLAGS%"
set CFLAGS=%CFLAGS: -GL=%
set CXXFLAGS=%CXXFLAGS: -GL=%
echo "%CXXFLAGS%"

mkdir build
cd build

set CURRENTDIR="%cd%"

cmake ^
    -G "NMake Makefiles"        ^
    -DCMAKE_BUILD_TYPE=Release  ^
    -DBUILD_SHARED_LIBS=ON      ^
    -DADIOS2_USE_MPI=OFF        ^
    -DADIOS2_BUILD_EXAMPLES=OFF ^
    -DADIOS2_BUILD_TESTING=OFF  ^
    -DADIOS2_USE_Python=ON      ^
    -DADIOS2_USE_Profiling=OFF  ^
    -DADIOS2_USE_Fortran=OFF    ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%  ^
    %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake test
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
