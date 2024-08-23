# Directory containing .asm files
param (
    [string]$ASM_DIR = "build/win64",
    [string]$OUTPUT_DIR = "build/win64_nasm"
)

# Function to convert MASM to NASM syntax
function Convert-MasmToNasm {
    param (
        [string]$InputFile,
        [string]$OutputFile
    )

    Get-Content $InputFile | ForEach-Object {
        $_ -replace '\.code', 'section .text' `
           -replace '\.data', 'section .data' `
           -replace 'PUBLIC', 'global' `
           -replace 'PROC', ':' `
           -replace 'ENDP', '' `
           -replace 'DWORD', 'dd' `
           -replace 'PTR', '' `
           -replace 'ifdef', '%ifdef' `
           -replace 'endif', '%endif'
    } | Set-Content $OutputFile
}

# Convert and compile each .asm file
Get-ChildItem "$ASM_DIR\*.asm" | ForEach-Object {
    $BaseName = $_.BaseName
    $NasmFile = "$OUTPUT_DIR\$BaseName.nasm"
    $ObjFile = "$BaseName.o"

    # Convert MASM to NASM
    Convert-MasmToNasm -InputFile $_.FullName -OutputFile $NasmFile
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
