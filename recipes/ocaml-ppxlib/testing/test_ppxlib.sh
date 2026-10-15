#!/usr/bin/env bash
# Checks ppxlib files exist and links ppxlib.cmxa with its dependency chain.
set -euxo pipefail
LIBDIR="${PREFIX}/lib/ocaml"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then LIBDIR="${PREFIX}/Library/lib/ocaml"; fi
d="${LIBDIR}/ppxlib"
test -f "${d}/META"
test -f "${d}/ppxlib.cmxa"
test -f "${d}/ast/ppxlib_ast.cmxa"
test -f "${d}/astlib/astlib.cmxa"
test -f "${d}/stdppx/stdppx.cmxa"
SEP=":"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then SEP=";"; fi
export OCAMLPATH="${LIBDIR}${OCAMLPATH:+${SEP}${OCAMLPATH}}"
WORK="$(mktemp -d)"
cd "${WORK}"
printf '(lang dune 3.0)\n' > dune-project
printf '(executable (name t) (libraries ppxlib))\n' > dune
printf 'let _ = Ppxlib.Driver.register_transformation\nlet () = print_endline "ppxlib ok"\n' > t.ml
dune build --root . ./t.exe
./_build/default/t.exe
echo "OK: ppxlib"
