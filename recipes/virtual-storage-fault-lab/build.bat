@echo off
cmake -S "%SRC_DIR%\Virtual-Storage-Fault-Lab-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target VirtualStorageFaultLabJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\VirtualStorageFaultLabJsonSDK.dll" "%SRC_DIR%\Virtual-Storage-Fault-Lab-Python-pypi\virtual_storage_fault_lab\VirtualStorageFaultLabJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Virtual-Storage-Fault-Lab-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
