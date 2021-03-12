setlocal EnableDelayedExpansion

mkdir build
cd build

cmake -G "NMake Makefiles" ^
      -D CMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -D CMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -D CMAKE_BUILD_TYPE:STRING=Release ^
      ..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
