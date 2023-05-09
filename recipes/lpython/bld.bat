call build0.bat
if errorlevel 1 exit 1

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DLPYTHON_BUILD_ALL=yes ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DXJUPYTER_DATA_DIR=%PREFIX%\\share\\jupyter ^
    -DCMAKE_PREFIX_PATH=%PREFIX% ^
    -DWITH_LLVM=yes ^
    -DWITH_XEUS=yes ^
    -DWITH_STACKTRACE=no ^
    %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1
