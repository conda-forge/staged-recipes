@echo on

:: The VERSION file in the v2.1.0 release archive still carries the "-dev" suffix
echo %PKG_VERSION%> VERSION

cmake -S . -B build -G Ninja %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DXAD_ENABLE_TESTS=OFF ^
  -DXAD_WARNINGS_PARANOID=OFF ^
  -DXAD_SIMD_OPTION=SSE2
if errorlevel 1 exit 1
cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1
cmake --install build
if errorlevel 1 exit 1

rmdir /s /q "%LIBRARY_PREFIX%\share\doc\xad"
