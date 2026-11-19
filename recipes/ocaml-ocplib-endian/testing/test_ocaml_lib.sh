#!/usr/bin/env bash
# Checks ocplib-endian (and its bigstring sublib) are installed and linkable.
set -euxo pipefail
LIBDIR="${PREFIX}/lib/ocaml"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then LIBDIR="${PREFIX}/Library/lib/ocaml"; fi
d="${LIBDIR}/ocplib-endian"
test -f "${d}/META"
test -f "${d}/ocplib_endian.cmxa"
test -f "${d}/bigstring/ocplib_endian_bigstring.cmxa"
WORK="$(mktemp -d)"
echo 'let () = ()' > "${WORK}/t.ml"
ocamlopt -linkall -I +unix -I "${d}" -I "${d}/bigstring" unix.cmxa \
  "${d}/ocplib_endian.cmxa" "${d}/bigstring/ocplib_endian_bigstring.cmxa" \
  "${WORK}/t.ml" -o "${WORK}/t.exe"
"${WORK}/t.exe"
echo "OK: ocplib-endian"
