@echo off
cmake -S "%SRC_DIR%\User-Backed-Virtual-Disk-SDK-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target UserBackedVirtualDiskSDKJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\UserBackedVirtualDiskSDKJsonSDK.dll" "%SRC_DIR%\User-Backed-Virtual-Disk-SDK-Python-pypi\user_backed_virtual_disk_sdk\UserBackedVirtualDiskSDKJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\User-Backed-Virtual-Disk-SDK-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
