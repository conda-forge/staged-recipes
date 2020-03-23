@echo off
setlocal EnableDelayedExpansion

nmake all
if errorlevel 1 exit 1
