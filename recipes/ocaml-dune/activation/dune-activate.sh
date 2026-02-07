#!/bin/bash
# Dune activation script - configure dune for OCaml convention
# - OCAMLPATH: where dune searches for packages (lib/ocaml/<package>/META)
# - OCAMLFIND_DESTDIR: where dune installs packages (lib/ocaml/)

if [[ -n "${CONDA_PREFIX:-}" ]]; then
  # Save originals for deactivation
  export _CONDA_DUNE_OCAMLPATH_BACKUP="${OCAMLPATH:-}"
  export _CONDA_DUNE_DESTDIR_BACKUP="${OCAMLFIND_DESTDIR:-}"

  # Set search path for package discovery
  export OCAMLPATH="${CONDA_PREFIX}/lib/ocaml${OCAMLPATH:+:$OCAMLPATH}"

  # Set install destination so dune installs to OCaml convention (lib/ocaml/)
  export OCAMLFIND_DESTDIR="${CONDA_PREFIX}/lib/ocaml"
fi
