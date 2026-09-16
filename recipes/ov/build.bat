go build -v -o %LIBRARY_BIN%\ov.exe .

REM Generate PowerShell completion file for Windows environment roots
if not exist "%LIBRARY_PREFIX%\share\powershell\completions" mkdir "%LIBRARY_PREFIX%\share\powershell\completions"
"%LIBRARY_BIN%\ov.exe" --completion powershell > "%LIBRARY_PREFIX%\share\powershell\completions\ov.ps1"
