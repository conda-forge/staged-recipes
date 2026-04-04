#!/bin/bash
# Build script for mumble-client
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
    -Dspeechd=OFF
    -Doverlay=OFF
    -Doverlay-xcompile=OFF
    -Dzeroconf=OFF
    -Dcelt=OFF
    -Dice=OFF
    -Dclient=ON
    -Dserver=OFF
    "-DCMAKE_PREFIX_PATH=${PREFIX}"
    "-DBOOST_ROOT=${PREFIX}"
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
    -Dbundled-gsl=OFF
    -Dbundled-minhook=OFF
    -Dbundled-SPSCQueue=OFF
    -Dbundled-speex=OFF
    -Dbundled-renamenoise=OFF
    -DTRACY_ENABLE=OFF
)

if [[ "$(uname)" == "Linux" ]]; then
    # speexdsp's cmake config file has a broken hardcoded include path; remove it
    # so mumble's find_pkg falls back to pkg-config which uses relocatable paths
    rm -rf "${PREFIX}/lib/cmake/speexdsp"

    export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS:-}"
    export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS:-}"
    # Include sysroot in library search so cmake can find system libs like librt
    SYSROOT="${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot"
    CMAKE_ARGS+=("-DCMAKE_FIND_ROOT_PATH=${PREFIX};${SYSROOT}")
    CMAKE_ARGS+=(
        "-DCMAKE_CXX_FLAGS=-Wno-error=cpp -Wno-cpp -Wno-deprecated-declarations"
        "-DCMAKE_C_FLAGS=-Wno-error=cpp -Wno-cpp -std=c11"
        "-DX11_INCLUDE_DIR=${PREFIX}/include"
        "-DX11_LIBRARIES=${PREFIX}/lib/libX11${SHLIB_EXT};${PREFIX}/lib/libXext${SHLIB_EXT};${PREFIX}/lib/libXi${SHLIB_EXT}"
        "-DOpus_ROOT=${PREFIX}"
        "-DOgg_ROOT=${PREFIX}"
        "-DSndFile_ROOT=${PREFIX}"
        "-DALSA_ROOT=${PREFIX}"
        "-DProtobuf_ROOT=${PREFIX}"
        # lowercase protobuf_DIR matches protobuf-config.cmake on case-sensitive filesystems
        "-Dprotobuf_DIR=${PREFIX}/lib/cmake/protobuf"
        "-DProtobuf_INCLUDE_DIR=${PREFIX}/include"
        "-DProtobuf_LIBRARY=${PREFIX}/lib/libprotobuf${SHLIB_EXT}"
        "-DProtobuf_PROTOC_EXECUTABLE=${PREFIX}/bin/protoc"
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
    )
fi

cmake "${CMAKE_ARGS[@]}"
cmake --build build -j "${CPU_COUNT:-4}"
cmake --install build

# Install license files
mkdir -p "${PREFIX}/share/licenses/mumble-client"
cp "${SRC_DIR}/src/mumble/LICENSE" "${PREFIX}/share/licenses/mumble-client/"
if [[ -d "${SRC_DIR}/src/mumble/3rdPartyLicenses" ]]; then
    cp -r "${SRC_DIR}/src/mumble/3rdPartyLicenses" "${PREFIX}/share/licenses/mumble-client/"
fi
