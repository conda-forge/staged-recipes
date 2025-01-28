$ErrorActionPreference = "Stop"

$env:PATH = "${env:BUILD_PREFIX}/Library/mingw-w64/bin;${env:BUILD_PREFIX}/Library/bin;${env:PREFIX}/Library/bin;${env:PREFIX}/bin;${env:PATH}"
$env:ROOT_PATH = $env:SRC_DIR

$CMAKE = (Get-Command cmake).Source

$OUTPUT_DIRECTORY = "$env:ROOT_PATH/output"
$EXPORT_DIRECTORY = ""

$UPDATE_SUBMODULES = $false
$CONFIGURATION = "Release"
$BUILD_PLATFORM = "Any CPU"
$CLEAN = $false
$PACKAGES = $false
$NIGHTLY = $false
$PORTABLE = $false
$HEADLESS = $false
$SKIP_FETCH = $false
$TLIB_ONLY = $false
$TLIB_EXPORT_COMPILE_COMMANDS = $false
$TLIB_ARCH = ""
$NET = $false
$TFM = "net8.0"
$GENERATE_DOTNET_BUILD_TARGET = $true
$PARAMS = @()
$CUSTOM_PROP = $null
$NET_FRAMEWORK_VER = $null
$RID = "linux-x64"
$HOST_ARCH = "i386"
$CMAKE_COMMON = ""

function print_help {
    Write-Host "Usage: $0 [-cdvspnt] [-b properties-file.csproj] [--no-gui] [--skip-fetch] [--profile-build] [--tlib-only] [--tlib-export-compile-commands] [--tlib-arch <arch>] [--host-arch i386|aarch64] [-- <ARGS>]"
    Write-Host
    Write-Host "-v                                verbose output"
    Write-Host "--no-gui                          build with GUI disabled"
    Write-Host "--force-net-framework-version     build against different version of .NET Framework than specified in the solution"
    Write-Host "--net                             build with dotnet"
    Write-Host "-F                                select the target framework for which Renode should be built (default value: $TFM)"
    Write-Host "--profile-build                   build optimized for profiling"
    Write-Host "--tlib-only                       only build tlib"
    Write-Host "<ARGS>                            arguments to pass to the build system"
}

$opts = Get-CommandLineArgs
while ($opts.Count -gt 0) {
    $opt = $opts[0]
    switch -regex ($opt) {
        "-v" {
            $PARAMS += "verbosity:detailed"
            $opts = $opts[1..$($opts.Count - 1)]
        }
        "--no-gui" {
            $HEADLESS = $true
            $opts = $opts[1..$($opts.Count - 1)]
        }
        "--force-net-framework-version" {
            $NET_FRAMEWORK_VER = "p:TargetFrameworkVersion=v$($opts[1])"
            $PARAMS += $NET_FRAMEWORK_VER
            $opts = $opts[2..$($opts.Count - 1)]
        }
        "--net" {
            $NET = $true
            $PARAMS += "p:NET=true"
            $opts = $opts[1..$($opts.Count - 1)]
        }
        "--tlib-only" {
            $TLIB_ONLY = $true
            $opts = $opts[1..$($opts.Count - 1)]
        }
        default {
            print_help
            exit 1
        }
    }
}

$PARAMS += @(
    ${env:CC} ? "p:CompilerPath=$env:CC" : $null,
    ${env:CC} ? "p:LinkerPath=$env:CC" : $null,
    ${env:AR} ? "p:ArPath=$env:AR" : $null
) + $opts

if ($env:PLATFORM) {
    Write-Host "PLATFORM environment variable is currently set to: >>$env:PLATFORM<<"
    Write-Host "This might cause problems during the build."
    Write-Host "Please clear it with:"
    Write-Host
    Write-Host "    unset PLATFORM"
    Write-Host
    Write-Host " and run the build script again."
    exit 1
}

if (-not (Test-Path .git)) {
    $SKIP_FETCH = $true
    $UPDATE_SUBMODULES = $false
}

