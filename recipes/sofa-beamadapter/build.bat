setlocal EnableDelayedExpansion

::Configure
cmake %CMAKE_ARGS% ^
  -B build ^
  -S %SRC_DIR% ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DBEAMADAPTER_BUILD_TESTS:BOOL=OFF
if errorlevel 1 exit 1

:: Build.
cmake --build build --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --install build
if errorlevel 1 exit 1