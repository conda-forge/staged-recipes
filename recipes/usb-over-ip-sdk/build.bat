@echo off
cmake -S "%SRC_DIR%\USB-over-IP-SDK-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target USBoverIPSDKJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\USBoverIPSDKJsonSDK.dll" "%SRC_DIR%\USB-over-IP-SDK-Python-pypi\usb_over_ip_sdk\USBoverIPSDKJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\USB-over-IP-SDK-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
