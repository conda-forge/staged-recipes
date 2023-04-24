#!/usr/bin/env bash
set -ex

# Variables not set for MSYS2 toolchain
FC="${FC:-gfortran}"
AR="${AR:-ar}"


export FPM_FC="${FC}"
export FPM_AR="${AR}"
export FPM_LDFLAGS="${LDFLAGS}"
export FPM_FFLAGS="-fbounds-check -ffree-line-length-0 -fimplicit-none -O3 -DWITH_QP=1"
fpm build --tests
fpm test
fpm install --prefix "${PREFIX}"

