REM remove unneeded librar stubs
rd /S /Q %SRC_DIR%\include
rd /S /Q %SRC_DIR%\lib
rd /S /Q %SRC_DIR%\share\man
if errorlevel 1 exit 1

mkdir %SRC_DIR%\share\doc\graphviz
move %SRC_DIR%\share\graphviz\doc %SRC_DIR%\share\doc\graphviz
if errorlevel 1 exit 1

xcopy /S %SRC_DIR% %LIBRARY_PREFIX%
if errorlevel 1 exit 1

del %LIBRARY_PREFIX%\bld.bat
if errorlevel 1 exit 1
