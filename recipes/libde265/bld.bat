mkdir build
cd build

cmake -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_SYSTEM_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE="Release" ^
  ..
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
