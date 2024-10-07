param (
    [string]$predefs
)

# Initialize cflags
$cflags = ""

# Check if predefs contains x86_64
if ($predefs -match 'x86_64') {
    # Check for adx flag in CPU information
    $cpuInfo = Get-WmiObject -Class Win32_Processor
    if ($cpuInfo | Select-String -Pattern 'adx') {
        $cflags = "-D__ADX__ $cflags"
    }
}

# Check if predefs contains __AVX__
if ($predefs -match '__AVX__') {
    $cflags = "$cflags -mno-avx" # avoid costly transitions
}

# Check if predefs contains x86_64 or aarch64
if ($predefs -notmatch 'x86_64|aarch64') {
    $cflags = "$cflags -D__BLST_NO_ASM__"
}

# Output the updated cflags
Write-Output $cflags
