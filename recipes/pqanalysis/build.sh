#!/bin/bash
set -euxo pipefail

# The PyPI sdist has no .git, so tell setuptools_scm the version explicitly.
export SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}"

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
