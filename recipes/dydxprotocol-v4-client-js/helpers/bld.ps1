# --- Function definitions ---

# Set environment variables
$env:npm_config_build_from_source = $true
$env:npm_config_legacy_peer_deps = $true
$env:NPM_CONFIG_USERCONFIG = "/tmp/nonexistentrc"

# Define conda packages
$main_package="@dydxprotocol/v4-client-js"

New-Item -ItemType Directory -Path "$env:SRC_DIR/$main_package" -Force
Push-Location "$env:SRC_DIR/js_module_source/v4-client-js"
    $tempTarFile = [System.IO.Path]::GetTempFileName()
    tar -cf $tempTarFile .
    tar -xf $tempTarFile -C "$env:SRC_DIR/$main_package"
    Remove-Item $tempTarFile
Pop-Location

# Navigate to directory and run commands
Push-Location $env:SRC_DIR/$main_package
    pnpm remove grpc-tools
    pnpm install --save-dev @grpc/grpc-js typescript@4.8.4 @types/jest @types/long@4.0.2 @types/node@18.15.13 @types/lodash @cosmjs/crypto
    pnpm install

    pnpm run transpile

    pnpm run compile
    pnpm install --save-dev jest
    $NODE_ENV="test"
    pnpm exec jest --testPathIgnorePatterns=__tests__/modules/client/*

    # Install
    pnpm install

    # Generate licenses
    . "${env:RECIPE_DIR}/helpers/js_build.ps1"
    Third-Party-Licenses "$env:SRC_DIR/$main_package"
    Copy-Item -Path "LICENSE" "$env:SRC_DIR/LICENSE"

    # Pack and install
    pnpm pack
Pop-Location
