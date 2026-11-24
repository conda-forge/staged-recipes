#!/usr/bin/env bash
# Compiles a tiny file through dune using the ppx_devtools-optcomp rewriter; build passes only if optcomp ran.
set -euxo pipefail

# dune's shared cache breaks on non-unix (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

LIBDIR="${PREFIX}/lib/ocaml"
SEP=":"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then LIBDIR="${PREFIX}/Library/lib/ocaml"; SEP=";"; fi
test -f "${LIBDIR}/ppx_devtools-optcomp/META"
export OCAMLPATH="${LIBDIR}${OCAMLPATH:+${SEP}${OCAMLPATH}}"
WORK="$(mktemp -d)"
cd "${WORK}"
printf '(lang dune 3.0)\n' > dune-project
printf '(executable (name t) (preprocess (pps ppx_devtools-optcomp)))\n' > dune
cat > t.ml <<'EOF'
let x = 1 [@@if ocaml_version >= (4, 0, 0)]
let y = this_identifier_does_not_exist [@@if ocaml_version < (4, 0, 0)]
let () = ignore x
EOF
dune build --root . ./t.exe
./_build/default/t.exe
echo "OK: ppx_devtools-optcomp"
