@echo on

REM The meflib source is extracted to meflib_src\meflib-<commit>\
REM We need to copy it to meflib\ where setup.py expects it
xcopy /E /I meflib_src\meflib-*\meflib meflib\

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
