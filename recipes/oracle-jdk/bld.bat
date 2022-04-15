
@echo off

SetLocal EnableExtensions EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This causes them to be run on environment [de]activation.
:: https://github.com/mamba-org/mamba/blob/master/libmamba/src/core/activation.cpp#L32-L47
set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"

for %%G in (activate deactivate) do (

    if not exist %PREFIX%\etc\conda\%%G.d mkdir %PREFIX%\etc\conda\%%G.d

    set "BAT_SCRIPT=%PREFIX%\etc\conda\%%G.d\%PKG_NAME%-%%G.bat"
    echo @echo off > "!BAT_SCRIPT!"
    echo set "PKG_UUID=%PKG_UUID%" >> "!BAT_SCRIPT!"
    type %RECIPE_DIR%\%%G.bat >> "!BAT_SCRIPT!"

    :: Copy unix shell activation scripts, needed by Windows Bash users
    set "SH_SCRIPT=%PREFIX%\etc\conda\%%G.d\%PKG_NAME%-%%G.sh"
::   echo:#!/bin/bash -euo > "!SH_SCRIPT!"
    echo PKG_UUID="%PKG_UUID%" >> "!SH_SCRIPT!"
    type %RECIPE_DIR%\%%G.sh >> "!SH_SCRIPT!"
    type "!SH_SCRIPT!"
)
