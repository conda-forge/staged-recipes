@echo off

set RAWPY_USE_SYSTEM_LIBRAW=1

%PYTHON% -m pip install . -vv
if errorlevel 1 exit 1
