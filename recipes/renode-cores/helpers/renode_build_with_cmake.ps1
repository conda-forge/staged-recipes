$ErrorActionPreference = "Stop"

# Get logical processors count
$cpuCount = (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors

# Set environment variables (using robust expansion)
$SRC_DIR = & cmd.exe /c echo %SRC_DIR%
$PREFIX = & cmd.exe /c echo %PREFIX%
$PKG_NAME = & cmd.exe /c echo %PKG_NAME%

# Check for empty environment variables
if ([string]::IsNullOrEmpty($SRC_DIR)) { throw "SRC_DIR is empty" }
if ([string]::IsNullOrEmpty($PREFIX)) { throw "PREFIX is empty" }
if ([string]::IsNullOrEmpty($PKG_NAME)) { throw "PKG_NAME is empty" }

# Update CMakeLists.txt (using combined git commands)
New-Item -ItemType Directory -Path "$SRC_DIR/updates" -Force | Out-Null
git -C "$SRC_DIR/updates" clone "https://github.com/renode/renode-infrastructure.git" -q
git -C "$SRC_DIR/updates/renode-infrastructure" checkout 3fc2d5fe643068e595e875d9408cb4329522b229 -q
Copy-Item -Path "$SRC_DIR/updates/renode-infrastructure/src/Emulator/Cores/CMakeLists.txt" -Destination "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/CMakeLists.txt" -Force

git -C "$SRC_DIR/updates" clone "https://github.com/antmicro/tlib.git" -q
git -C "$SRC_DIR/updates/tlib" checkout 69fff75a0eba7471283b0b8db2e55e8388e284f6 -q
Copy-Item -Path "$SRC_DIR/updates/tlib/CMakeLists.txt" -Destination "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/tlib" -Force
Copy-Item -Path "$SRC_DIR/updates/tlib/tcg/CMakeLists.txt" -Destination "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/tlib/tcg" -Force
Copy-Item -Path "$SRC_DIR/updates/tlib/LICENSE" -Destination "$Env:RECIPE_DIR/tlib-LICENSE" -Force

Copy-Item "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/tlib/softfloat-3/COPYING.txt" "$Env:RECIPE_DIR/softfloat-3-COPYING.txt" -Force

# Check weak implementations (using combined path)
& bash.exe -c ". '$SRC_DIR/tools/building/check_weak_implementations.sh'"

$env:PATH = "${env:BUILD_PREFIX}/Library/mingw-w64/bin;${env:BUILD_PREFIX}/Library/bin;${env:PREFIX}/Library/bin;${env:PREFIX}/bin;${env:PATH}"
$env:CXXFLAGS = "-Wno-unused-function -Wno-maybe-uninitialized"

$CMAKE = (Get-Command cmake).Source
$CORES_PATH = Join-Path $SRC_DIR "/src/Infrastructure/src/Emulator/Cores"
$CORES = @("arm.le", "arm.be", "arm64.le", "arm-m.le", "arm-m.be", "ppc.le", "ppc.be", "ppc64.le", "ppc64.be", "i386.le", "x86_64.le", "riscv.le", "riscv64.le", "sparc.le", "sparc.be", "xtensa.le")

New-Item -ItemType Directory -Path "$CORES_PATH/bin/Release/lib" -Force | Out-Null
foreach ($core_config in $CORES) {
    Write-Host "Building $core_config"

    $CORE = $core_config.Split('.')[0]
    $ENDIAN = $core_config.Split('.')[1]
    $BITS = if ($CORE -match "64") { 64 } else { 32 }

    # Construct CMake arguments dynamically
    $cmakeArgs = @(
        "-GNinja",
        "-DTARGET_ARCH=$CORE",
        "-DTARGET_WORD_SIZE=$BITS",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DHOST_ARCH=i386",
        "-DCMAKE_VERBOSE_MAKEFILE=ON",
        $CORES_PATH
    )
    if ($ENDIAN -eq "be") { $cmakeArgs += "-DTARGET_BIG_ENDIAN=1" }

    # Build and install (combined paths and commands)
    $buildDir = "$CORES_PATH/obj/Release/$CORE/$ENDIAN"
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
    Push-Location $buildDir
        & $CMAKE @cmakeArgs
        & $CMAKE --build . -j $cpuCount
        Copy-Item "tlib/*.so" "$CORES_PATH/bin/Release/lib" -Force -Verbose
    Pop-Location
}

# Install to conda path (combined path and robocopy)
$CORES_BIN_PATH = "$CORES_PATH/bin/Release"
New-Item -ItemType Directory -Path "$PREFIX/Library/lib/$PKG_NAME" -Force | Out-Null
icacls "$PREFIX/Library/lib/$PKG_NAME" /grant Users:(OI)(CI)F /T
robocopy "$CORES_BIN_PATH/lib" "$PREFIX/Library/lib/$PKG_NAME" /E /COPY:DATSO

exit 0
