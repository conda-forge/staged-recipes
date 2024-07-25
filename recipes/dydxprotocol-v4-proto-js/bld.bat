@echo on
setlocal enabledelayedexpansion

cd %SRC_DIR%

powershell -Command "(Get-Content %SRC_DIR%/v4-proto-js/package.json) -replace '0.0.0', '%PKG_VERSION%' | Set-Content %SRC_DIR%/v4-proto-js/package.json"
if errorlevel 1 exit 1

:: JavaScript client
cd %SRC_DIR%\v4-proto-js

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
