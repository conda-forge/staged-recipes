#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

CONFIGURATION="Release"
HOST_ARCH="i386"
CMAKE_COMMON=""

# check weak implementations of core libraries
pushd "${SRC_DIR}/tools/building" > /dev/null
  ./check_weak_implementations.sh
popd > /dev/null

# Paths for tlib
CORES_PATH="${SRC_DIR}/src/Infrastructure/src/Emulator/Cores"
CORES_BUILD_PATH="$CORES_PATH/obj/$CONFIGURATION"
CORES_BIN_PATH="$CORES_PATH/bin/$CONFIGURATION"

CMAKE_GEN="-GUnix Makefiles"

# Macos architecture flags, to make rosetta work properly
if [[ "${target_platform}" == "osx-64" ]]; then
  CMAKE_COMMON+=" -DCMAKE_OSX_ARCHITECTURES=x86_64"
fi
if [[ "${target_platform}" == "osx-arm64" ]]; then
  HOST_ARCH="aarch64"
  CMAKE_COMMON+=" -DCMAKE_OSX_ARCHITECTURES=arm64"
fi

# This list contains all cores that will be built.
# If you are adding a new core or endianness add it here to have the correct tlib built
CORES=(arm.le arm.be arm64.le arm-m.le arm-m.be ppc.le ppc.be ppc64.le ppc64.be i386.le x86_64.le riscv.le riscv64.le sparc.le sparc.be xtensa.le)

# build tlib
for core_config in "${CORES[@]}"
do
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

      cmake "$CMAKE_GEN" $CMAKE_COMMON $CMAKE_CONF_FLAGS -DHOST_ARCH=$HOST_ARCH $CORES_PATH
      cmake --build .

      CORE_BIN_DIR=$CORES_BIN_PATH/lib
      mkdir -p $CORE_BIN_DIR
      if [[ "${target_platform}" == "osx-"* ]]; then
          # macos `cp` does not have the -u flag
          cp -v tlib/*.so $CORE_BIN_DIR/
      else
          cp -u -v tlib/*.so $CORE_BIN_DIR/
      fi
    popd > /dev/null
done

exit 0
