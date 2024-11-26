setlocal EnableDelayedExpansion
@echo on

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if %ERRORLEVEL% neq 0 exit 1

REM Some support files get installed as if they were freestanding Python
REM packages!
rmdir /s /q %SP_DIR%\docs
if %ERRORLEVEL% neq 0 exit 1
