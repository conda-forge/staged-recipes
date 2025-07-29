@echo on

REM Copy the binary to the Scripts directory on Windows
mkdir "%PREFIX%\Scripts"
copy gpq.exe "%PREFIX%\Scripts\"
if errorlevel 1 exit 1