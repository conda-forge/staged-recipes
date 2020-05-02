REM This is a fix for a CMake bug where it crashes because of the "/GL" flag
REM See: https://gitlab.kitware.com/cmake/cmake/issues/16282
set CXXFLAGS=%CXXFLAGS:-GL=%
set CFLAGS=%CFLAGS:-GL=%

set "CMAKE_GENERATOR=NMake Makefiles"

$PYTHON -m pip install . --no-deps --ignore-installed -vv
