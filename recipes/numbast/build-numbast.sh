#!/bin/bash
set -exuo pipefail

pushd numbast
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_NUMBAST="${PKG_VERSION}"
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
popd
