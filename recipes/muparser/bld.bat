rem  @echo off

@rem See https://bitbucket.org/dbarbier/ot-superbuild
cp "%RECIPE_DIR%\CMakeLists.txt" .
if errorlevel 1 exit 1

mkdir build
cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ..

cmake --build . --config %CMAKE_CONFIG% --target ALL_BUILD
cmake --build . --config %CMAKE_CONFIG% --target INSTALL

if errorlevel 1 exit 1

start example1.exe

if errorlevel 1 exit 1
