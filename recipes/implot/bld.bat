@echo on

cmake %SRC_DIR% ^
  %CMAKE_ARGS% ^
  -B build ^
  -DBUILD_SHARED_LIBS=ON
if errorlevel 1 exit 1

:: Build.
cmake --build build --parallel --config Release
if errorlevel 1 exit 1

:: Install.
cmake --install build --config Release
if errorlevel 1 exit 1
