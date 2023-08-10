setlocal EnableDelayedExpansion

mkdir build
cd build

::Configure
:: SofaPython3 installs python package in non-standard directory suffix,
:: using Library/lib/python3/site-packages instead of lib/site-packages,
:: which would imply to redefine the PYTHONPATH environment variable at activation.
:: This is changed using the SP3_PYTHON_PACKAGES_DIRECTORY cmake variable.
cmake %CMAKE_ARGS% ^
  -B . ^
  -S %SRC_DIR% ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DPython_EXECUTABLE:PATH="%PREFIX%\python.exe" ^
  -DSP3_PYTHON_PACKAGES_DIRECTORY:PATH="..\..\lib\site-packages" ^
  -DSP3_BUILD_TEST:BOOL=OFF
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --target install
if errorlevel 1 exit 1

:: Test
ctest --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1
