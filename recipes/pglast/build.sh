#!/bin/bash
set -euxo pipefail

# Devendored build: link the conda libpg_query package instead of compiling the
# bundled (empty) submodule. devendor-libpg_query.patch points parser.pyx at the
# installed pg_query/* headers and drops setup.py's bundled-make build_ext, so
# we regenerate parser.c from the patched parser.pyx here -- the committed
# parser.c still has the old vendored include paths baked in.
cython pglast/parser.pyx

# pg_query.h, pg_query/*.h and protobuf-c/protobuf-c.h live under $PREFIX/include
# (on the default search path); the vendored PostgreSQL server headers that
# libpg_query installs need an explicit include dir.
export CFLAGS="${CFLAGS:-} -I${PREFIX}/include -I${PREFIX}/include/pg_query/postgres"

$PYTHON -m pip install . --no-deps --no-build-isolation -vv
