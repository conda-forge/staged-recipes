#!/usr/bin/env bash
# Build a PRIVATE findlib into ${SRC_DIR}/_tools (never into $PREFIX) and
# configure it to see the OCaml libraries already installed in $PREFIX.
# Meant to be sourced: it exports PATH and OCAMLFIND_CONF.
# (unix only: semgrep is not built on Windows)
set -euxo pipefail

T="${SRC_DIR}/_tools"
export OCAML_PREFIX="${PREFIX}"

if [[ ! -x "${T}/bin/ocamlfind" ]]; then
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
OCAML_STDLIB="$(ocamlc -where)"
cat > "${T}/etc/findlib.conf" <<EOF
destdir="${PREFIX}/lib/ocaml"
path="${PREFIX}/lib/ocaml:${T}/lib:${OCAML_STDLIB}"
EOF
export OCAMLFIND_CONF="${T}/etc/findlib.conf"
