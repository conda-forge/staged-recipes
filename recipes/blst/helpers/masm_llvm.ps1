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
        $content = Get-Content $InputFile

        $rules = @{
            'OPTION\s+DOTNAME' = ''
            '\s+PROC\s+PRIVATE' = ':'
            '::' = ':'
            'ENDP' = ''
            'imagerel\s+(\w+)' = 'rel $1'
            '\$L\$' = '.L'
        }

        foreach ($rule in $rules.GetEnumerator()) {
            $content = $content -replace $rule.Key, $rule.Value
        }

        Write-Host "Converted content to be written to ${OutputFile}:`n${content}"
        $content | Set-Content $OutputFile

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