@echo off
:: Switch code page to UTF-8 so console can handle UTF-8 output
chcp 65001 >nul

:: Force Python to use UTF-8 for stdio (works on Python 3.7+)
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8

:: Install using pip (conda-build will use this script on Windows)
%PYTHON% -m pip install . --no-deps --ignore-installed -vv
