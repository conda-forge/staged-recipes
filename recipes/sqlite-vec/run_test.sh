#!/usr/bin/env bash
set -euxo pipefail

# Upstream tests load dist/vec0; copy the installed package's extension there.
mkdir -p dist
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
        cp "$(cygpath -u "${PREFIX}")/Library/lib/sqlite-vec/vec0.dll" dist/
        ;;
    Darwin)
        cp "${PREFIX}/lib/sqlite-vec/vec0.dylib" dist/
        ;;
    *)
        cp "${PREFIX}/lib/sqlite-vec/vec0.so" dist/
        ;;
esac

make test-loadable
