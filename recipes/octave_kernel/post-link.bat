@echo off

"%PREFIX%"\Python.exe -m octave_kernel.install > NUL 2>&1 && if errorlevel 1 exit 1
