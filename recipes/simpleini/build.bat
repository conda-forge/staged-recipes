setlocal EnableDelayedExpansion

mkdir build
cd build

::Configure
cmake %CMAKE_ARGS% ^
  -B . ^
  -S %SRC_DIR% ^
  -G Ninja ^
  -DBUILD_TESTING=OFF ^
  -DCMAKE_BUILD_TYPE:STRING=Release
if errorlevel 1 exit 1

:: Build.
cmake --build .
if errorlevel 1 exit 1

:: Install.
cmake --build . --target install
if errorlevel 1 exit 1