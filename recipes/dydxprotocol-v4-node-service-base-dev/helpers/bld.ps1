# Set environment variables
$env:npm_config_build_from_source = $true
$env:npm_config_legacy_peer_deps = $true
$env:NPM_CONFIG_USERCONFIG = "/tmp/nonexistentrc"

# Define conda packages
$main_package="@dydxprotocol/node-service-base-dev"

New-Item -ItemType Directory -Path "$env:SRC_DIR/$main_package" -Force
Push-Location "$env:SRC_DIR/js_module_source"
    tar -cf - . | tar -xf - -C "$env:SRC_DIR/$main_package"
Pop-Location

# Navigate to directory and run commands
Push-Location $env:SRC_DIR/$main_package
    Get-ChildItem -Path . -Recurse
    # Build
    pnpm install
    pnpm run compile

    # Install
    pnpm install

    # Generate licenses
    . "${env:RECIPE_DIR}/helpers/js_build.ps1"
    Third-Party-Licenses "$env:SRC_DIR/$main_package"
    Copy-Item -Path "LICENSE" "$env:SRC_DIR/LICENSE"

    # Pack and install
    pnpm pack

    New-Item -ItemType Directory -Path "$env:PREFIX\lib"
    Push-Location "$env:PREFIX\lib"
        Invoke-Expression "npm install --global $env:SRC_DIR\$env:PKG_NAME-$env:PKG_VERSION.tgz"
        if ($LASTEXITCODE -ne 0) {
            exit 1
        }
    Pop-Location
Pop-Location