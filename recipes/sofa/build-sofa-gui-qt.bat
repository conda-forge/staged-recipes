setlocal EnableDelayedExpansion
@echo on


rmdir /S /Q build-sofa-gl

mkdir build-sofa-gl
cd build-sofa-gl

:: Configure
cmake %CMAKE_ARGS% ^
  -B . ^
  -S %SRC_DIR%\Sofa\GUI\Qt ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DSOFA_ENABLE_LEGACY_HEADERS:BOOL=OFF ^
  -DSOFA_BUILD_TESTS:BOOL=OFF ^
  -DSOFA_FLOATING_POINT_TYPE=double ^
  -DSOFA_ALLOW_FETCH_DEPENDENCIES:BOOL=OFF
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --target install
if errorlevel 1 exit 1
