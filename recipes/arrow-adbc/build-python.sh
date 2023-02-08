#!/bin/bash

set -ex

if [[ "$(uname)" = "Darwin" ]]; then
    LIB_SUFFIX="dylib"
else
    LIB_SUFFIX="so"
fi

if [[ "${PKG_NAME}" = "adbc-driver-manager" ]]; then
    pushd python/adbc_driver_manager
elif [[ "${PKG_NAME}" = "adbc-driver-postgresql" ]]; then
    pushd python/adbc_driver_postgresql
    export ADBC_POSTGRESQL_LIBRARY=$PREFIX/lib/libadbc_driver_postgresql.$LIB_SUFFIX
elif [[ "${PKG_NAME}" = "adbc-driver-sqlite" ]]; then
    pushd python/adbc_driver_sqlite
    export ADBC_SQLITE_LIBRARY=$PREFIX/lib/libadbc_driver_sqlite.$LIB_SUFFIX
else
    echo "Unknown package ${PKG_NAME}"
    exit 1
fi

export SETUPTOOLS_SCM_PRETEND_VERSION=$PKG_VERSION

echo "==== INSTALL ${PKG_NAME}"
$PYTHON -m pip install . -vvv --no-deps --no-build-isolation

popd
