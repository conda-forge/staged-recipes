@echo off
cmake -S "%SRC_DIR%\Remote-Workstation-SDK-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target RemoteWorkstationSDKJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\RemoteWorkstationSDKJsonSDK.dll" "%SRC_DIR%\Remote-Workstation-SDK-Python-pypi\remote_workstation_sdk\RemoteWorkstationSDKJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Remote-Workstation-SDK-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
