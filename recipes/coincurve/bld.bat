@echo off
setlocal enableextensions enabledelayedexpansion
%PYTHON% -m build
if errorlevel 1 exit 1

