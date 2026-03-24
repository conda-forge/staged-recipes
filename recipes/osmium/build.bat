@echo off
REM Remove contrib folder as it contains libosmium and protozero
REM which will be provided as conda dependencies
if exist contrib (
    rmdir /s /q contrib
)

REM Build and install the package
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
