if "%VS_MAJOR%" == "9" (
ECHO VS 2008
set CXXFLAGS=%CXXFLAGS:-D_hypot=hypot
) else (
REM This is a fix for a CMake bug where it crashes because of the "/GL" flag
REM See: https://gitlab.kitware.com/cmake/cmake/issues/16282
set CXXFLAGS=%CXXFLAGS:-GL=%
set CFLAGS=%CFLAGS:-GL=%
)

cmake -Bbuild -GNinja ^
    %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
    -DMDI_Fortran=ON ^
    -DMDI_Python=ON ^
    -DMDI_CXX=ON ^
    -DMDI_Python_PACKAGE=ON

cmake --build build
cmake --install build
