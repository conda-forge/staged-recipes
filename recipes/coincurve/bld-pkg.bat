@echo off
setlocal EnableDelayedExpansion

set SHARED_NAME=!PKG_NAME:-shared=!
if "!SHARED_NAME!"=="%PKG_NAME%" (
  set "SECP256K1_SHARED_LIBS=0"
) else (
  set "SECP256K1_SHARED_LIBS=1"
)

%PYTHON% -m pip install --use-pep517 . -vvv
if %ERRORLEVEL% neq 0 exit 1
