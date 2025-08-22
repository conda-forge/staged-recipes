:: echo
echo off

:: python version
%PYTHON% --version
if errorlevel 1 exit 1

:: Test in sandbox
%PYTHON% bin/check_py_test.py
if errorlevel 1 exit 1

:: install
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1

:: install result
%PYTHON% -m pip show at_cascade
if errorlevel 1 exit 1

echo 'build.bat: OK'
