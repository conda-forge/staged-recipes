@echo on

mkdir build
cd build
cmake %CMAKE_ARGS% ^
  -G "Ninja" ^
  -D WIL_BUILD_PACKAGING=OFF ^
  -D WIL_BUILD_TESTS=OFF ^
  ..
if %ERRORLEVEL% neq 0 exit 1

cmake --build . --target install --config Release
if %ERRORLEVEL% neq 0 exit 1
