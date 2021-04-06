cd src
mkdir build && cd build

cmake -LAH -G "NMake Makefiles" ^
  -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  %SRC_DIR%/src
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

