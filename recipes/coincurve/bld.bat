@echo off
setlocal enableextensions enabledelayedexpansion
%PYTHON% -m pip install build
%PYTHON% -m build .
if errorlevel 1 exit 1

