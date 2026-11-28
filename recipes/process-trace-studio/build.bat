@echo off
cmake -S "%SRC_DIR%\Process-Trace-Studio-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target ProcessTraceStudioJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\ProcessTraceStudioJsonSDK.dll" "%SRC_DIR%\Process-Trace-Studio-Python-pypi\process_trace_studio\ProcessTraceStudioJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Process-Trace-Studio-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
