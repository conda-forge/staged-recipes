@echo on

REM The meflib source is extracted to meflib_src\ (conda-build strips the top-level dir)
REM setup.py expects include_dirs=["meflib/meflib"], so we need meflib\meflib\
REM The pymef tarball has an empty meflib\ dir (submodule placeholder)
REM Copy the meflib subdirectory into meflib\ to create the nested structure
mkdir meflib\meflib
xcopy /E /I meflib_src\meflib meflib\meflib\

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
