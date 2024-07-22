@echo on
setlocal enabledelayedexpansion

cd %SRC_DIR%

powershell -Command "(Get-Content %SRC_DIR%\v4-proto-py\setup.py) -replace 'version=0.0.0', 'version=%PKG_VERSION%' | Set-Content %SRC_DIR%\v4-proto-py\setup.py"
if errorlevel 1 exit 1

bash -c %BUILD_PREFIX%\\Library\\bin\\gnumake.exe -e -w debug -f %SRC_DIR%\\Makefile v4-proto-py-gen
if errorlevel 1 exit 1

:: JavaScript client
cd %SRC_DIR%\v4-proto-js
  powershell -Command "(Get-Content package.json) -replace '0.0.0', '%PKG_VERSION%' | Set-Content package.json"
  if errorlevel 1 exit 1

  call pnpm install
  if errorlevel 1 exit 1

  pnpm run transpile
  if errorlevel 1 exit 1

  call pnpm add @cosmjs/tendermint-rpc @types/node
  if errorlevel 1 exit 1

  call pnpm add long@5.2.3
  if errorlevel 1 exit 1

  call pnpm run build
  if errorlevel 1 exit 1
