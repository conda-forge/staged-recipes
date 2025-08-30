@ECHO ON

REM This is the standard command for installing a modern Python package in conda-build
REM We add cpp_std to ensure the compiler uses the C++20 standard
"%PYTHON%" -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++20"

IF %ERRORLEVEL% NEQ 0 exit /B 1
