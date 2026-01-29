#!/bin/bash

set -exuo pipefail

# bun needs to be on the PATH for the scripts to work
export PATH="$(pwd)/bun.native:${PATH}"

export CMAKE_AR="$(which ${AR})"
export CMAKE_STRIP="$BUILD_PREFIX/bin/strip"

bun ./scripts/build.mjs -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_DSYMUTIL="$(which arm64-apple-darwin20.0.0-dsymutil)" -B build/release

exit 1
