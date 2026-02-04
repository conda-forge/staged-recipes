#!/bin/bash
# Dune deactivation script - restore original OCAMLPATH and OCAMLFIND_DESTDIR

if [[ -n "${_CONDA_DUNE_OCAMLPATH_BACKUP:-}" ]]; then
  export OCAMLPATH="${_CONDA_DUNE_OCAMLPATH_BACKUP}"
else
  unset OCAMLPATH
fi
unset _CONDA_DUNE_OCAMLPATH_BACKUP

if [[ -n "${_CONDA_DUNE_DESTDIR_BACKUP:-}" ]]; then
  export OCAMLFIND_DESTDIR="${_CONDA_DUNE_DESTDIR_BACKUP}"
else
  unset OCAMLFIND_DESTDIR
fi
unset _CONDA_DUNE_DESTDIR_BACKUP
