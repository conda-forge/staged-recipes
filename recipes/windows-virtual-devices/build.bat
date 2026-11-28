@echo off
cmake -S "%SRC_DIR%\Windows-Virtual-Devices-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target WindowsVirtualDevicesJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\WindowsVirtualDevicesJsonSDK.dll" "%SRC_DIR%\Windows-Virtual-Devices-Python-pypi\windows_virtual_devices\WindowsVirtualDevicesJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Windows-Virtual-Devices-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
