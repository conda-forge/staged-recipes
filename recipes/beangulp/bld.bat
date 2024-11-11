setlocal EnableDelayedExpansion
@echo on

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if %ERRORLEVEL% neq 0 exit 1

REM These support files get installed as if they were freestanding Python
REM packages!
rmdir /s /q %SP_DIR%\examples %SP_DIR%\tools
if %ERRORLEVEL% neq 0 exit 1
