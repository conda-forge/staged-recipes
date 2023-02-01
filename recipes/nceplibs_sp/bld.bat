
mkdir build
cd build

:: Configure.
cmake -G "Ninja" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
ninja
if errorlevel 1 exit 1

:: Install
ninja install
if errorlevel 1 exit 1

:: Test.
ctest
if errorlevel 1 exit 1
