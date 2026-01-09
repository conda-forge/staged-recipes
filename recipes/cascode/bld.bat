@echo off
mkdir %PREFIX%\Scripts
copy cascode.exe %PREFIX%\Scripts\
if errorlevel 1 exit 1
