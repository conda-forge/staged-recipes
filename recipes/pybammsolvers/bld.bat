@echo off

SET CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%

python -m pip install . -vv --no-deps --no-build-isolation
if %errorlevel% NEQ 0 exit /b %errorlevel%
