param (
    [string]$framework_version
)

$OUTPUT_DIRECTORY = "${env:SRC_DIR}\output"
$CONFIGURATION = "Release"
$BUILD_PLATFORM = "Any CPU"
$HEADLESS = $true
$NET = $true
$TFM = "net$framework_version"
$HOST_ARCH = "i386"
$CMAKE_COMMON = ""

$PARAMS = @()
if ($env:CC) {
    $PARAMS += "p:CompilerPath=$env:CC"
    $PARAMS += "p:LinkerPath=$env:CC"
}
if ($env:AR) {
    $PARAMS += "p:ArPath=$env:AR"
}
$PARAMS += $args

if ($HEADLESS) {
    $BUILD_TARGET = "Headless"
    $PARAMS += "p:GUI_DISABLED=true"
} else {
    $BUILD_TARGET = "Mono"
}

$DirectoryBuildTargetsContent = @"
<Project>
  <PropertyGroup>
    <TargetFrameworks>$TFM</TargetFrameworks>
    ${env:OS_SPECIFIC_TARGET_OPTS}
  </PropertyGroup>
</Project>
"@

$DirectoryBuildTargetsPath = "${env:SRC_DIR}\Directory.Build.targets"
Set-Content -Path $DirectoryBuildTargetsPath -Value $DirectoryBuildTargetsContent

$env:DOTNET_CLI_TELEMETRY_OPTOUT = 1
$CS_COMPILER = "dotnet build"
$TARGET = "${env:SRC_DIR}\Renode_NET.sln"
$BUILD_TYPE = "dotnet"

$OUT_BIN_DIR = "${env:SRC_DIR}\output\bin\$CONFIGURATION"
$BUILD_TYPE_FILE = "$OUT_BIN_DIR\build_type"

# Copy properties file according to the running OS
New-Item -ItemType Directory -Force -Path $OUTPUT_DIRECTORY
# Remove-Item -Force -Path "$OUTPUT_DIRECTORY\properties.csproj"
$PROP_FILE = "${env:SRC_DIR}\src\Infrastructure\src\Emulator\Cores\windows-properties_NET.csproj"
Copy-Item -Path $PROP_FILE -Destination "$OUTPUT_DIRECTORY\properties.csproj"

$CORES_PATH = "${env:SRC_DIR}\src\Infrastructure\src\Emulator\Cores"

$PARAMS += "p:Configuration=${CONFIGURATION}${BUILD_TARGET}"
$PARAMS += "p:GenerateFullPaths=true"
$PARAMS += "p:Platform=`"$BUILD_PLATFORM`""

# build
function Build-Args-Helper {
    param (
        [string[]]$params
    )
    $retStr = ""
    foreach ($p in $params) {
        $retStr += " -$p"
    }
    return $retStr
}

Invoke-Expression "$CS_COMPILER $(Build-Args-Helper -params $PARAMS) $TARGET"
Set-Content -Path $BUILD_TYPE_FILE -Value $BUILD_TYPE

# copy llvm library
$LLVM_LIB = "libllvm-disas"
$LIB_EXT = "dll"
Copy-Item -Path "lib\resources\llvm\$LLVM_LIB.$LIB_EXT" -Destination "$OUT_BIN_DIR\libllvm-disas.$LIB_EXT"
