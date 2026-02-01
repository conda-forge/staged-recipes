#!/bin/bash
set -o errexit -o pipefail
export DISABLE_AUTOBUILD=1
export R_COMPILE_PKGS=1
export CFLAGS="${CFLAGS} -O3"
${R} CMD INSTALL --build .
