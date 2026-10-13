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
if [[ "${SEP}" == ";" ]]; then
  OCAML_STDLIB="${OCAML_STDLIB//\\//}"
fi
cat > "${T}/etc/findlib.conf" <<EOF
destdir="${PFXC}/lib/ocaml"
path="${PFXC}/lib/ocaml${SEP}${TC}/lib${SEP}${OCAML_STDLIB}"
EOF
export OCAMLFIND_CONF="${T}/etc/findlib.conf"

# TEMPORARY win diagnostic: show the generated findlib.conf (CRs visible)
if [[ "${SEP}" == ";" ]]; then
  echo "=== findlib.conf (win diagnostic) ==="
  cat -A "${OCAMLFIND_CONF}"
  ocamlfind printconf || true
  command -v ocamlfind || true
  env | grep -iE 'ocaml|findlib' || true
  ls "${T}/etc/findlib.conf.d" 2>&1 || true
  for d in "${PFX}/lib/ocaml" "${T}/lib" "${OCAML_STDLIB}"; do for f in "$d"/META "$d"/*/META; do [ -f "$f" ] && { echo "== $f"; head -c 64 "$f" | od -c | head -3; }; done; done || true
  head -5 "${T}/toplevel/topfind" 2>&1 || true
  ls "${T}/toplevel" "${T}/lib" "${T}/lib/ocaml" 2>&1 || true
  echo "=== ocamlbuild (win diagnostic) ==="
  command -v ocamlbuild || true
  OCB_WHERE="$(ocamlbuild -where 2>&1 | tr -d '\r')" || true
  echo "ocamlbuild -where: ${OCB_WHERE}"
  ls -la "${OCB_WHERE}" 2>&1 | head -30 || true
  ls -la "${BUILD_PREFIX}/Library/lib/ocaml/ocamlbuild" 2>&1 | head -30 || true
  ls "${BUILD_PREFIX}/Library/bin" 2>&1 | grep -i ocamlbuild || true
fi
