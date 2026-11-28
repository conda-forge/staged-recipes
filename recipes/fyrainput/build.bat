@echo off
cmake -S "%SRC_DIR%\FyraInput-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DFAMILY_NATIVE_SOURCE="%SRC_DIR%\packaging\native" -DFAMILY_TEST_BACKEND=OFF
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target FyraInputBridge
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\FyraInputBridge.dll" "%SRC_DIR%\FyraInput-Python-pypi\fyrainput\FyraInputBridge.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\FyraInput-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
