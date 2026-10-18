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
  # (PFXC/TC are for findlib.conf only; PFX/T stay original elsewhere)
  PFXC="${PFX//\\//}"
  TC="${T//\\//}"
else
  PFX="${PREFIX}"
  PFXC="${PFX}"
  SEP=":"
  TC="${T}"
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
    mkdir -p "${T}/toplevel"
    cp src/findlib/topfind "${T}/toplevel/topfind"
  popd
fi

export PATH="${T}/bin:${PATH}"

# Resolve from conda's OCaml tree, then the private tree (num, zarith), then the stdlib.
mkdir -p "${T}/etc" "${T}/lib"
OCAML_STDLIB="$(ocamlc -where | tr -d '\r')"
if [[ "${SEP}" == ";" ]]; then
  OCAML_STDLIB="${OCAML_STDLIB//\\//}"
fi
cat > "${T}/etc/findlib.conf" <<EOF
destdir="${PFXC}/lib/ocaml"
path="${PFXC}/lib/ocaml${SEP}${TC}/lib${SEP}${OCAML_STDLIB}"
EOF
export OCAMLFIND_CONF="${T}/etc/findlib.conf"
