#!/usr/bin/env bash
set -euxo pipefail
# Force the Ninja generator: the linux images export
# CMAKE_GENERATOR="Unix Makefiles" (scikit-build-core honors it), and ninja —
# not make — is in the build dependencies.
export CMAKE_GENERATOR=Ninja
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
