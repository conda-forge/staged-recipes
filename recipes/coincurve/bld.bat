@echo off
setlocal enableextensions enabledelayedexpansion
%PYTHON% setup.py install
if errorlevel 1 exit 1

