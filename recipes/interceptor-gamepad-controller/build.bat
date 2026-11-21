@echo off
cmake -S "%SRC_DIR%\Interceptor-Gamepad-Controller-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DFAMILY_NATIVE_SOURCE="%SRC_DIR%\packaging\native" -DFAMILY_TEST_BACKEND=OFF
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target InterceptorGamepadControllerBridge
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\InterceptorGamepadControllerBridge.dll" "%SRC_DIR%\Interceptor-Gamepad-Controller-Python-pypi\interceptor_gamepad_controller\InterceptorGamepadControllerBridge.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Interceptor-Gamepad-Controller-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
