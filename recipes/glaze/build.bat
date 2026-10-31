@echo on
setlocal enabledelayedexpansion

cmake -S . -B build -G Ninja %CMAKE_ARGS% ^
  -DBUILD_TESTING=OFF ^
  -Dglaze_ENABLE_FUZZING=OFF ^
  -Dglaze_DEVELOPER_MODE=OFF

if %errorlevel% neq 0 exit /b %errorlevel%

cmake --build build -j %CPU_COUNT%
if %errorlevel% neq 0 exit /b %errorlevel%

cmake --install build
if %errorlevel% neq 0 exit /b %errorlevel%