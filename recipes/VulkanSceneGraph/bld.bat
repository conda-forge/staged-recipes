@echo on

cmake %SRC_DIR% ^
  %CMAKE_ARGS% ^
  -B build ^
  -DBUILD_SHARED_LIBS=ON

cmake --build build --parallel --config Release
if errorlevel 1 exit 1

cmake --install build --config Release
if errorlevel 1 exit 1
