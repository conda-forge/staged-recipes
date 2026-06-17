@echo off
if not defined SYSTEMROOT set SYSTEMROOT=C:\Windows
if not defined SystemRoot set SystemRoot=C:\Windows
"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if %ERRORLEVEL% neq 0 exit /b 1
