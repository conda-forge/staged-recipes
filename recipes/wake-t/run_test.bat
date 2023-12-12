@echo on

:: Example
%PYTHON% examples\track_plasma_fluid.py
if errorlevel 1 exit 1

:: pytest
%PYTHON% -m pytest -s -vvvv tests\
if errorlevel 1 exit 1
