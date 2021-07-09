@echo off
setlocal
IF NOT DEFINED MSYS2_PATH_TYPE set MSYS2_PATH_TYPE=minimal
set CHERE_INVOKING=1
cmd /C C:\msys64\usr\bin\bash.exe -lc %*
