@echo off
cmake -S "%SRC_DIR%\Titan-File-Filter-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target TitanFileFilterJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\TitanFileFilterJsonSDK.dll" "%SRC_DIR%\Titan-File-Filter-Python-pypi\titan_file_filter\TitanFileFilterJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Titan-File-Filter-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
