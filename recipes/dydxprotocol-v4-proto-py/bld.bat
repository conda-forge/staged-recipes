@echo on
setlocal enabledelayedexpansion

cd %SRC_DIR%

powershell -Command "(Get-Content %SRC_DIR%/v4-proto-py/setup.py) -replace 'version=\"0.0.0\"', 'version=\"%PKG_VERSION%\"' | Set-Content %SRC_DIR%/v4-proto-py/setup.py"
if errorlevel 1 exit 1

call dockerd --experimental
exit 1

bash -c make -e -w debug -f %SRC_DIR%\\Makefile v4-proto-py-gen
if errorlevel 1 exit 1
