#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Update CMakeLists.txt and copy license files
cp "cmake-renode-infrastructure/src/Emulator/Cores/CMakeLists.txt" "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/CMakeLists.txt"

cp cmake-tlib/CMakeLists.txt "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/tlib"
cp cmake-tlib/tcg/CMakeLists.txt "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/tlib/tcg"

cp cmake-tlib/LICENSE "${RECIPE_DIR}/tlib-LICENSE"
cp "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/tlib/softfloat-3/COPYING.txt" "${RECIPE_DIR}/softfloat-3-COPYING.txt"

export CXXFLAGS="${CXXFLAGS} -Wno-unknown-warning-option"

# Check weak implementations
pushd "${SRC_DIR}/tools/building" > /dev/null
  ./check_weak_implementations.sh
popd > /dev/null

CORES_PATH="${SRC_DIR}/src/Infrastructure/src/Emulator/Cores"
CORES=("arm.le" "arm.be" "arm64.le" "arm-m.le" "arm-m.be" "ppc.le" "ppc.be" "ppc64.le" "ppc64.be" "i386.le" "x86_64.le" "riscv.le" "riscv64.le" "sparc.le" "sparc.be" "xtensa.le")

for core_config in "${CORES[@]}"; do
    CORE="${core_config%%.*}"
    ENDIAN="${core_config##*.}"
    BITS=32
    [[ "$CORE" == *"64"* ]] && BITS=64

    CMAKE_CONF_FLAGS=(
        "-GNinja"
        "-DTARGET_ARCH=$CORE"
        "-DTARGET_WORD_SIZE=$BITS"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DCMAKE_VERBOSE_MAKEFILE=ON"
        "$CORES_PATH"
    )

    [[ "${target_platform}" == "osx-arm64" ]] && CMAKE_CONF_FLAGS+=("-DCMAKE_OSX_ARCHITECTURES=arm64" "-DHOST_ARCH=aarch64")
    [[ "$ENDIAN" == "be" ]] && CMAKE_CONF_FLAGS+=("-DTARGET_BIG_ENDIAN=1")

    CORE_DIR="$CORES_PATH/obj/Release/$CORE/$ENDIAN"
    mkdir -p "$CORE_DIR"
    pushd "$CORE_DIR" > /dev/null
        cmake "${CMAKE_CONF_FLAGS[@]}"
        cmake --build .
        mkdir -p "$CORES_PATH/bin/Release/lib"
        cp -u -v tlib/*.so "$CORES_PATH/bin/Release/lib/"
    popd > /dev/null
done

# Install to conda path
mkdir -p "${PREFIX}/lib/${PKG_NAME}"
tar -c -C "${CORES_PATH}/bin/Release/lib" . | tar -x -C "${PREFIX}/lib/${PKG_NAME}"

exit 0

