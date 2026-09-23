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

# Avoid using uv for running tests
sed -e 's/^test-loadable: loadable$/test-loadable:/' \
    -e 's/uv run --managed-python --project tests pytest -vv -s -x \./python -m pytest -vvv -s -x/' \
    Makefile > Makefile.test
make -f Makefile.test test-loadable
