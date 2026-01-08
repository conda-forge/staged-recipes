setlocal EnableDelayedExpansion

::Configure
cmake %CMAKE_ARGS% ^
  -B build ^
  -S %SRC_DIR% ^
  -G Ninja ^
  -DCMAKE_INSTALL_INCLUDEDIR="include" ^
  -DCMAKE_INSTALL_LIBDIR="lib" ^
  -DTIGHT_INCLUSION_TOPLEVEL_PROJECT=OFF ^
  -DCMAKE_BUILD_TYPE:STRING=Release
if errorlevel 1 exit 1

:: Build.
cmake --build build --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --build build --parallel "%CPU_COUNT%" --target install
if errorlevel 1 exit 1