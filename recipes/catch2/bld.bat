setlocal EnableDelayedExpansion

:: Make a build folder and change to it
mkdir build
cd build

:: configure
cmake -LAH -G"Ninja" ^
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  ..
if errorlevel 1 exit 1

:: build and install
cmake --build . --target install
if errorlevel 1 exit 1

:: test
ctest -R
if errorlevel 1 exit 1
