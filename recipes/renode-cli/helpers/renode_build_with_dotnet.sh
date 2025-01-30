#!/usr/bin/env bash

set -uex

framework_version=$1
shift 1

OUTPUT_DIRECTORY="${SRC_DIR}/output"

CONFIGURATION="Release"
BUILD_PLATFORM="Any CPU"
HEADLESS=true
NET=true
TFM="net${framework_version}"
GENERATE_DOTNET_BUILD_TARGET=true
NET_FRAMEWORK_VER=
RID="linux-x64"
HOST_ARCH="i386"
# Common cmake flags
CMAKE_COMMON=""

PARAMS=(
  # By default use CC as Compiler- and LinkerPath, and AR as ArPath
  ${CC:+"p:CompilerPath=$CC"}
  ${CC:+"p:LinkerPath=$CC"}
  ${AR:+"p:ArPath=$AR"}
  # But allow users to override it
  "$@"
)

if $HEADLESS
then
    BUILD_TARGET=Headless
    PARAMS+=(p:GUI_DISABLED=true)
else
    BUILD_TARGET=Mono
fi

cat <<EOF > "${SRC_DIR}/Directory.Build.targets"
<Project>
  <PropertyGroup>
    <TargetFrameworks>$TFM</TargetFrameworks>
    ${OS_SPECIFIC_TARGET_OPTS:+${OS_SPECIFIC_TARGET_OPTS}}
  </PropertyGroup>
</Project>
EOF

export DOTNET_CLI_TELEMETRY_OPTOUT=1
CS_COMPILER="dotnet build"
TARGET="${SRC_DIR}/Renode_NET.sln"
BUILD_TYPE="dotnet"

OUT_BIN_DIR="${SRC_DIR}/output/bin/${CONFIGURATION}"
BUILD_TYPE_FILE="${OUT_BIN_DIR}/build_type"

# Copy properties file according to the running OS
mkdir -p "$OUTPUT_DIRECTORY"
rm -f "$OUTPUT_DIRECTORY/properties.csproj"
if [[ "${target_platform}" == "osx-"* ]]; then
  PROP_FILE="${CURRENT_PATH:=.}/src/Infrastructure/src/Emulator/Cores/osx-properties.csproj"
elif [[ "${target_platform}" == "linux-"* ]] || [[ "${target_platform}" == "noarch" ]]; then
  PROP_FILE="${CURRENT_PATH:=.}/src/Infrastructure/src/Emulator/Cores/linux-properties.csproj"
else
  PROP_FILE="${CURRENT_PATH:=.}/src/Infrastructure/src/Emulator/Cores/windows-properties.csproj"
fi
cp "$PROP_FILE" "$OUTPUT_DIRECTORY/properties.csproj"

CORES_PATH="${SRC_DIR}/src/Infrastructure/src/Emulator/Cores"

PARAMS+=(p:Configuration=${CONFIGURATION}${BUILD_TARGET} p:GenerateFullPaths=true p:Platform="\"$BUILD_PLATFORM\"")

# build
function build_args_helper() {
    local retStr=""
    for p in "$@" ; do
        if [ "$CS_COMPILER" = 'xbuild' ] ; then
            retStr="${retStr} /$p"
        else
            retStr="${retStr} -$p"
        fi
    done
    echo ${retStr}
}

eval "$CS_COMPILER $(build_args_helper "${PARAMS[@]}") $TARGET"
echo -n "$BUILD_TYPE" > "$BUILD_TYPE_FILE"

# copy llvm library
LLVM_LIB="libllvm-disas"
if [[ $HOST_ARCH == "aarch64" ]]; then
  # aarch64 host binaries have a different name
  LLVM_LIB="libllvm-disas-aarch64"
fi
if [[ "${target_platform}" == "linux-"* ]] || [[ "${target_platform}" == "noarch" ]]; then
  LIB_EXT="so"
elif [[ "${target_platform}" == "osx-"* ]]; then
  LIB_EXT="dylib"
else
  LIB_EXT="dll"
fi
cp lib/resources/llvm/$LLVM_LIB.$LIB_EXT $OUT_BIN_DIR/libllvm-disas.$LIB_EXT
