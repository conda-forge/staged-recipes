@echo ON
setlocal enabledelayedexpansion

make OS=WINDOWS
if errorlevel 1 exit 1

mkdir %PREFIX%\bin
copy teensy_loader_cli.exe  %PREFIX%\bin\
if errorlevel 1 exit 1

exit 0
