cd trunk
cmake -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
-D HDF5_INCLUDE_DIR=%LIBRARY_PREFIX%\include ^
-D HDF5_LIB_PATH=%LIBRARY_PREFIX%\lib ^
-D CMAKE_BUILD_TYPE=Release ^
-G "NMake Makefiles" .
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

# need to move libkea.dll to bin
move %LIBRARY_PREFIX%\lib\libkea.dll %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1
