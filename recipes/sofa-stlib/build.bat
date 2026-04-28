setlocal EnableDelayedExpansion

::Configure
cmake %CMAKE_ARGS% ^
  -B build ^
  -S %SRC_DIR% ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DPython_EXECUTABLE:PATH="%PREFIX%\python.exe" ^
  -DPLUGIN_SOFAPYTHON:BOOL=ON
if errorlevel 1 exit 1

:: Build.
cmake --build build --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --install build
if errorlevel 1 exit 1