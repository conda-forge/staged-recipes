@echo on
setlocal enabledelayedexpansion

cd %SRC_DIR%

  call pnpm install --save-dev @types/jest
  if errorlevel 1 exit 1

  call pnpm run build
  if errorlevel 1 exit 1

  call pnpm install
  if errorlevel 1 exit 1

  call pnpm pack
  if errorlevel 1 exit 1

  call pnpm licenses list --json | pnpm-licenses generate-disclaimer --json-input --output-file=%SRC_DIR%\ThirdPartyLicenses.txt
  if errorlevel 1 exit 1

  call npm install --userconfig nonexistentrc --global "dydxprotocol-node-service-base-dev-%PKG_VERSION%.tgz" --dry-run
  call npm install --userconfig nonexistentrc --global "dydxprotocol-node-service-base-dev-%PKG_VERSION%.tgz"
  if errorlevel 1 exit 1
