#!/bin/bash

set -ex

pushd "python/${PKG_NAME//-/_}"

export _ADBC_IS_CONDA=1
export SETUPTOOLS_SCM_PRETEND_VERSION=$PKG_VERSION

echo "==== INSTALL ${PKG_NAME}"
$PYTHON -m pip install . -vvv --no-deps --no-build-isolation

popd
