cmake .. -G "NMake Makefiles" -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DXEXTRA_JUPYTER_DATA_DIR=%PREFIX%\\share\\jupyter %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
