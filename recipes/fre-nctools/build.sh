#!/usr/bin/env bash
set -euxo pipefail

autoreconf --install --force

bash ./configure \
    --prefix="${PREFIX}" \
    --build="${BUILD}" \
    --host="${HOST}" \
    --with-netcdf="${PREFIX}" \
    --with-netcdf-fortran="${PREFIX}" \
    --without-mpi \
    --without-fms \
    --disable-gpu

# Upstream's Fortran module dependencies are incomplete for parallel builds.
make -j1 PERL="/usr/bin/env perl"
make install PERL="/usr/bin/env perl"

for script in "${PREFIX}/bin/"*.csh; do
    sed -i.bak "1s|^#!/bin/csh|#!${PREFIX}/bin/tcsh|" "${script}"
    rm "${script}.bak"
done
