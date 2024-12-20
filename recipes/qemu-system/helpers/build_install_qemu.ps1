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

function Build-Qemu {
    param (
        [string]$build_dir,
        [string]$install_dir,
        [string[]]$qemu_args
    )
    try {
        Write-Host "Building QEMU in $build_dir" -ForegroundColor Green
        New-Item -ItemType Directory -Force -Path $build_dir | Out-Null
        Push-Location $build_dir

        $env:PKG_CONFIG = "$env:BUILD_PREFIX/bin/pkg-config"
        $env:PKG_CONFIG_PATH = "$env:BUILD_PREFIX/lib/pkgconfig"
        $env:PKG_CONFIG_LIBDIR = "$env:BUILD_PREFIX/lib/pkgconfig"

        Write-Host "PKG_CONFIG: $env:PKG_CONFIG" -ForegroundColor Cyan
        Write-Host "PKG_CONFIG_PATH: $env:PKG_CONFIG_PATH" -ForegroundColor Cyan
        Write-Host "PKG_CONFIG_LIBDIR: $env:PKG_CONFIG_LIBDIR" -ForegroundColor Cyan
        Write-Host "SRC_DIR: $env:SRC_DIR"
        Write-Host "BUILD_PREFIX: $env:BUILD_PREFIX"
        Write-Host "PATH: $env:PATH"

        $unixPath = $env:SRC_DIR -replace '\\', '/'
        Invoke-CommandWithLogging "ls $unixPath/qemu-source/configure"
        Invoke-CommandWithLogging "bash -c $unixPath/qemu-source/configure --help"

        $configureArgs = @(
            "--prefix=$install_dir",
            $qemu_args,
            "--enable-system"
        )

        Invoke-CommandWithLogging "$env:SRC_DIR\qemu-source\configure $($configureArgs -join ' ')"

        Invoke-CommandWithLogging "make -j$env:CPU_COUNT"
        Invoke-CommandWithLogging "make check"
        Invoke-CommandWithLogging "make install"
    }
    catch {
        Write-Host "Error occurred during QEMU build: $_" -ForegroundColor Red
        throw
    }
    finally {
        Pop-Location
    }
}

# --- Main ---
try {
    Write-EnvironmentInfo
    $qemu_args = @("--target-list=aarch64-softmmu")
    Build-Qemu -build_dir "$env:SRC_DIR\_conda-build-win-64" -install_dir "$env:SRC_DIR\_conda-install-win-64" -qemu_args $qemu_args
    Write-Host "QEMU build completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "QEMU build failed: $_" -ForegroundColor Red
    exit 1
}
