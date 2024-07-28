# --- Function definitions ---

function analyze_dependencies {
    param (
        [string]$package_json_path
    )

    if (-Not (Test-Path -Path $package_json_path)) {
        Write-Error "Error: $package_json_path does not exist."
        exit 1
    }

    $dep = (jq -r '.dependencies // {} | keys[]' $package_json_path) -split "`n"
    $dev = (jq -r '.devDependencies // {} | keys[]' $package_json_path) -split "`n"

    $global:dependencies = @($dep)
    $global:devDependencies = @($dev)
}

function reference_conda_packages {
    param (
        [string]$main_pkg,
        [string[]]$pkgs
    )

    $licenses_filter = "["
    $install_filter = @()

    Push-Location "${env:BUILD_PREFIX}/lib/node_modules"
    tar -cf - . | (cd "${env:SRC_DIR}" && tar -xf -)
    Pop-Location

    Push-Location "${env:PREFIX}/lib/node_modules"
    tar -cf - . | (cd "${env:SRC_DIR}" && tar -xf -)
    Pop-Location

    foreach ($pkg in $pkgs) {
        New-Item -ItemType Directory -Path "${env:SRC_DIR}/_conda-logs" -Force

        $rpath = ".." # Default relative path
        for ($i = 0; $i -lt $main_pkg.Length; $i++) {
            if ($main_pkg[$i] -eq "/") {
                $rpath = "$rpath/.."
            }
        }

        if ($global:dependencies -contains $pkg) {
            Push-Location "${env:SRC_DIR}/$main_pkg"
            pnpm install --save "$pkg@file:$rpath/$pkg" > "${env:SRC_DIR}/_conda-logs/dep.log" 2>&1
            Pop-Location
        } elseif ($global:devDependencies -contains $pkg) {
            Push-Location "${env:SRC_DIR}/$main_pkg"
            pnpm install --save-dev "$pkg@file:$rpath/$pkg" > "${env:SRC_DIR}/_conda-logs/dev.log" 2>&1
            Pop-Location
        } else {
            Write-Error "$pkg is not found in dependencies or devDependencies"
        }

        $licenses_filter += "`"!$pkg`","
        $install_filter += "--filter !$pkg"
    }

    $licenses_filter = $licenses_filter.TrimEnd(",") + "]"
    $global:licenses_filter_conda_pkgs = $licenses_filter
    $global:install_filter_conda_pkgs = $install_filter
}

function replace_null_versions {
    param (
        [string]$file_path,
        [string]$new_version
    )

    # Read JSON file
    $json_content = Get-Content -Path $file_path -Raw

    # Replace null values in versions
    $modified_json = $json_content | jq --arg new_version $new_version '
        (.. | objects | select(has("versions")) | .versions) |= map(if . == null then $new_version else . end)
    '

    # Write JSON file
    $modified_json | Set-Content -Path $file_path
}

function third_party_licenses {
    param (
        [string]$main_pkg
    )

    Push-Location $main_pkg
    New-Item -ItemType Directory -Path "${env:SRC_DIR}/_conda-logs" -Force

    pnpm licenses list --prod --json > "${env:SRC_DIR}/_conda-licenses.json"
    replace_null_versions "${env:SRC_DIR}/_conda-licenses.json" "0.0.0" > "${env:SRC_DIR}/_conda-logs/replace_null.log" 2>&1
    pnpm-licenses generate-disclaimer `
        --prod `
        --filter="$global:licenses_filter_conda_pkgs" `
        --json-input `
        --output-file="${env:SRC_DIR}/ThirdPartyLicenses.txt" < "${env:SRC_DIR}/_conda-licenses.json" > "${env:SRC_DIR}/_conda-logs/licenses.log" 2>&1
    Pop-Location
}