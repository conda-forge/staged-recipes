#!/usr/bin/env bash
# Usage: build.sh <opam-package-name>
# Builds and installs a Jane Street dune package into the conda lib/ocaml tree.
# base runs dune-configurator's discover.exe during the build, so a C compiler must be active.
set -euxo pipefail

# dune's shared cache breaks on non-unix (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

pkg="$1"

if [[ "${OSTYPE:-}" == "msys" || "${OSTYPE:-}" == "cygwin" || "${target_platform:-}" == win-* ]]; then
  prefix="${PREFIX}/Library"
  sep=';'
else
  prefix="${PREFIX}"
  sep=':'
fi

# Host libs (dune-configurator, sexplib0, ...) live in ${prefix}/lib/ocaml; non-unix activation only lists BUILD_PREFIX.
export OCAMLPATH="${prefix}/lib/ocaml${OCAMLPATH:+${sep}${OCAMLPATH}}"

dune build -p "${pkg}" --profile=release -j "${CPU_COUNT:-1}" @install
dune install -p "${pkg}" --prefix="${prefix}" \
  --libdir="${prefix}/lib/ocaml" \
  --docdir="${prefix}/share/doc" \
  --mandir="${prefix}/share/man"
