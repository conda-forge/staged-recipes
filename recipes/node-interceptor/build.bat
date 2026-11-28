@echo off
cmake -S "%SRC_DIR%\node-interceptor-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target nodeinterceptorJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\nodeinterceptorJsonSDK.dll" "%SRC_DIR%\node-interceptor-Python-pypi\node_interceptor\nodeinterceptorJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\node-interceptor-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
