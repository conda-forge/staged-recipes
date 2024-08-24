# Directory containing .asm files
param (
    [string]$ASM_DIR = "build/win64",
    [string]$OUTPUT_DIR = "build/win64_nasm"
)

# Ensure the output directory exists
if (-Not (Test-Path -Path $OUTPUT_DIR)) {
    New-Item -ItemType Directory -Path $OUTPUT_DIR
}

# Function to convert MASM to NASM syntax
function Convert-MasmToNasm {
    param (
        [string]$InputFile,
        [string]$OutputFile
    )

     Write-Host "Reading content from $InputFile"
    $content = Get-Content $InputFile
    Write-Host "Content of ${InputFile}:`n${content}"

    $convertedContent = $content | ForEach-Object {
        $_ -replace '\.code', 'section .text' `
           -replace '\.data', 'section .data' `
           -replace 'PUBLIC', 'global' `
           -replace 'PROC', ':' `
           -replace 'ENDP', '' `
           -replace 'DWORD', 'dd' `
           -replace 'PTR', '' `
           -replace 'ifdef', '%ifdef' `
           -replace 'endif', '%endif'
    }

    Write-Host "Converted content to be written to ${OutputFile}:`n${convertedContent}"
    $convertedContent | Set-Content $OutputFile

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully converted $InputFile to $OutputFile"
    } else {
        Write-Host "Failed to convert $InputFile to $OutputFile"
    }
}

# Convert and compile each .asm file
Get-ChildItem "$ASM_DIR\*.asm" | ForEach-Object {
    $BaseName = $_.BaseName
    $NasmFile = "$OUTPUT_DIR\$BaseName.asm"

    # Convert MASM to NASM
    Convert-MasmToNasm -InputFile $_.FullName -OutputFile $NasmFile
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
