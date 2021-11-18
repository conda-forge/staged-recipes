@echo off
echo ** Running bld.bat **

REM It's important that the name of this file is exactly bld.bat

"%PYTHON%" ./setup_for_condabuild.py install
if errorlevel 1 exit 1