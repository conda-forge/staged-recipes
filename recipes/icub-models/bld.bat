mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=ON ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DPython3_EXECUTABLE:PATH=%PYTHON% ^
    -DICUB_MODELS_COMPILE_PYTHON_BINDINGS:BOOL=ON ^
    -DICUB_MODELS_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON ^
    -DICUB_MODELS_PYTHON_PIP_METADATA_INSTALL:BOOL=ON ^
    -DICUB_MODELS_PYTHON_PIP_METADATA_INSTALLER=conda ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure -C Release 
if errorlevel 1 exit 1
