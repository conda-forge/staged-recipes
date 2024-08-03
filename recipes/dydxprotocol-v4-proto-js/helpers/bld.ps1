Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. "${env:RECIPE_DIR}/helpers/js_build.ps1"

# Set environment variables
$env:npm_config_build_from_source = $true
$env:npm_config_legacy_peer_deps = $true
$env:NPM_CONFIG_USERCONFIG = "/tmp/nonexistentrc"

New-Item -ItemType Directory -Path "${env:SRC_DIR}/_conda-logs" -Force

# Define conda packages
$main_package="@dydxprotocol/v4-proto"

# Build process contains reference to the main directory, but module name is different
# So we build in 2 phases: prepare the package then build the main package
Push-Location "${env:SRC_DIR}/js_module_source/v4-proto-js"
  pnpm install --save @cosmjs/tendermint-rpc
  pnpm install --save-dev @types/node @types/long@4.0.2
  pnpm run transpile
  if ($IsMacOS) {
    Get-ChildItem -Path "src/codegen" -Filter "*.ts" | ForEach-Object {
      (Get-Content -Path $_.FullName) -replace '\(e\) =>', '($1: any) =>' | Set-Content -Path $_.FullName
    }
  } else {
    Get-ChildItem -Path "src/codegen" -Filter "*.ts" | ForEach-Object {
      (Get-Content -Path $_.FullName) -replace '\(e\) =>', '($1: any) =>' | Set-Content -Path $_.FullName
    }
  }
Pop-Location

New-Item -ItemType Directory -Path "${env:SRC_DIR}/${main_package}" -Force
Push-Location "${env:SRC_DIR}/js_module_source/v4-proto-js"
  tar -cf - . | tar -xf - -C "${env:SRC_DIR}/${main_package}"
Pop-Location

Push-Location "${env:SRC_DIR}/${main_package}"
  # Patch version
  if ($IsMacOS) {
    (Get-Content -Path "package.json") -replace '0.0.0', "${env:PKG_VERSION}" | Set-Content -Path "package.json"
  } else {
    (Get-Content -Path "package.json") -replace '0.0.0', "${env:PKG_VERSION}" | Set-Content -Path "package.json"
  }

  pnpm tsc --project ./tsconfig.json --traceResolution > "${env:SRC_DIR}/_conda-logs/tsc.log" 2>&1
  pnpm install

  Third-Party-Licenses "${env:SRC_DIR}/${main_package}"
  Copy-Item -Path "LICENSE" -Destination "${env:SRC_DIR}/LICENSE"

  pnpm pack
Pop-Location
