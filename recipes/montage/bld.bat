make
if errorlevel 1 exit 1

xcopy /E bin %LIBRARY_BIN%
