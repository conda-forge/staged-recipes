@echo off
cmake -S "%SRC_DIR%" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DICB_TEST_BACKEND=OFF -DBUILD_TESTING=OFF
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target InterceptorBridge
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\InterceptorBridge.dll" "%SRC_DIR%\Interceptor-MultiLang-Python-pypi\interceptor\InterceptorBridge.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Interceptor-MultiLang-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
