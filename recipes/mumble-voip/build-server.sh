#!/bin/bash
# Build script for mumble-server
# See: https://github.com/mumble-voip/mumble/blob/master/docs/dev/build-instructions/build_linux.md
set -exo pipefail

cd "${SRC_DIR}/src/mumble"

# Copy CMake config files provided alongside the recipe
cp "${SRC_DIR}/cmake-config/cmake_system_libs.cmake" .
cp "${SRC_DIR}/cmake-config/conda_toolchain.cmake" .

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

CMAKE_ARGS=(
    -B build
    -G Ninja
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_CXX_STANDARD=20
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -Doverlay=OFF
    -Dzeroconf=OFF
    -Dice=OFF
    -Dclient=OFF
    -Dserver=ON
    -DTRACY_ENABLE=OFF
    "-DCMAKE_PREFIX_PATH=${PREFIX}"
    "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
    "-DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib"
    "-DCMAKE_INSTALL_BINDIR=${PREFIX}/bin"
    "-DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include"
    -DMUMBLE_INSTALL_LIBDIR=lib/mumble
    -DMUMBLE_INSTALL_PLUGINDIR=lib/mumble/plugins
    "-DCMAKE_INCLUDE_PATH=${PREFIX}/include"
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON
    "-DCMAKE_INSTALL_RPATH=${PREFIX}/lib"
    --toolchain conda_toolchain.cmake
    -Dbundled-json=OFF
    -Dbundled-spdlog=OFF
    -Dbundled-utf8cpp=OFF
    -Dbundled-opus=OFF
    -Dbundled-ogg=OFF
    -Dbundled-sndfile=OFF
    -Dbundled-flac=OFF
    -Dbundled-vorbis=OFF
    -Dbundled-tracy=OFF
    -DTRACY_ENABLE=OFF
    -Dbundled-soci=OFF
    -Dbundled-gsl=OFF
    -Dbundled-minhook=OFF
    -Dbundled-SPSCQueue=OFF
    -Dbundled-speex=OFF
)

if [[ "$(uname)" == "Linux" ]]; then
    # speexdsp's cmake config file has a broken hardcoded include path; remove it
    # so mumble's find_pkg falls back to pkg-config which uses relocatable paths
    rm -rf "${PREFIX}/lib/cmake/speexdsp"

    export CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/tracy ${CPPFLAGS:-}"
    export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS:-}"
    SYSROOT="${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot"
    CMAKE_ARGS+=("-DCMAKE_FIND_ROOT_PATH=${PREFIX};${SYSROOT}")
    CMAKE_ARGS+=(
        "-DCMAKE_CXX_FLAGS=-Wno-error=cpp -Wno-cpp -Wno-deprecated-declarations -Wno-error=unused-parameter -Wno-error=conversion -I${PREFIX}/include/tracy"
        "-DCMAKE_C_FLAGS=-Wno-error=cpp -Wno-cpp -std=c11 -Wno-error=unused-parameter -Wno-error=conversion -I${PREFIX}/include/tracy"
        "-DOpus_ROOT=${PREFIX}"
        "-DOgg_ROOT=${PREFIX}"
        "-DSndFile_ROOT=${PREFIX}"
        "-DALSA_ROOT=${PREFIX}"
        "-DProtobuf_ROOT=${PREFIX}"
        "-Dprotobuf_DIR=${PREFIX}/lib/cmake/protobuf"
        "-DProtobuf_INCLUDE_DIR=${PREFIX}/include"
        "-DProtobuf_LIBRARY=${PREFIX}/lib/libprotobuf${SHLIB_EXT}"
        "-DProtobuf_PROTOC_EXECUTABLE=${PREFIX}/bin/protoc"
        "-DSOCI_ROOT=${PREFIX}"
        -DUSE_ALSA=ON
    )
elif [[ "$(uname)" == "Darwin" ]]; then
    CMAKE_ARGS+=(
        "-DCMAKE_CXX_FLAGS=-Wno-deprecated-declarations -D_LIBCPP_DISABLE_AVAILABILITY"
        "-DCMAKE_C_FLAGS=-Wno-deprecated-declarations -std=c11"
        "-DOpus_ROOT=${PREFIX}"
        "-DOgg_ROOT=${PREFIX}"
        "-DSndFile_ROOT=${PREFIX}"
        "-DProtobuf_ROOT=${PREFIX}"
        "-Dprotobuf_DIR=${PREFIX}/lib/cmake/protobuf"
        "-DProtobuf_INCLUDE_DIR=${PREFIX}/include"
        "-DProtobuf_LIBRARY=${PREFIX}/lib/libprotobuf${SHLIB_EXT}"
        "-DProtobuf_PROTOC_EXECUTABLE=${PREFIX}/bin/protoc"
        "-DSOCI_ROOT=${PREFIX}"
    )
fi

cmake "${CMAKE_ARGS[@]}"
cmake --build build -j "${CPU_COUNT:-4}"
cmake --install build

# Install service configuration (Linux only)
if [[ "$(uname)" == "Linux" ]]; then
    mkdir -p "${PREFIX}/etc/mumble"
    cp "${SRC_DIR}/service-config/service.yaml" "${PREFIX}/etc/mumble/service.yaml"
fi

# Install license files
mkdir -p "${PREFIX}/share/licenses/mumble-server"
cp "${SRC_DIR}/src/mumble/LICENSE" "${PREFIX}/share/licenses/mumble-server/"
if [[ -d "${SRC_DIR}/src/mumble/3rdPartyLicenses" ]]; then
    cp -r "${SRC_DIR}/src/mumble/3rdPartyLicenses" "${PREFIX}/share/licenses/mumble-server/"
fi
