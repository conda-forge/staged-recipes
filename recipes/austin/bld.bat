echo ON

call %BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat
if %ERRORLEVEL% neq 0 exit 1

REM %PYTHON% -m pip install . -vv
REM if errorlevel 1 exit 1
