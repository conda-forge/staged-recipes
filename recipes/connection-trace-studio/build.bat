@echo off
cmake -S "%SRC_DIR%\Connection-Trace-Studio-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target ConnectionTraceStudioJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\ConnectionTraceStudioJsonSDK.dll" "%SRC_DIR%\Connection-Trace-Studio-Python-pypi\connection_trace_studio\ConnectionTraceStudioJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Connection-Trace-Studio-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
