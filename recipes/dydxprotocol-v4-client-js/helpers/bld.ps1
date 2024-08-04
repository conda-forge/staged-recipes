# --- Function definitions ---

function Reference-CondaPackages {
    param (
        [string]$mainPkg,
        [string[]]$pkgs
    )

    $filterStr = "["
    $installFilter = "--filter"
    foreach ($pkg in $pkgs) {
        # Simulating the installation environment so that the relative path works
        New-Item -ItemType SymbolicLink -Path "$env:PREFIX/lib/node_modules/$pkg" -Target "$env:SRC_DIR/$pkg"

        Push-Location "$env:SRC_DIR/$mainPkg"
            pnpm install --save-dev "$pkg@file:../$pkg"
        Pop-Location

        $filterStr += "`"!$pkg`", "
        $installFilter += " $pkg"
    }
    $filterStr = $filterStr.TrimEnd(", ") + "]"
    return @($filterStr, $installFilter)
}

function Replace-NullVersions {
    param (
        [string]$filePath,
        [string]$newVersion
    )

    # Read JSON file
    $jsonContent = Get-Content -Path $filePath -Raw

    # Replace null values in versions
    $modifiedJson = $jsonContent | jq --arg new_version $newVersion '
        (.. | objects | select(has("versions")) | .versions) |= map(if . == null then $new_version else . end)
    '

    # Write JSON file
    $modifiedJson | Set-Content -Path $filePath
}

# Set environment variables
$env:npm_config_build_from_source = $true
$env:npm_config_legacy_peer_deps = $true
$env:NPM_CONFIG_USERCONFIG = "/tmp/nonexistentrc"

# Define conda packages
$main_package="@dydxprotocol/v4-client-js"

# Navigate to directory and run commands
Push-Location "$env:SRC_DIR/$main_package"
    Remove-Item "package-lock.json" -Force

    # Build
    pnpm install
    Remove-Item -Recurse -Force build
    pnpm run compile
    # pnpm audit fix

    # Install
    pnpm install $installFilterCondaPkgs

    # Generate licenses
    pnpm licenses list --prod --json > %SRC_DIR%/_conda-licenses.json
    Replace-NullVersions -filePath %SRC_DIR%/_conda-licenses.json -newVersion "0.0.0"
    pnpm-licenses generate-disclaimer `
        --prod `
        --json-input `
        --output-file="$env:SRC_DIR/ThirdPartyLicenses.txt" > %SRC_DIR%/_conda-licenses.txt 2>&1
    Copy-Item -Path "LICENSE" "$env:SRC_DIR/LICENSE"

    # Pack and install
    pnpm pack

    New-Item -ItemType Directory -Path "$env:PREFIX\lib"
    Push-Location "$env:PREFIX\lib"
        Invoke-Expression "npm install --global $env:SRC_DIR\dydxprotocol-$main_package-$env:PKG_VERSION.tgz"
        if ($LASTEXITCODE -ne 0) {
            exit 1
        }
    Pop-Location
Pop-Location