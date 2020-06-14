setlocal EnableDelayedExpansion
echo on

mkdir build_conda
if errorlevel 1 exit 1

cd build_conda
if errorlevel 1 exit 1

cmake -LAH -G "Ninja"                           ^
   -DCMAKE_BUILD_TYPE:STRING=Release            ^
   -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"    ^
   ..
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
