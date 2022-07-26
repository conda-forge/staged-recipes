:: Install SysConfig: System configuration tool
start /wait sysconfig-1.13.0_2553-setup.exe --mode unattended --prefix %SRC_DIR%\tisysconfig || exit /b 1

:: Copy dist directory
if not exist %LIBRARY_LIB%\tisysconfig mkdir %LIBRARY_LIB%\tisysconfig || exit 1
xcopy /I /E %SRC_DIR%\tisysconfig\dist %LIBRARY_LIB%\tisysconfig || exit /b 1

:: Copy tisysconfig script
if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1
copy %RECIPE_DIR%\tisysconfig.bat %LIBRARY_BIN%
