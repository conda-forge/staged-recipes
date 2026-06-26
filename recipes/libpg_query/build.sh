#!/bin/bash
set -euxo pipefail

# `make install` depends on both the static archive and the shared library, so
# this builds and installs libpg_query.{a,so/dylib} plus the public headers
# (pg_query.h, postgres_deparse.h) and the protobuf .proto under $PREFIX.
# `prefix` is a plain (overridable) variable in the upstream Makefile.
make build_shared -j"${CPU_COUNT}"
make install prefix="${PREFIX}"

# Upstream's `make install` only exposes the public API, but downstream
# consumers that wrap libpg_query's internals (e.g. pglast) compile against its
# internal header, the generated protobuf header, and the vendored PostgreSQL
# server headers. Install those too, following the layout Debian's
# libpg-query-dev package uses (headers under include/pg_query/).
incdir="${PREFIX}/include"
install -d "${incdir}/pg_query"
install -m 644 src/pg_query_internal.h "${incdir}/pg_query/pg_query_internal.h"
install -m 644 protobuf/pg_query.pb-c.h "${incdir}/pg_query/pg_query.pb-c.h"
cp -R src/postgres/include "${incdir}/pg_query/postgres"
