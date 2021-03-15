#!/usr/bin/env bash
set -ex

ls
gunzip fpm-0.1.4.f90.gz
mkdir "${PREFIX}/bin"
${FC} ${LDFLAGS} ${FFLAGS} fpm-0.1.4.f90 -o "${PREFIX}/bin/fpm"
