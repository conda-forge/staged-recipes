
@echo off

SetLocal EnableExtensions EnableDelayedExpansion
if errorlevel 1 exit 1

rem  Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
rem  This causes them to be run on environment [de]activation.
rem  https://github.com/mamba-org/mamba/blob/master/libmamba/src/core/activation.cpp#L32-L47
set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"
if errorlevel 1 exit 1

for %%G in (activate deactivate) do (

    if not exist %PREFIX%\etc\conda\%%G.d mkdir %PREFIX%\etc\conda\%%G.d
    if errorlevel 1 exit 1

    set "BAT_SCRIPT=%PREFIX%\etc\conda\%%G.d\%PKG_NAME%-%%G.bat"
    echo @echo off > "!BAT_SCRIPT!"
    if errorlevel 1 exit 1
    echo set "PKG_UUID=%PKG_UUID%" >> "!BAT_SCRIPT!"
    if errorlevel 1 exit 1
    type %RECIPE_DIR%\%%G.bat >> "!BAT_SCRIPT!"
    if errorlevel 1 exit 1

    rem  Copy unix shell activation scripts, needed by Windows Bash users
    set "SH_SCRIPT=%PREFIX%\etc\conda\%%G.d\%PKG_NAME%-%%G.sh"
    if errorlevel 1 exit 1
rem    echo:#!/bin/bash -euo > "!SH_SCRIPT!"
    echo PKG_UUID="%PKG_UUID%" >> "!SH_SCRIPT!"
    if errorlevel 1 exit 1
    type %RECIPE_DIR%\%%G.sh >> "!SH_SCRIPT!"
    if errorlevel 1 exit 1
rem     type "!SH_SCRIPT!"
)
if errorlevel 1 exit 1
