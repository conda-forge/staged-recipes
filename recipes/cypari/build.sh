#!/bin/bash

set -euxo pipefail

# Upstream's setup.py expects PARI and GMP under libcache/, and runs
# build_pari.sh to download and statically build them if they are missing.
# conda-forge builds have no network and should not vendor libraries that
# already exist as packages, so point libcache at the host prefix instead.
# autogen/paths.py reads libcache/pari/{bin/gphelp,share/pari/pari.desc} and
# regenerates the bindings from the PARI actually being linked.
mkdir -p libcache
ln -sf "${PREFIX}" libcache/pari
ln -sf "${PREFIX}" libcache/gmp

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
