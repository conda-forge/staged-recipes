@echo on

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
copy /y k3d-windows-amd64.exe "%PREFIX%\bin\k3d.exe"
if errorlevel 1 exit 1
