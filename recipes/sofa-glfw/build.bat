setlocal EnableDelayedExpansion

mkdir build
cd build

::Configure
cmake %CMAKE_ARGS% ^
  -B . ^
  -S %SRC_DIR% ^
  -G Ninja ^
  -DPLUGIN_SOFAGLFW:BOOL=ON ^
  -DPLUGIN_SOFAIMGUI:BOOL=ON ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DPython_EXECUTABLE:PATH="%PREFIX%\python.exe" ^
  -DSP3_PYTHON_PACKAGES_DIRECTORY:PATH="..\..\lib\site-packages"
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --target install
if errorlevel 1 exit 1

:: Testing compilation as 3rd party
cd ..
mkdir build-test
cmake %CMAKE_ARGS% ^
  -B build-test ^
  -S %SRC_DIR%\SofaImGui\extensions\SofaImGui.Camera ^
  -DCMAKE_VERBOSE_MAKEFILE=ON
if errorlevel 1 exit 1

cmake --build build-test --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1
