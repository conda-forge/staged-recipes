@echo on
setlocal enabledelayedexpansion

call pnpm install
if errorlevel 1 exit 1

call pnpm install --save-dev @types/jest
if errorlevel 1 exit 1

call pnpm install --prod
if errorlevel 1 exit 1

call pnpm licenses list --json | pnpm-licenses generate-disclaimer --json-input --output-file=%SRC_DIR%\ThirdPartyLicenses.txt
if errorlevel 1 exit 1

call pnpm pack
if errorlevel 1 exit 1

call npm config set prefix %BUILD_PREFIX%
if errorlevel 1 exit 1

dir
echo %PKG_VERSION%

call npm install --userconfig nonexistentrc --global "dydxprotocol-node-service-base-dev-%PKG_VERSION%.tgz"
if errorlevel 1 exit 1
