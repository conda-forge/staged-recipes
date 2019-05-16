:: Copy over binary
copy "bin\gdrive-windows-x64.exe" "%LIBRARY_BIN%\gdrive.exe"
if errorlevel 1 exit 1
