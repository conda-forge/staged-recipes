@echo on
setlocal EnableDelayedExpansion


pkg-config --print-provides "%PKG_NAME%"
pkg-config --exact-version="%PKG_VERSION%" "%PKG_NAME%" || exit 1

REM Add more testing before merge

