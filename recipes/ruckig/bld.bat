mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True ^
    -DPYBIND11_FINDPYTHON:BOOL=ON ^
    -DBUILD_PYTHON_MODULE:BOOL=ON ^
    -DPYTHON_EXECUTABLE:PATH=%PYTHON% ^
    -DPython_EXECUTABLE:PATH=%PYTHON% ^
    -DPython3_EXECUTABLE:PATH=%PYTHON% ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Install manually Python extension
cp ruckig.cp* %SP_DIR%

:: Test.
ctest -C Release
if errorlevel 1 exit 1
