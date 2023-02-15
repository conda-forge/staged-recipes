#!/bin/bash

set -ex

case "${PKG_NAME}" in
    libadbc-driver-manager)
        export PKG_ROOT=c/driver_manager
        ;;
    libadbc-driver-flightsql)
        export CGO_ENABLED=1
        export PKG_ROOT=c/driver/flightsql
        ;;
    libadbc-driver-postgresql)
        export PKG_ROOT=c/driver/postgresql
        ;;
    libadbc-driver-sqlite)
        export PKG_ROOT=c/driver/sqlite
        ;;
    *)
        echo "Unknown package ${PKG_NAME}"
        exit 1
        ;;
esac

if [[ "${target_platform}" == "linux-aarch64" ]] ||
       [[ "${target_platform}" == "osx-arm64" ]]; then
    export GOARCH="arm64"

    # conda sets these which trip the build up
    CFLAGS="$(echo $CFLAGS | sed 's/-march=core2 //g')"
    CFLAGS="$(echo $CFLAGS | sed 's/-mtune=haswell //g')"
    CFLAGS="$(echo $CFLAGS | sed 's/-march=nocona //g')"
    CFLAGS="$(echo $CFLAGS | sed 's/-mssse3 //g')"
elif [[ "${target_platform}" == "linux-ppc64le" ]]; then
    export GOARCH="ppc64le"
else
    export GOARCH="amd64"
fi

mkdir -p "build-cpp/${PKG_NAME}"
pushd "build-cpp/${PKG_NAME}"

cmake "../../${PKG_ROOT}" \
      -G Ninja \
      -DADBC_BUILD_SHARED=ON \
      -DADBC_BUILD_STATIC=OFF \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_PREFIX_PATH="${PREFIX}"

cmake --build . --target install -j

popd
