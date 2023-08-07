setlocal EnableDelayedExpansion

mkdir build
cd build

::set PYTHON_VERSION=%PY_VER%
::set PY_VER_NO_DOT=%PY_VER:.=%
::set PYTHON_LIBRARY="%CONDA_PREFIX%\libs\python%PY_VER_NO_DOT%.lib"

echo "========================="
echo "Python vars before"
echo %PY_VER%
echo %PYTHON_VERSION%
echo %PY_VER_NO_DOT%
echo %PYTHON%
echo %PYTHON_LIBRARY%

::Configure
cmake --debug-find ^
    %CMAKE_ARGS% ^
    -B . ^
    -S %SRC_DIR% ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DPython_EXECUTABLE="%CONDA_PREFIX%\python.exe" ^
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
echo "List CONDA_PREFIX dir which is:"
echo %CONDA_PREFIX%
dir %CONDA_PREFIX%
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
echo "========================="
echo "Python vars after"
echo %PY_VER%
echo %PYTHON_VERSION%
echo %PY_VER_NO_DOT%
echo %PYTHON%
echo %PYTHON_LIBRARY%
