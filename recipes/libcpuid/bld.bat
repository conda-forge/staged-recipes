setlocal EnableDelayedExpansion

mkdir build
cd build

cmake -GNinja ^
      -D CMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -D CMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -D CMAKE_BUILD_TYPE:STRING=Release ^
      ..
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
