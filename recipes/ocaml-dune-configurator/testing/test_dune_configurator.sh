#!/usr/bin/env bash
# Checks dune-configurator files exist and links configurator.cmxa (+ csexp).
set -euxo pipefail
LIBDIR="${PREFIX}/lib/ocaml"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then LIBDIR="${PREFIX}/Library/lib/ocaml"; fi
d="${LIBDIR}/dune-configurator"
test -f "${d}/META"
test -f "${d}/configurator.cmxa"
test -f "${d}/configurator.cma"
ls "${d}"/*.cmi >/dev/null
WORK="$(mktemp -d)"
printf '%s\n' 'let _ = Configurator.V1.main' 'let () = print_endline "dune-configurator ok"' > "${WORK}/t.ml"
ocamlopt -linkall -I +unix -I "${LIBDIR}/csexp" -I "${d}" \
  unix.cmxa "${LIBDIR}/csexp/csexp.cmxa" "${d}/configurator.cmxa" \
  "${WORK}/t.ml" -o "${WORK}/t.exe"
"${WORK}/t.exe"
echo "OK: dune-configurator"
