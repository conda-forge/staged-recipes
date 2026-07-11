@echo off
setlocal enabledelayedexpansion

"%PYTHON%" -m build --no-isolation --verbose -Csetup-args=-Dfvsvariants=%variants% -Csetup-args=-Dbuildtype=%mode%
if errorlevel 1 exit 1
