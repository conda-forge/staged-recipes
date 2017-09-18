@echo off

"%PREFIX%"\Python.exe -m sas_kernel.install --prefix %PREFIX% > NUL 2>&1 && if errorlevel 1 exit 1
