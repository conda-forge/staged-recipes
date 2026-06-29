#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

# `make` builds the static lib (unused here) but, as a side effect, generates the
# `src/*.h` path-stubs that the model-specific mains (cmssm.c, thdm.c, ...) #include.
# The conda toolchain is injected through the empty `CFLAGS_MP` hook (see
# build_libsuperiso.sh for why this preserves upstream's -DVERSION defines).
#
# Those stubs bake in paths to external spectrum generators (SOFTSUSY, Isajet, SuSpect,
# SPheno, NMSSMTools, 2HDMC) that the model-driver tools shell out to via system() at
# runtime. They are not added as dependencies.
#   * Only softsusy and spheno are packaged on conda-forge as of 2026-06 (isajet, suspect,
#     nmssmtools and 2hdmc are not), so most of the model drivers could not be made
#     functional regardless.
#   * Each model main calls every generator in sequence (upstream expects you to comment
#     out the ones you lack), so wiring even softsusy/spheno cleanly would mean patching
#     all nine drivers and redoing that on every release.
#   * SuperIso's core tools need no generator. The supported, generator-agnostic workflow
#     is to feed a precomputed SLHA spectrum to slha.x. The drivers keep upstream's default
#     paths and simply error if the user has not supplied a generator of their own.
make CC="${CC}" AR="${AR}" CFLAGS_MP="${CFLAGS}"

# Compile each top-level main and link it against the shared libsuperiso. VERSION/YEAR are
# read from the Makefile so the banner stays correct; the -DVERSION="v5.0" quoting is clean
# in a direct shell compile (unlike through make's FlagsForMake layer).
version="$(awk -F'= ' '/^VERSION /{print $2}' Makefile)"
year="$(awk -F'= ' '/^YEAR /{print $2}' Makefile)"

for f in *.c; do
  prog="${f%.c}"
  ${CC} ${CFLAGS} -DVERSION="\"${version}\"" -DYEAR="${year}" -c "${f}" -o "${prog}.o"
  ${CC} ${CFLAGS} ${LDFLAGS} -o "${prog}.x" "${prog}.o" -lsuperiso -lm
done

install -d "${PREFIX}/bin" "${PREFIX}/share/superiso"
install -m 0755 ./*.x "${PREFIX}/bin/"
install -m 0644 example.lha "${PREFIX}/share/superiso/"
cp -R chi2_input "${PREFIX}/share/superiso/"
