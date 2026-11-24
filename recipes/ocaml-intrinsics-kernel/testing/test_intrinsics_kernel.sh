#!/usr/bin/env bash
# Checks ocaml_intrinsics_kernel is installed and that a dune project linking it (stubs included) runs.
set -euxo pipefail

# dune's shared cache breaks on non-unix (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

LIBDIR="${PREFIX}/lib/ocaml"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then LIBDIR="${PREFIX}/Library/lib/ocaml"; fi
test -f "${LIBDIR}/ocaml_intrinsics_kernel/META"
test -f "${LIBDIR}/ocaml_intrinsics_kernel/ocaml_intrinsics_kernel.cmxa"
if [[ "${LIBDIR}" == */Library/lib/ocaml ]]; then sep=';'; else sep=':'; fi
export OCAMLPATH="${LIBDIR}${OCAMLPATH:+${sep}${OCAMLPATH}}"
WORK="$(mktemp -d)"
cd "${WORK}"
echo '(lang dune 3.0)' > dune-project
# -linkall forces every module and its C stubs into the executable
echo '(executable (name t) (libraries ocaml_intrinsics_kernel) (link_flags (-linkall)))' > dune
cat > t.ml <<'EOF'
let () = print_endline "intrinsics_kernel ok"
EOF
dune build --root . ./t.exe
./_build/default/t.exe
echo "OK: ocaml_intrinsics_kernel"
