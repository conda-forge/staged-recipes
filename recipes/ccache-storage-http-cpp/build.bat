@echo on

cmake -S . -B build -G Ninja %CMAKE_ARGS% -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit /b 1

cmake --build build --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1

cmake --install build --config Release
if errorlevel 1 exit /b 1