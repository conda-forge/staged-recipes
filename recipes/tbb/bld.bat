rem  @echo off

@rem See https://github.com/wjakob/tbb
cp "%RECIPE_DIR%\CMakeLists.txt" .
if errorlevel 1 exit 1
cp "%RECIPE_DIR%\version_string.ver.in" .
if errorlevel 1 exit 1

mkdir build
cd build

set CMAKE_CONFIG="Release"


cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ..

cmake --build . --config %CMAKE_CONFIG% --target ALL_BUILD
cmake --build . --config %CMAKE_CONFIG% --target INSTALL

if errorlevel 1 exit 1
