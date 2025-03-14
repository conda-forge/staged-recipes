#!/usr/bin/env bash

set -uex

framework_version=$1
shift 1

cat <<EOF > "${SRC_DIR}/Directory.Build.targets"
<Project>
  <PropertyGroup>
    <TargetFrameworks>net${framework_version}</TargetFrameworks>
    ${OS_SPECIFIC_TARGET_OPTS:+${OS_SPECIFIC_TARGET_OPTS}}
  </PropertyGroup>
</Project>
EOF

export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Copy properties file according to the running OS
OUTPUT_DIRECTORY="${SRC_DIR}/output"
mkdir -p "$OUTPUT_DIRECTORY"
rm -f "$OUTPUT_DIRECTORY/properties.csproj"
PROP_FILE="${CURRENT_PATH:=.}/src/Infrastructure/src/Emulator/Cores/${target_platform%%-*}-properties.csproj"
cp "$PROP_FILE" "$OUTPUT_DIRECTORY/properties.csproj"

# build
function build_args_helper() {
    local retStr=""
    for p in "$@" ; do
        retStr="${retStr} -$p"
    done
    echo ${retStr}
}

eval "dotnet build \
  -p:GUI_DISABLED=true \
  -p:Configuration=ReleaseHeadless \
  -p:GenerateFullPaths=true \
  -p:Platform=\"Any CPU\" \
  ${SRC_DIR}/Renode_NET.sln"
echo -n "dotnet" > "${SRC_DIR}/output/bin/Release/build_type"

# copy llvm library
LLVM_LIB="libllvm-disas"
# Re-evaluate when building the linux-aarch64 and osx-arm64
# if [[ $HOST_ARCH == "aarch64" ]]; then
#   # aarch64 host binaries have a different name
#   LLVM_LIB="libllvm-disas-aarch64"
# fi
cp lib/resources/llvm/$LLVM_LIB.$SHLIB_EXT ${SRC_DIR}/output/bin/Release/libllvm-disas.$SHLIB_EXT
