#!/usr/bin/env bash
# Checks stdio is installed and that a dune project using it builds and runs.
set -euxo pipefail

# dune's shared cache breaks on non-unix (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

LIBDIR="${PREFIX}/lib/ocaml"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then LIBDIR="${PREFIX}/Library/lib/ocaml"; fi
test -f "${LIBDIR}/stdio/META"
test -f "${LIBDIR}/stdio/stdio.cmxa"
if [[ "${LIBDIR}" == */Library/lib/ocaml ]]; then sep=';'; else sep=':'; fi
export OCAMLPATH="${LIBDIR}${OCAMLPATH:+${sep}${OCAMLPATH}}"
WORK="$(mktemp -d)"
cd "${WORK}"
echo '(lang dune 3.0)' > dune-project
echo '(executable (name t) (libraries stdio))' > dune
cat > t.ml <<'EOF'
let () = Stdio.print_endline "stdio ok"
EOF
dune build --root . ./t.exe
./_build/default/t.exe
echo "OK: stdio"
