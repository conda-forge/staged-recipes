@echo off
cmake -S "%SRC_DIR%\AutoHotInterceptor-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DFAMILY_NATIVE_SOURCE="%SRC_DIR%\packaging\native" -DFAMILY_TEST_BACKEND=OFF
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target AutoHotInterceptorBridge
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\AutoHotInterceptorBridge.dll" "%SRC_DIR%\AutoHotInterceptor-Python-pypi\autohotinterceptor\AutoHotInterceptorBridge.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\AutoHotInterceptor-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
