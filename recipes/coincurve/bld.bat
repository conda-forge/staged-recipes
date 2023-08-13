@echo off
setlocal enableextensions enabledelayedexpansion
%PYTHON% -m pip install --use-pep517 . -vv .
if errorlevel 1 exit 1
