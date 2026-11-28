@echo off
cmake -S "%SRC_DIR%\Titan-Network-Filter-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target TitanNetworkFilterJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\TitanNetworkFilterJsonSDK.dll" "%SRC_DIR%\Titan-Network-Filter-Python-pypi\titan_network_filter\TitanNetworkFilterJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Titan-Network-Filter-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
