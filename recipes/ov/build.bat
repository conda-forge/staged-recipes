go build -v -ldflags="-X main.Version=%PKG_VERSION% -X main.Revision=conda-forge" -o %PREFIX%\bin\ov.exe .
go-licenses save . --save_path=".\license-files"

REM Generate PowerShell completion file for Windows environment roots
if not exist "%PREFIX%\share\powershell\completions" mkdir "%PREFIX%\share\powershell\completions"
"%PREFIX%\bin\ov.exe" --completion powershell > "%PREFIX%\share\powershell\completions\ov.ps1"
