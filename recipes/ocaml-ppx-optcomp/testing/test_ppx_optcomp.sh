#!/usr/bin/env bash
# Compiles a tiny file through dune using the ppx_optcomp rewriter; the build passes only if optcomp ran.
set -euxo pipefail

# dune's shared cache breaks on non-unix (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

LIBDIR="${PREFIX}/lib/ocaml"
SEP=":"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then LIBDIR="${PREFIX}/Library/lib/ocaml"; SEP=";"; fi
test -f "${LIBDIR}/ppx_optcomp/META"
export OCAMLPATH="${LIBDIR}${OCAMLPATH:+${SEP}${OCAMLPATH}}"
WORK="$(mktemp -d)"
cd "${WORK}"
printf '(lang dune 3.0)\n' > dune-project
printf '(executable (name t) (preprocess (pps ppx_optcomp)))\n' > dune
cat > t.ml <<'EOF'
[%%if ocaml_version >= (4, 8, 0)]
let x = 1
[%%else]
let x = this_identifier_does_not_exist
[%%endif]
let () = assert (x = 1); print_endline "ppx_optcomp ok"
EOF
dune build --root . ./t.exe
./_build/default/t.exe
echo "OK: ppx_optcomp"
