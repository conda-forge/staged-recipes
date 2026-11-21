#!/usr/bin/env bash
# Usage: build.sh <opam package>
set -euxo pipefail

# dune's shared cache breaks on non-unix (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

pkg="$1"

if [[ "${target_platform:-}" == win-* ]]; then
  prefix="${PREFIX}/Library"
  sep=';'
else
  prefix="${PREFIX}"
  sep=':'
fi
# Host libs live in ${prefix}/lib/ocaml; non-unix activation only lists BUILD_PREFIX.
export OCAMLPATH="${prefix}/lib/ocaml${OCAMLPATH:+${sep}${OCAMLPATH}}"

dune build -p "${pkg}" --profile=release -j "${CPU_COUNT:-1}" @install
dune install "${pkg}" --prefix="${prefix}" \
  --libdir="${prefix}/lib/ocaml" \
  --docdir="${prefix}/share/doc" \
  --mandir="${prefix}/share/man"
