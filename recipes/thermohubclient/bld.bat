mkdir build
cd build

if "%VS_MAJOR%" == "9" (
ECHO VS 2008
set CXXFLAGS=%CXXFLAGS:-D_hypot=hypot
) else (
REM This is a fix for a CMake bug where it crashes because of the "/GL" flag
REM See: https://gitlab.kitware.com/cmake/cmake/issues/16282
set CXXFLAGS=%CXXFLAGS:-GL=%
set CFLAGS=%CFLAGS:-GL=%
)

cmake -G Ninja ^
    -DTHERMOFUN_PYTHON_INSTALL_PREFIX:PATH="%PREFIX%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..
ninja install
