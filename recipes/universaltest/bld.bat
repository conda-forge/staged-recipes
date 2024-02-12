setlocal EnableDelayedExpansion

mkdir build
cd build

cmake -G "NMake Makefiles" ^
      -DCMAKE_BUILD_TYPE=Debug ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      ..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit

nmake install
if errorlevel 1 exit
