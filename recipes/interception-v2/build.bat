@echo off
cmake -S "%SRC_DIR%\Interception-V2-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target InterceptionV2JsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\InterceptionV2JsonSDK.dll" "%SRC_DIR%\Interception-V2-Python-pypi\interception_v2\InterceptionV2JsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Interception-V2-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
