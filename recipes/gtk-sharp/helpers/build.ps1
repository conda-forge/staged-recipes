function Write-EnvironmentInfo {
    Write-Host "==== Environment Information ====" -ForegroundColor Cyan
    Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-Host "Current Directory: $(Get-Location)"
    Write-Host "SRC_DIR: $env:SRC_DIR"
    Write-Host "BUILD_PREFIX: $env:BUILD_PREFIX"
    Write-Host "PATH: $env:PATH"

    Write-Host "`n==== Directory Contents ====" -ForegroundColor Cyan
    Get-ChildItem -Path $env:SRC_DIR | Format-Table Name, LastWriteTime, Length -AutoSize
}

function Invoke-CommandWithLogging {
    param([string]$Command)
    Write-Host "Executing: $Command" -ForegroundColor Yellow
    try {
        $output = Invoke-Expression $Command -ErrorVariable cmdError 2>&1
        $output | Tee-Object -Append -FilePath "$env:SRC_DIR\build_qemu_detailed.log" | ForEach-Object { Write-Host $_ }
        if ($LASTEXITCODE -ne 0) {
            if ($cmdError) {
                Write-Host "Command error details: $cmdError" -ForegroundColor Red
            }
            throw "Command failed with exit code >$LASTEXITCODE<"
        }
    } catch {
        Write-Host "Error executing command: $_" -ForegroundColor Red
        throw
    }
}

$env:PKG_CONFIG_PATH = "${env:PREFIX}/lib/pkgconfig;${env:PREFIX}/share/pkgconfig;${env:BUILD_PREFIX}/lib/pkgconfig"

# Split off last part of the version string
$_pkg_version = $env:PKG_VERSION -replace "\.[^.]+$", ""

Invoke-CommandWithLogging "ls -l bootstrap-$_pkg_version"
Invoke-CommandWithLogging "bash -c 'ls -l bootstrap-$_pkg_version'"

Invoke-CommandWithLogging "bash -c 'bootstrap-$_pkg_version --prefix=$env:PREFIX'"

Invoke-CommandWithLogging "bash -c 'configure --prefix=$env:PREFIX --disable-static'"
Invoke-CommandWithLogging "makw"
Invoke-CommandWithLogging "make install"
