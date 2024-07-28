# Set environment variables
$env:npm_config_build_from_source = $true
$env:npm_config_legacy_peer_deps = $true
$env:NPM_CONFIG_USERCONFIG = "/tmp/nonexistentrc"

# Define conda packages
$main_package="@dydxprotocol/node-service-base-dev"
$condaPackages = @(
    "eslint",
    "@typescript-eslint/eslint-plugin",
    "@typescript-eslint/parser"
)

New-Item -ItemType Directory -Path "$env:SRC_DIR/$main_package" -Force
Push-Location "$env:SRC_DIR/js_module_source"
    tar -cf - . | tar -xf - -C "$env:SRC_DIR/$main_package"
Pop-Location

# Remove and create symlink for node
Remove-Item "$env:PREFIX/bin/node" -Force
New-Item -ItemType SymbolicLink -Path "$env:PREFIX/bin/node" -Target "$env:BUILD_PREFIX/bin/node"

# Call function and store result
$filterCondaPackages = Reference-CondaPackages -mainPkg "node-service-base-dev" -pkgs $condaPackages
$licensesFilterCondaPkgs = $filterCondaPackages[0]
$installFilterCondaPkgs = $filterCondaPackages[1]

# Navigate to directory and run commands
Push-Location $main_package
    Remove-Item "package-lock.json" -Force

    # Build
    pnpm install
    Remove-Item -Recurse -Force build
    pnpm run compile
    # pnpm audit fix

    # Install
    Invoke-Expression "pnpm install $global:install_filter_conda_pkgs"

    # Generate licenses
    third_party_licenses "$env:SRC_DIR/$main_package"
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