#!/usr/bin/env bash
# Usage: test_ocaml_lib.sh <lib>... (link order: dependencies first, tested lib LAST)
# Checks the tested lib's META/.cmxa/.cma/.cmi exist, then links ALL given
# archives with -linkall so every compilation unit is actually linked: a plain
# link of an empty program drops unreferenced units and would prove nothing.
set -euxo pipefail
LIBDIR="${PREFIX}/lib/ocaml"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then LIBDIR="${PREFIX}/Library/lib/ocaml"; fi
TESTED="${!#}"   # last argument
d="${LIBDIR}/${TESTED}"
test -f "${d}/META"
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
echo "OK: ${TESTED}"
