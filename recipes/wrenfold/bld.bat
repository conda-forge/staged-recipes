@echo off

:: Python library with no headers.
set WF_SKIP_HEADER_INSTALL=skip
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if %errorlevel% neq 0 exit /b %errorlevel%

:: Install headers.
mkdir /I %PREFIX%\include\wrenfold
xcopy /s/v components\runtime\wrenfold\*.h %PREFIX%\include\wrenfold\
xcopy LICENSE %PREFIX%\include\wrenfold\
