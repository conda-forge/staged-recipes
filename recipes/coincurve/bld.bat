@echo off
setlocal enableextensions enabledelayedexpansion
conda install -c conda-forge python-build
%PYTHON% -m build .
if errorlevel 1 exit 1

