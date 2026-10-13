#!/usr/bin/env bash
# Build a PRIVATE findlib into ${SRC_DIR}/_tools (never into $PREFIX) and
# configure it to see the OCaml libraries already installed in $PREFIX.
# Meant to be sourced: it exports PATH and OCAMLFIND_CONF.
set -euxo pipefail

T="${SRC_DIR}/_tools"

# conda-build/rattler-build: on Windows the OCaml tree lives under Library/
if [[ "${OS:-}" == "Windows_NT" || "${target_platform:-}" == win-* ]]; then
  PFX="${LIBRARY_PREFIX:-${PREFIX}/Library}"
  SEP=";"
  # findlib conf lexer rejects backslash escapes; use forward slashes
  PFX="${PFX//\\//}"
  T="${T//\\//}"
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
OCAML_STDLIB="$(ocamlc -where | tr -d '\r')"
[[ "${SEP}" == ";" ]] && OCAML_STDLIB="${OCAML_STDLIB//\\//}"
cat > "${T}/etc/findlib.conf" <<EOF
destdir="${PFX}/lib/ocaml"
path="${PFX}/lib/ocaml${SEP}${T}/lib${SEP}${OCAML_STDLIB}"
EOF
export OCAMLFIND_CONF="${T}/etc/findlib.conf"

# TEMPORARY win diagnostic: show the generated findlib.conf (CRs visible)
if [[ "${SEP}" == ";" ]]; then
  echo "=== findlib.conf (win diagnostic) ==="
  cat -A "${OCAMLFIND_CONF}"
  ocamlfind printconf || true
fi
