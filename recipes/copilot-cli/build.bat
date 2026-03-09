echo on
dir /A

mkdir "%LIBRARY_BIN%"
if errorlevel 1 exit 1

copy /B /V /Y copilot.exe "%LIBRARY_BIN%\copilot.exe"
if errorlevel 1 exit 1
