@echo off
cmake -S "%SRC_DIR%\File-Trace-Studio-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target FileTraceStudioJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\FileTraceStudioJsonSDK.dll" "%SRC_DIR%\File-Trace-Studio-Python-pypi\file_trace_studio\FileTraceStudioJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\File-Trace-Studio-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