if ($SKIP_FETCH) {
    Write-Host "Skipping init/update of submodules"
}

. "${env:ROOT_PATH}/tools/common.ps1"

if ($SKIP_FETCH) {
    Write-Host "Skipping library fetch"
}

if ($HEADLESS) {
    $BUILD_TARGET = "Headless"
    $PARAMS += "p:GUI_DISABLED=true"
}

if ($GENERATE_DOTNET_BUILD_TARGET) {
    if ($env:ON_WINDOWS) {
        $OS_SPECIFIC_TARGET_OPTS = '<CsWinRTAotOptimizerEnabled>false</CsWinRTAotOptimizerEnabled>'
    }
}

$OUT_BIN_DIR = Join-Path -Path "output/bin" -ChildPath $CONFIGURATION
$BUILD_TYPE_FILE = Join-Path -Path $OUT_BIN_DIR -ChildPath "build_type"

$CORES_PATH = Join-Path -Path $env:ROOT_PATH -ChildPath "src/Infrastructure/src/Emulator/Cores"

Push-Location "$env:ROOT_PATH/tools/building"
./check_weak_implementations.ps1
Pop-Location

$PARAMS += "p:Configuration=${CONFIGURATION}${BUILD_TARGET}" "p:GenerateFullPaths=true" "p:Platform=`"$BUILD_PLATFORM`""

$CORES_BUILD_PATH = Join-Path -Path $CORES_PATH -ChildPath "obj/$CONFIGURATION"
$CORES_BIN_PATH = Join-Path -Path $CORES_PATH -ChildPath "bin/$CONFIGURATION"

$CMAKE_GEN = "-GNinja"

$CORES = @("arm.le", "arm.be", "arm64.le", "arm-m.le", "arm-m.be", "ppc.le", "ppc.be", "ppc64.le", "ppc64.be", "i386.le", "x86_64.le", "riscv.le", "riscv64.le", "sparc.le", "sparc.be", "xtensa.le")

foreach ($core_config in $CORES) {
    Write-Host "Building $core_config"
    $CORE = $core_config.Split('.')[0]
    $ENDIAN = $core_config.Split('.')[1]
    $BITS = if ($CORE -match "64") { 64 } else { 32 }
    $CMAKE_CONF_FLAGS = "-DTARGET_ARCH=$CORE -DTARGET_WORD_SIZE=$BITS -DCMAKE_BUILD_TYPE=$CONFIGURATION"
    $CORE_DIR = Join-Path -Path $CORES_BUILD_PATH -ChildPath "$CORE/$ENDIAN"
    New-Item -ItemType Directory -Path $CORE_DIR -Force | Out-Null
    Push-Location $CORE_DIR
    if ($ENDIAN -eq "be") {
        $CMAKE_CONF_FLAGS += " -DTARGET_BIG_ENDIAN=1"
    }
    if ($TLIB_EXPORT_COMPILE_COMMANDS) {
        $CMAKE_CONF_FLAGS += " -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
    }
    & $CMAKE $CMAKE_GEN $CMAKE_COMMON $CMAKE_CONF_FLAGS -DHOST_ARCH=$HOST_ARCH $CORES_PATH
    & $CMAKE --build . -j (Get-ProcessorCount)
    $CORE_BIN_DIR = Join-Path -Path $CORES_BIN_PATH -ChildPath "lib"
    New-Item -ItemType Directory -Path $CORE_BIN_DIR -Force | Out-Null
    if ($env:ON_OSX) {
        Copy-Item -Path "tlib/*.so" -Destination $CORE_BIN_DIR -Verbose
    } else {
        Copy-Item -Path "tlib/*.so" -Destination $CORE_BIN_DIR -Force -Verbose
    }
    if ($TLIB_EXPORT_COMPILE_COMMANDS) {
        Copy-Item -Path "$CORE_DIR/compile_commands.json" -Destination "$CORES_PATH/tlib/" -Force -Verbose
    }
    Pop-Location
}

exit 0