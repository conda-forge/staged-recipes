@echo off
setlocal EnableDelayedExpansion

rm -rf coincurve.egg-info
rm -rf libsecp256k1

set SHARED_NAME=!PKG_NAME:-shared=!
if "!SHARED_NAME!"=="%PKG_NAME%" (
  set "SECP256K1_SHARED_LIBS=0"
) else (
  set "SECP256K1_SHARED_LIBS=1"
)

:: %PYTHON% %RECIPE_DIR%\compose_cffi_files.py
:: if %ERRORLEVEL% neq 0 exit 1

%PYTHON% -m pip install --use-pep517 . -vvv
if %ERRORLEVEL% neq 0 exit 1
