#!/usr/bin/env bash
set -ex

mkdir "${PREFIX}/bin"
${FC} ${LDFLAGS} ${FFLAGS} fpm-0.1.4.f90 -o "${PREFIX}/bin/fpm"
