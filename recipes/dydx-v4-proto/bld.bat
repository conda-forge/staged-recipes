@echo on
setlocal enabledelayedexpansion

powershell -Command "(Get-Content v4-proto-py\setup.py) -replace 'version=0.0.0', 'version=%PKG_VERSION%' | Set-Content v4-proto-py\setup.py"
if errorlevel 1 exit 1

call %BUILD_PREFIX%\Library\bin\gnumake.exe v4-proto-py-gen
if errorlevel 1 exit 1

:: JavaScript client
cd v4-proto-js
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
