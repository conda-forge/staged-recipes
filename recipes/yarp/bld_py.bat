cd bindings
rmdir /s /q build
mkdir build
cd build

cmake -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DPython3_EXECUTABLE:PATH=%PYTHON% ^
    -DYARP_COMPILE_BINDINGS:BOOL=ON ^
    -DCREATE_PYTHON:BOOL=ON ^
    -DCMAKE_INSTALL_PYTHON3DIR:PATH="%SP_DIR%" ^
    -DYARP_PYTHON_PIP_METADATA_INSTALL:BOOL=ON ^
    -DYARP_PYTHON_PIP_METADATA_INSTALLER=conda ^
    -DYARP_DISABLE_VERSION_SOURCE:BOOL=ON ^
    ..
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
