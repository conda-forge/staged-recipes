@echo off

if exist "%PREFIX%\Library\lib\libaatm.%SHLIB_EXT%" (
    rem  Do nothing, file exists
) else (
    exit 1
)
