cd cpp
mkdir build\release
cd build\release

:: NOTE: we disable building ingester on Windows since the
:: build is failing for some unknown reason, and it's likely
:: not to be desired (you need Linux to run Redis anyways).
cmake -G"NMake Makefiles" ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_LIBDIR:STRING=lib ^
  -DRIVER_BUILD_INGESTER=OFF ^
  -DRIVER_BUILD_TESTS=OFF ^
  -DRIVER_INSTALL=ON ^
  %CMAKE_ARGS% ^
  ..\..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

