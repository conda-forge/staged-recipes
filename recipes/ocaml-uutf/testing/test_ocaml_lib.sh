#!/usr/bin/env bash
# Usage: test_ocaml_lib.sh <lib>... (dependencies first, tested lib last); links all with -linkall
set -euxo pipefail
LIBDIR="${PREFIX}/lib/ocaml"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then LIBDIR="${PREFIX}/Library/lib/ocaml"; fi
TESTED="${!#}"   # last argument
d="${LIBDIR}/${TESTED}"
test -f "${d}/${TESTED}.cmxa"
test -f "${d}/${TESTED}.cma"
ls "${d}"/*.cmi >/dev/null
INCLUDES=(); ARCHIVES=()
for lib in "$@"; do
  INCLUDES+=(-I "${LIBDIR}/${lib}")
  ARCHIVES+=("${LIBDIR}/${lib}/${lib}.cmxa")
done
WORK="$(mktemp -d)"
echo 'let () = ()' > "${WORK}/t.ml"
ocamlopt -linkall -I +unix "${INCLUDES[@]}" unix.cmxa "${ARCHIVES[@]}" "${WORK}/t.ml" -o "${WORK}/t.exe"
"${WORK}/t.exe"
