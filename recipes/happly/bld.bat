@echo on
setlocal EnableDelayedExpansion

mkdir %PREFIX%\\Library\\include

copy happly.h %PREFIX%\Library\include\happly.h
if %ERRORLEVEL% neq 0 exit 1
