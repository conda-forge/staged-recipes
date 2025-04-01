@echo off

set PYTHONIOENCODING=utf-8

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
