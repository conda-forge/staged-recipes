@echo off
cmake -S "%SRC_DIR%\FyraInput-Gamepad-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DFAMILY_NATIVE_SOURCE="%SRC_DIR%\packaging\native" -DFAMILY_TEST_BACKEND=OFF
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target FyraInputGamepadBridge
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\FyraInputGamepadBridge.dll" "%SRC_DIR%\FyraInput-Gamepad-Python-pypi\fyrainput_gamepad\FyraInputGamepadBridge.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\FyraInput-Gamepad-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
