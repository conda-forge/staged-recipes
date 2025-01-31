$ErrorActionPreference = "Stop"

$cpuCount = (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors

$env:PATH = "${env:BUILD_PREFIX}/Library/mingw-w64/bin;${env:BUILD_PREFIX}/Library/bin;${env:PREFIX}/Library/bin;${env:PREFIX}/bin;${env:PATH}"
$env:SRC_DIR = $env:SRC_DIR

$CMAKE = (Get-Command cmake).Source

$CONFIGURATION = "Release"
$HOST_ARCH = "i386"
$CMAKE_COMMON = ""

$CORES_PATH = Join-Path -Path $env:SRC_DIR -ChildPath "src\Infrastructure\src\Emulator\Cores"

Push-Location "$env:SRC_DIR\tools\building"
    bash .\check_weak_implementations.sh
Pop-Location

$CORES_BUILD_PATH = Join-Path -Path $CORES_PATH -ChildPath "obj\$CONFIGURATION"
$CORES_BIN_PATH = Join-Path -Path $CORES_PATH -ChildPath "bin\$CONFIGURATION"

$CMAKE_GEN = "-GNinja"

$CORES = @("arm.le", "arm.be", "arm64.le", "arm-m.le", "arm-m.be", "ppc.le", "ppc.be", "ppc64.le", "ppc64.be", "i386.le", "x86_64.le", "riscv.le", "riscv64.le", "sparc.le", "sparc.be", "xtensa.le")

function Update-CMakeLists {
    param (
        [string]$filePath,
        [string]$flagToRemove,
        [string]$flagToAdd
    )
    (gc $filePath) -replace $flagToRemove,$flagToAdd | sc $filePath
}

Update-CMakeLists "$CORES_PATH\tlib\CMakeLists.txt" "-fPIC" "-Wno-unused-function -Wno-maybe-uninitialized"
Update-CMakeLists "$CORES_PATH\tlib\tcg\CMakeLists.txt" "-fPIC" "-Wno-unused-function -Wno-maybe-uninitialized"

foreach ($core_config in $CORES) {
    Write-Host "Building $core_config"

    $CORE = $core_config.Split('.')[0]
    $ENDIAN = $core_config.Split('.')[1]
    $BITS = if ($CORE -match "64") { 64 } else { 32 }

    $CMAKE_CONF_FLAGS = @(
        "-DTARGET_ARCH=$CORE"
        "-DTARGET_WORD_SIZE=$BITS"
        "-DCMAKE_BUILD_TYPE=$CONFIGURATION"
    )

    $CORE_DIR = Join-Path -Path $CORES_BUILD_PATH -ChildPath "$CORE\$ENDIAN"
    New-Item -ItemType Directory -Path $CORE_DIR -Force | Out-Null
    Push-Location $CORE_DIR
        if ($ENDIAN -eq "be") {
            $CMAKE_CONF_FLAGS += @("-DTARGET_BIG_ENDIAN=1")
        }

        & $CMAKE $CMAKE_GEN $CMAKE_COMMON @CMAKE_CONF_FLAGS -DHOST_ARCH="$HOST_ARCH" $CORES_PATH -DCMAKE_VERBOSE_MAKEFILE=ON
        & $CMAKE --build . -j $cpuCount

        $CORE_BIN_DIR = Join-Path -Path $CORES_BIN_PATH -ChildPath "lib"
        New-Item -ItemType Directory -Path $CORE_BIN_DIR -Force | Out-Null
        Copy-Item -Path "tlib\*.so" -Destination $CORE_BIN_DIR -Force -Verbose
    Pop-Location
}

exit 0