@echo off
cmake -S "%SRC_DIR%\Storage-IO-Flight-Recorder-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target StorageIOFlightRecorderJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\StorageIOFlightRecorderJsonSDK.dll" "%SRC_DIR%\Storage-IO-Flight-Recorder-Python-pypi\storage_io_flight_recorder\StorageIOFlightRecorderJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Storage-IO-Flight-Recorder-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
