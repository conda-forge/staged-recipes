#!/usr/bin/env bash

set -u
set -e

export PATH="${BUILD_PREFIX}/Library/mingw-w64/bin:${BUILD_PREFIX}/Library/bin:${PREFIX}/Library/bin:${PREFIX}/bin:${PATH}"
export ROOT_PATH="$SRC_DIR"

CMAKE=$(which cmake)

OUTPUT_DIRECTORY="$ROOT_PATH/output"
EXPORT_DIRECTORY=""

UPDATE_SUBMODULES=false
CONFIGURATION="Release"
BUILD_PLATFORM="Any CPU"
CLEAN=false
PACKAGES=false
NIGHTLY=false
PORTABLE=false
HEADLESS=false
SKIP_FETCH=false
TLIB_ONLY=false
TLIB_EXPORT_COMPILE_COMMANDS=false
TLIB_ARCH=""
NET=false
TFM="net8.0"
GENERATE_DOTNET_BUILD_TARGET=true
PARAMS=()
CUSTOM_PROP=
NET_FRAMEWORK_VER=
RID="linux-x64"
HOST_ARCH="i386"
# Common cmake flags
CMAKE_COMMON=""

function print_help() {
  echo "Usage: $0 [-cdvspnt] [-b properties-file.csproj] [--no-gui] [--skip-fetch] [--profile-build] [--tlib-only] [--tlib-export-compile-commands] [--tlib-arch <arch>] [--host-arch i386|aarch64] [-- <ARGS>]"
  echo
  echo "-v                                verbose output"
  echo "--no-gui                          build with GUI disabled"
  echo "--force-net-framework-version     build against different version of .NET Framework than specified in the solution"
  echo "--net                             build with dotnet"
  echo "-F                                select the target framework for which Renode should be built (default value: $TFM)"
  echo "--profile-build                   build optimized for profiling"
  echo "--tlib-only                       only build tlib"
  echo "<ARGS>                            arguments to pass to the build system"
}

while getopts "v::-:" opt
do
  case $opt in
    v)
      PARAMS+=(verbosity:detailed)
      ;;
    -)
      case $OPTARG in
        "no-gui")
          HEADLESS=true
          ;;
        "force-net-framework-version")
          shift $((OPTIND-1))
          NET_FRAMEWORK_VER=p:TargetFrameworkVersion=v$1
          PARAMS+=($NET_FRAMEWORK_VER)
          OPTIND=2
          ;;
        "net")
          NET=true
          PARAMS+=(p:NET=true)
          ;;
        "tlib-only")
          TLIB_ONLY=true
          ;;
        *)
          print_help
          exit 1
          ;;
      esac
      ;;
    \?)
      print_help
      exit 1
      ;;
  esac
done
shift "$((OPTIND-1))"
PARAMS+=(
  # By default use CC as Compiler- and LinkerPath, and AR as ArPath
  ${CC:+"p:CompilerPath=$CC"}
  ${CC:+"p:LinkerPath=$CC"}
  ${AR:+"p:ArPath=$AR"}
  # But allow users to override it
  "$@"
)

if [ -n "${PLATFORM:-}" ]
then
    echo "PLATFORM environment variable is currently set to: >>$PLATFORM<<"
    echo "This might cause problems during the build."
    echo "Please clear it with:"
    echo ""
    echo "    unset PLATFORM"
    echo ""
    echo " and run the build script again."

    exit 1
fi

# We can only update parts of this repository if Renode is built from within the git tree
if [ ! -e .git ]
then
  SKIP_FETCH=true
  UPDATE_SUBMODULES=false
fi

if $SKIP_FETCH
then
  echo "Skipping init/update of submodules"
fi

. "${ROOT_PATH}/tools/common.sh"

if $SKIP_FETCH
then
  echo "Skipping library fetch"
fi

if $HEADLESS
then
    BUILD_TARGET=Headless
    PARAMS+=(p:GUI_DISABLED=true)
fi

if [[ $GENERATE_DOTNET_BUILD_TARGET = true ]]; then
  if $ON_WINDOWS; then
    # CsWinRTAotOptimizerEnabled is disabled due to a bug in dotnet-sdk.
    # See: https://github.com/dotnet/sdk/issues/44026
    OS_SPECIFIC_TARGET_OPTS='<CsWinRTAotOptimizerEnabled>false</CsWinRTAotOptimizerEnabled>'
  fi
fi

OUT_BIN_DIR="$(get_path "output/bin/${CONFIGURATION}")"
BUILD_TYPE_FILE=$(get_path "${OUT_BIN_DIR}/build_type")

CORES_PATH="$ROOT_PATH/src/Infrastructure/src/Emulator/Cores"

# check weak implementations of core libraries
pushd "$ROOT_PATH/tools/building" > /dev/null
  ./check_weak_implementations.sh
popd > /dev/null

PARAMS+=(p:Configuration=${CONFIGURATION}${BUILD_TARGET} p:GenerateFullPaths=true p:Platform="\"$BUILD_PLATFORM\"")

# Paths for tlib
CORES_BUILD_PATH="$CORES_PATH/obj/$CONFIGURATION"
CORES_BIN_PATH="$CORES_PATH/bin/$CONFIGURATION"

# Cmake generator, handled in their own variable since the names contain spaces
CMAKE_GEN="-GNinja"

# This list contains all cores that will be built.
# If you are adding a new core or endianness add it here to have the correct tlib built
CORES=(arm.le arm.be arm64.le arm-m.le arm-m.be ppc.le ppc.be ppc64.le ppc64.be i386.le x86_64.le riscv.le riscv64.le sparc.le sparc.be xtensa.le)

# build tlib
for core_config in "${CORES[@]}"
do
    echo Building $core_config
    CORE="$(echo $core_config | cut -d '.' -f 1)"
    ENDIAN="$(echo $core_config | cut -d '.' -f 2)"
    BITS=32
    # Check if core is 64-bit
    if [[ $CORE =~ "64" ]]; then
      BITS=64
    fi
    # Core specific flags to cmake
    CMAKE_CONF_FLAGS="-DTARGET_ARCH=$CORE -DTARGET_WORD_SIZE=$BITS -DCMAKE_BUILD_TYPE=$CONFIGURATION"
    CORE_DIR=$CORES_BUILD_PATH/$CORE/$ENDIAN
    mkdir -p $CORE_DIR
    pushd "$CORE_DIR" > /dev/null
    if [[ $ENDIAN == "be" ]]; then
        CMAKE_CONF_FLAGS+=" -DTARGET_BIG_ENDIAN=1"
    fi
    if [[ "$TLIB_EXPORT_COMPILE_COMMANDS" = true ]]; then
        CMAKE_CONF_FLAGS+=" -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
    fi
    "${CMAKE}" "$CMAKE_GEN" $CMAKE_COMMON $CMAKE_CONF_FLAGS -DHOST_ARCH=$HOST_ARCH $CORES_PATH
    "${CMAKE}" --build . -j$(nproc)
    CORE_BIN_DIR=$CORES_BIN_PATH/lib
    mkdir -p $CORE_BIN_DIR
    if $ON_OSX; then
        # macos `cp` does not have the -u flag
        cp -v tlib/*.so $CORE_BIN_DIR/
    else
        cp -u -v tlib/*.so $CORE_BIN_DIR/
    fi
    # copy compile_commands.json to tlib directory
    if [[ "$TLIB_EXPORT_COMPILE_COMMANDS" = true ]]; then
       command cp -v -f $CORE_DIR/compile_commands.json $CORES_PATH/tlib/
    fi
    popd > /dev/null
done

exit 0
