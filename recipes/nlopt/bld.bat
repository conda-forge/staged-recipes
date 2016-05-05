@echo off

@rem See https://github.com/jyypma/nloptr/blob/master/INSTALL.windows
cp "%RECIPE_DIR%\CMakeLists.txt" .
if errorlevel 1 exit 1
cp "%RECIPE_DIR%\config.cmake.h.in" .
if errorlevel 1 exit 1

mkdir build
cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles"                               ^
    -DPYTHON_EXECUTABLE="%PYTHON%"                           ^
    -DPYTHON_INCLUDE_PATH="%PREFIX%\include"                 ^
    -DPYTHON_LIBRARY="%PREFIX%\libs\python%PY_VER:.=%.lib"   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ..

cmake --build . --config %CMAKE_CONFIG% --target ALL_BUILD
cmake --build . --config %CMAKE_CONFIG% --target INSTALL

if errorlevel 1 exit 1



