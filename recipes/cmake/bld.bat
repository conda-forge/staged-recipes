move bin\* %LIBRARY_BIN%\
if errorlevel 1 exit 1

move share %LIBRARY_PREFIX%\
if errorlevel 1 exit 1
