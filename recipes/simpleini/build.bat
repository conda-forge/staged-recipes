setlocal EnableDelayedExpansion

::Configure
cmake %CMAKE_ARGS% ^
  -B build ^
  -S %SRC_DIR% ^
  -G Ninja ^
  -DBUILD_TESTING=OFF ^
  -DCMAKE_BUILD_TYPE:STRING=Release
if errorlevel 1 exit 1

:: Build.
cmake --build build
if errorlevel 1 exit 1

:: Install.
cmake --install build
if errorlevel 1 exit 1