# --- Function definitions ---

function Replace-Null-Versions {
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

function Third-Party-Licenses {
    param (
        [string]$main_pkg
    )

    Push-Location $main_pkg

    $jsonContent = pnpm licenses list --prod --json
    $jsonContent | Set-Content -Path "${env:SRC_DIR}/_conda-licenses.json"
    Replace-Null-Versions "${env:SRC_DIR}/_conda-licenses.json" "0.0.0"

    $jsonContent = Get-Content -Path "${env:SRC_DIR}/_conda-licenses.json" -Raw
    pnpm-licenses generate-disclaimer `
        --prod `
        --json-input `
        --output-file="${env:SRC_DIR}/ThirdPartyLicenses.txt" `
        --input-data=$jsonContent
    Pop-Location
}