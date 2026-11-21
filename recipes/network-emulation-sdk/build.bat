@echo off
cmake -S "%SRC_DIR%\Network-Emulation-SDK-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target NetworkEmulationSDKJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\NetworkEmulationSDKJsonSDK.dll" "%SRC_DIR%\Network-Emulation-SDK-Python-pypi\network_emulation_sdk\NetworkEmulationSDKJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Network-Emulation-SDK-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
