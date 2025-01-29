#!/usr/bin/env bash

set -u
set -e

OUTPUT_DIRECTORY="${SRC_DIR}/output"

UPDATE_SUBMODULES=false
CONFIGURATION="Release"
HEADLESS=false
NET=false
TFM="net8.0"
GENERATE_DOTNET_BUILD_TARGET=true
PARAMS=()
NET_FRAMEWORK_VER=
RID="linux-x64"
HOST_ARCH="i386"
# Common cmake flags
CMAKE_COMMON=""

function print_help() {
  echo "Usage: $0 [--no-gui] [--net] [--force-net-framework-version] [--host-arch i386|aarch64] [-- <ARGS>]"
  echo
  echo "--no-gui                          build with GUI disabled"
  echo "--force-net-framework-version     build against different version of .NET Framework than specified in the solution"
  echo "--net                             build with dotnet"
  echo "--host-arch                       build with a specific tcg host architecture (default: i386)"
  echo "<ARGS>                            arguments to pass to the build system"
}

OPTIONS=$(getopt -o vhnt: -l "no-gui,net,tlib-only,host-arch:" -n "$0" -- "$@")
eval set -- "$OPTIONS"

while true; do
  case $1 in
    --no-gui)
      HEADLESS=true
      shift
      ;;
    --net)
      NET=true
      shift
      ;;
    --host-arch)
      shift
      HOST_ARCH=$1
      shift
      ;;
    --force-net-framework-version)
      shift
      NET_FRAMEWORK_VER=p:TargetFrameworkVersion=v$1
      PARAMS+=($NET_FRAMEWORK_VER)
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      print_help
      exit 1
      ;;
  esac
done

PARAMS+=(
  # By default use CC as Compiler- and LinkerPath, and AR as ArPath
  ${CC:+"p:CompilerPath=$CC"}
  ${CC:+"p:LinkerPath=$CC"}
  ${AR:+"p:ArPath=$AR"}
  # But allow users to override it
  "$@"
)

. "${{SRC_DIR}}/tools/common.sh"

if $SKIP_FETCH
then
  echo "Skipping library fetch"
else
  "${{SRC_DIR}}"/tools/building/fetch_libraries.sh
fi

if $HEADLESS
then
    BUILD_TARGET=Headless
    PARAMS+=(p:GUI_DISABLED=true)
elif $ON_WINDOWS
then
    BUILD_TARGET=Windows
    TFM="$TFM-windows10.0.17763.0"
    RID="win-x64"
else
    BUILD_TARGET=Mono
fi

if [[ $GENERATE_DOTNET_BUILD_TARGET = true ]]; then
  if $ON_WINDOWS; then
    # CsWinRTAotOptimizerEnabled is disabled due to a bug in dotnet-sdk.
    # See: https://github.com/dotnet/sdk/issues/44026
    OS_SPECIFIC_TARGET_OPTS='<CsWinRTAotOptimizerEnabled>false</CsWinRTAotOptimizerEnabled>'
  fi
fi

cat <<EOF > "$(get_path "$PWD/Directory.Build.targets")"
<Project>
  <PropertyGroup>
    <TargetFrameworks>$TFM</TargetFrameworks>
    ${OS_SPECIFIC_TARGET_OPTS:+${OS_SPECIFIC_TARGET_OPTS}}
  </PropertyGroup>
</Project>
EOF

fi

if $NET
then
  export DOTNET_CLI_TELEMETRY_OPTOUT=1
  CS_COMPILER="dotnet build"
  TARGET="`get_path \"$PWD/Renode_NET.sln\"`"
  BUILD_TYPE="dotnet"
else
  TARGET="`get_path \"$PWD/Renode.sln\"`"
  BUILD_TYPE="mono"
fi

OUT_BIN_DIR="$(get_path "output/bin/${CONFIGURATION}")"
BUILD_TYPE_FILE=$(get_path "${OUT_BIN_DIR}/build_type")

# Verify Mono and mcs version on Linux and macOS
if ! $ON_WINDOWS && ! $NET
then
  if ! [ -x "$(command -v mcs)" ]
  then
    MINIMUM_MONO=`get_min_mono_version`
    echo "mcs not found. Renode requires Mono $MINIMUM_MONO or newer. Please refer to documentation for installation instructions. Exiting!"
    exit 1
  fi

  verify_mono_version
fi

# Copy properties file according to the running OS
mkdir -p "$OUTPUT_DIRECTORY"
if $ON_OSX
then
  PROP_FILE="${CURRENT_PATH:=.}/src/Infrastructure/src/Emulator/Cores/osx-properties.csproj"
elif $ON_LINUX
then
  PROP_FILE="${CURRENT_PATH:=.}/src/Infrastructure/src/Emulator/Cores/linux-properties.csproj"
else
  PROP_FILE="${CURRENT_PATH:=.}/src/Infrastructure/src/Emulator/Cores/windows-properties.csproj"
fi
cp "$PROP_FILE" "$OUTPUT_DIRECTORY/properties.csproj"

if ! $NET
then
  # Assets files are not deleted during `dotnet clean`, as it would confuse intellisense per comment in https://github.com/NuGet/Home/issues/7368#issuecomment-457411014,
  # but we need to delete them to build Renode again for .NETFramework since `project.assets.json` doesn't play well if project files share the same directory.
  # If `Renode_NET.sln` is picked for OmniSharp, it will trigger reanalysis of the project after removing assets files.
  # We don't remove these files as part of `clean` target, because other intermediate files are well separated between .NET and .NETFramework
  # and enforcing `clean` every time before rebuilding would slow down the build process on both frameworks.
  find ${SRC_DIR} -type f -name 'project.assets.json' -delete
fi

CORES_PATH="${SRC_DIR}/src/Infrastructure/src/Emulator/Cores"

PARAMS+=(p:Configuration=${CONFIGURATION}${BUILD_TARGET} p:GenerateFullPaths=true p:Platform="\"$BUILD_PLATFORM\"")

# build
eval "$CS_COMPILER $(build_args_helper "${PARAMS[@]}") $TARGET"
echo -n "$BUILD_TYPE" > "$BUILD_TYPE_FILE"

# copy llvm library
LLVM_LIB="libllvm-disas"
if [[ $HOST_ARCH == "aarch64" ]]; then
  # aarch64 host binaries have a different name
  LLVM_LIB="libllvm-disas-aarch64"
fi
if [[ "${DETECTED_OS}" == "windows" ]]; then
  LIB_EXT="dll"
elif [[ "${DETECTED_OS}" == "osx" ]]; then
  LIB_EXT="dylib"
else
  LIB_EXT="so"
fi
cp lib/resources/llvm/$LLVM_LIB.$LIB_EXT $OUT_BIN_DIR/libllvm-disas.$LIB_EXT
