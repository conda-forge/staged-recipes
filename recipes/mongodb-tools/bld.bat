call build.bat
if errorlevel 1 exit 1

move bin\* %LIBRARY_BIN%\
if errorlevel 1 exit 1