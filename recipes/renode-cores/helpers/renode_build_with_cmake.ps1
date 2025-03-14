$ErrorActionPreference = "Stop"

$cpuCount = (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors

$env:PATH = "${env:BUILD_PREFIX}/Library/mingw-w64/bin;${env:BUILD_PREFIX}/Library/bin;${env:PREFIX}/Library/bin;${env:PREFIX}/bin;${env:PATH}"
$env:CXXFLAGS = "-Wno-unused-function -Wno-maybe-uninitialized"

$CMAKE = (Get-Command cmake).Source

$CORES_PATH = Join-Path -Path $env:SRC_DIR -ChildPath "src\Infrastructure\src\Emulator\Cores"

Push-Location "$env:SRC_DIR\tools\building"
    bash .\check_weak_implementations.sh
Pop-Location

$CORES_BUILD_PATH = Join-Path -Path $CORES_PATH -ChildPath "obj\Release"
$CORES_BIN_PATH = Join-Path -Path $CORES_PATH -ChildPath "bin\Release"

$CORES = @("arm.le", "arm.be", "arm64.le", "arm-m.le", "arm-m.be", "ppc.le", "ppc.be", "ppc64.le", "ppc64.be", "i386.le", "x86_64.le", "riscv.le", "riscv64.le", "sparc.le", "sparc.be", "xtensa.le")

# function Update-CMakeLists {
#     param (
#         [string]$filePath,
#         [string]$flagToRemove,
#         [string]$flagToAdd
#     )
#     (gc $filePath) -replace $flagToRemove,$flagToAdd | sc $filePath
# }

# Update-CMakeLists "$CORES_PATH\tlib\CMakeLists.txt" "-fPIC" "-Wno-unused-function -Wno-maybe-uninitialized"
# Update-CMakeLists "$CORES_PATH\tlib\tcg\CMakeLists.txt" "-fPIC" "-Wno-unused-function -Wno-maybe-uninitialized"

foreach ($core_config in $CORES) {
    Write-Host "Building $core_config"

    $CORE = $core_config.Split('.')[0]
    $ENDIAN = $core_config.Split('.')[1]
    $BITS = if ($CORE -match "64") { 64 } else { 32 }

    $CMAKE_CONF_FLAGS = @(
        "-DTARGET_ARCH=$CORE"
        "-DTARGET_WORD_SIZE=$BITS"
        "-DCMAKE_BUILD_TYPE=Release"
    )

    $CORE_DIR = Join-Path -Path $CORES_BUILD_PATH -ChildPath "$CORE\$ENDIAN"
    New-Item -ItemType Directory -Path $CORE_DIR -Force | Out-Null
    Push-Location $CORE_DIR
        if ($ENDIAN -eq "be") {
            $CMAKE_CONF_FLAGS += @("-DTARGET_BIG_ENDIAN=1")
        }

        & $CMAKE -GNinja @CMAKE_CONF_FLAGS -DHOST_ARCH="i386" $CORES_PATH -DCMAKE_VERBOSE_MAKEFILE=ON
        & $CMAKE --build . -j $cpuCount

        $CORE_BIN_DIR = Join-Path -Path $CORES_BIN_PATH -ChildPath "lib"
        New-Item -ItemType Directory -Path $CORE_BIN_DIR -Force | Out-Null
        Copy-Item -Path "tlib\*.so" -Destination $CORE_BIN_DIR -Force -Verbose
    Pop-Location
}

exit 0