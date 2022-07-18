#!/usr/bin/env bash
set -eux

export GOPATH="$( pwd )"

module='github.com/minio/minio'

if [[ "${target_platform}" == "win-64" ]]; then
    ext='.exe'
else
    ext=''
fi

pushd "src/${module}"
    pwd
    ls -lah
    mkdir -p ${PREFIX}/bin
    go build -o "$PREFIX/bin/minio${ext}" .    
    bash $RECIPE_DIR/build_library_licenses.sh
popd
