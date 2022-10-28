cd python
rmdir /s /q build
mkdir build
cd build

cmake -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON ^
    -DUSE_SYSTEM_PATHS_FOR_PYTHON_INSTALLATION:BOOL=ON ^
    -DPython3_EXECUTABLE:PATH=%PYTHON% ^
    -DPYTHON_EXECUTABLE:PATH=%PYTHON% ^
    ..
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
