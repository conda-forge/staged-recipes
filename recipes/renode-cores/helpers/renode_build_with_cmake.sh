#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check weak implementations of core libraries
pushd "${SRC_DIR}/tools/building" > /dev/null
  ./check_weak_implementations.sh
popd > /dev/null

# Paths for tlib
CORES_PATH="${SRC_DIR}/src/Infrastructure/src/Emulator/Cores"

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
    CMAKE_CONF_FLAGS="-DTARGET_ARCH=$CORE -DTARGET_WORD_SIZE=$BITS -DCMAKE_BUILD_TYPE=Release"
    CORE_DIR=${CORES_PATH}/obj/Release/$CORE/$ENDIAN

    mkdir -p $CORE_DIR
    pushd "$CORE_DIR" > /dev/null
      if [[ $ENDIAN == "be" ]]; then
          CMAKE_CONF_FLAGS+=" -DTARGET_BIG_ENDIAN=1"
      fi

      if [[ "${target_platform}" == "osx-arm64" ]]; then
        cmake \
          "-GUnix Makefiles" \
          -DCMAKE_OSX_ARCHITECTURES=arm64 \
          -DHOST_ARCH=aarch64 \
          $CMAKE_CONF_FLAGS \
          $CORES_PATH
      else
        cmake \
          "-GUnix Makefiles" \
          -DCMAKE_OSX_ARCHITECTURES=x86_64 \
          -DHOST_ARCH=i386 \
          $CMAKE_CONF_FLAGS \
          $CORES_PATH
      fi
      cmake --build .

      mkdir -p ${CORES_PATH}/bin/Release/lib
      cp -u -v tlib/*.so ${CORES_PATH}/bin/Release/lib/
    popd > /dev/null
done

exit 0
