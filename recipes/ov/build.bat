go build -v -o %PREFIX%\bin\ov.exe .

REM Generate PowerShell completion file for Windows environment roots
if not exist "%PREFIX%\share\powershell\completions" mkdir "%PREFIX%\share\powershell\completions"
"%PREFIX%\bin\ov.exe" --completion powershell > "%PREFIX%\share\powershell\completions\ov.ps1"
