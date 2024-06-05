#!/bin/bash

set -ex

# Windows shell doesn't start in the source directory
cd "$SRC_DIR"

if [[ $(uname) == "Linux" || $(uname) == "Darwin" ]] && [[ "${GFORTRAN}" != "gfortran" ]]; then
	ln -s "${GFORTRAN}" "${BUILD_PREFIX}/bin/gfortran"
fi

make

mkdir -p "${PREFIX}/bin/"
cp ./dimad "${PREFIX}/bin"
ls -la "${PREFIX}/bin"
