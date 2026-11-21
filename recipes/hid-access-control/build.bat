@echo off
cmake -S "%SRC_DIR%\HID-Access-Control-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target HIDAccessControlJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\HIDAccessControlJsonSDK.dll" "%SRC_DIR%\HID-Access-Control-Python-pypi\hid_access_control\HIDAccessControlJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\HID-Access-Control-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
