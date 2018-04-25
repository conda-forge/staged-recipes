:: Copy over binary
copy "bin\container-diff-windows-amd64.exe" "%LIBRARY_BIN%\container-diff.exe"
if errorlevel 1 exit 1
