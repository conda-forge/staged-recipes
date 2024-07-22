@echo off

cd v4-proto-js
  call pnpm install
  if errorlevel 1 exit 1

  call pnpm pack
  if errorlevel 1 exit 1

  call pnpm licenses list --json | pnpm-licenses generate-disclaimer --json-input --output-file="$SRC_DIR"/ThirdPartyLicenses.txt
  if errorlevel 1 exit 1

  call npm install --userconfig nonexistentrc --global "dydxprotocol-v4-proto-%PKG_VERSION%.tgz"
  if errorlevel 1 exit 1
