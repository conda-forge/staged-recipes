param (
    [string]$framework_version
)

$SRC_DIR = Resolve-Path "$Env:SRC_DIR"

$OUTPUT_DIRECTORY = "$SRC_DIR\output"
$CONFIGURATION = "Release"
$BUILD_PLATFORM = "Any CPU"
$HEADLESS = $true
$NET = $true
$TFM = "net$framework_version-windows"
$HOST_ARCH = "i386"
$CMAKE_COMMON = ""

$PARAMS = @()
if ($Env:CC) {
    $PARAMS += "/p:CompilerPath=$Env:CC"
    $PARAMS += "/p:LinkerPath=$Env:CC"
}
if ($Env:AR) {
    $PARAMS += "/p:ArPath=$Env:AR"
}
$PARAMS += $args

if ($HEADLESS) {
    $BUILD_TARGET = "Headless"
    $PARAMS += "/p:GUI_DISABLED=true"
}

$DirectoryBuildTargetsContent = @"
<Project>
  <PropertyGroup>
    <TargetFrameworks>$TFM</TargetFrameworks>
    ${Env:OS_SPECIFIC_TARGET_OPTS}
  </PropertyGroup>
</Project>
"@

$DirectoryBuildTargetsPath = "$SRC_DIR\Directory.Build.targets"
Set-Content -Path $DirectoryBuildTargetsPath -Value $DirectoryBuildTargetsContent

$Env:DOTNET_CLI_TELEMETRY_OPTOUT = 1
$CS_COMPILER = "dotnet build /m"
$TARGET = "$SRC_DIR\Renode_NET.sln"
$BUILD_TYPE = "dotnet"

$OUT_BIN_DIR = "$SRC_DIR\output\bin\$CONFIGURATION"
$BUILD_TYPE_FILE = "$OUT_BIN_DIR\build_type"

# Copy properties file according to the running OS
New-Item -ItemType Directory -Force -Path $OUT_BIN_DIR
New-Item -ItemType Directory -Force -Path $OUTPUT_DIRECTORY
# Remove-Item -Force -Path "$OUTPUT_DIRECTORY\properties.csproj"
$PROP_FILE = "$SRC_DIR\src\Infrastructure\src\Emulator\Cores\windows-properties_NET.csproj"
Copy-Item -Path $PROP_FILE -Destination "$OUTPUT_DIRECTORY\properties.csproj"

$CORES_PATH = "$SRC_DIR\src\Infrastructure\src\Emulator\Cores"

$PARAMS += "/p:Configuration=${CONFIGURATION}${BUILD_TARGET}"
$PARAMS += "/p:GenerateFullPaths=true"
$PARAMS += "/p:Platform=`"$BUILD_PLATFORM`""

# build
Invoke-Expression "$CS_COMPILER @PARAMS $TARGET"
Set-Content -Path $BUILD_TYPE_FILE -Value $BUILD_TYPE

# copy llvm library
$LLVM_LIB = "libllvm-disas"
$LIB_EXT = "dll"
Copy-Item -Path "$SRC_DIR\lib\resources\llvm\$LLVM_LIB.$LIB_EXT" -Destination "$OUT_BIN_DIR\libllvm-disas.$LIB_EXT"
