#!/usr/bin/env bash
# Build a PRIVATE findlib into ${SRC_DIR}/_tools (never into $PREFIX) and
# configure it to see the OCaml libraries already installed in $PREFIX.
# Meant to be sourced: it exports PATH and OCAMLFIND_CONF.
set -euxo pipefail

T="${SRC_DIR}/_tools"

# conda-build/rattler-build: on Windows the OCaml tree lives under Library/
if [[ "${OS:-}" == "Windows_NT" ]]; then
  PFX="${LIBRARY_PREFIX:-${PREFIX}/Library}"
  SEP=";"
else
  PFX="${PREFIX}"
  SEP=":"
fi
export OCAML_PREFIX="${PFX}"

if [[ ! -x "${T}/bin/ocamlfind" && ! -x "${T}/bin/ocamlfind.exe" ]]; then
  pushd "${SRC_DIR}/findlib"
    ./configure \
      -bindir "${T}/bin" \
      -sitelib "${T}/lib" \
      -mandir "${T}/man" \
      -config "${T}/etc/findlib.conf" \
      -no-custom \
      -no-topfind
    make all
    make opt
    make install
    # Copy topfind into private tree. topkg's pkg.ml does `#use "topfind"`,
    # so we must provide it without installing it into $PREFIX/lib/ocaml.
    mkdir -p "${T}/toplevel"
    cp src/findlib/topfind "${T}/toplevel/topfind"
  popd
fi

export PATH="${T}/bin:${PATH}"

# Install into / resolve from conda's OCaml tree, then the private findlib
# tree (so `#require "findlib"` style lookups still work), then the stdlib.
mkdir -p "${T}/etc"
cat > "${T}/etc/findlib.conf" <<EOF
destdir="${PFX}/lib/ocaml"
path="${PFX}/lib/ocaml${SEP}${T}/lib${SEP}$(ocamlc -where)"
EOF
export OCAMLFIND_CONF="${T}/etc/findlib.conf"
