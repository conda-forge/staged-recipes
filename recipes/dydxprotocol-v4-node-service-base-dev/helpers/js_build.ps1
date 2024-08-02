# --- Function definitions ---

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
        --json-input `
        --output-file="${env:SRC_DIR}/ThirdPartyLicenses.txt" < "${env:SRC_DIR}/_conda-licenses.json" > "${env:SRC_DIR}/_conda-logs/licenses.log" 2>&1
    Pop-Location
}