@echo on
cmake -S . -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%
if %ERRORLEVEL% neq 0 exit /b 1
cmake --build build
if %ERRORLEVEL% neq 0 exit /b 1
ctest --test-dir build --output-on-failure
if %ERRORLEVEL% neq 0 exit /b 1
cmake --install build
if %ERRORLEVEL% neq 0 exit /b 1
