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

    try {
        Write-Host "Reading content from $InputFile"
        $content = Get-Content $InputFile
        Write-Host "Content of ${InputFile}"

        $convertedContent = "%use masm`n" + $content

        Write-Host "Converted content to be written to ${OutputFile}"
        $convertedContent | Set-Content $OutputFile

        Write-Host "Successfully converted $InputFile to $OutputFile"
    } catch {
        Write-Host "Error converting $InputFile to $OutputFile"
        Write-Host "Error details: $_"
    }
}

# Convert each .asm file
$asmFiles = Get-ChildItem "$ASM_DIR\*.asm"
Write-Host "Found $($asmFiles.Count) .asm files to convert."

$asmFiles | ForEach-Object {
    $BaseName = $_.BaseName
    $NasmFile = "$OUTPUT_DIR\$BaseName.asm"

    # Convert MASM to NASM
    try {
        Convert-MasmToNasm -InputFile $_.FullName -OutputFile $NasmFile
    } catch {
        Write-Host "Error converting $_ to $NasmFile"
        Write-Host "Error details: $_"
    }
}