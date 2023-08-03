setlocal EnableDelayedExpansion

mkdir build
cd build

::Configure
cmake ^
    %CMAKE_ARGS% ^
    -B . ^
    -S %SRC_DIR% ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DPYTHON_EXECUTABLE="%PREFIX%\python" ^
    -DPython_FIND_STRATEGY=LOCATION ^
    -DSP3_BUILD_TEST=OFF
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

echo "========================="
echo "List PREFIX dir which is:"
echo %PREFIX%
dir %PREFIX%
echo "========================="
echo "List LIBRARY_PREFIX dir which is:"
echo %LIBRARY_PREFIX%
dir %LIBRARY_PREFIX%
echo "========================="
echo "List LIBRARY_BIN dir which is:"
echo %LIBRARY_BIN%
dir %LIBRARY_BIN%