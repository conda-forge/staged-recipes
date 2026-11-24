#!/usr/bin/env bash
# Checks base is installed and that a dune project using it builds and runs.
set -euxo pipefail

# dune's shared cache breaks on non-unix (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

LIBDIR="${PREFIX}/lib/ocaml"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then LIBDIR="${PREFIX}/Library/lib/ocaml"; fi
test -f "${LIBDIR}/base/META"
test -f "${LIBDIR}/base/base.cmxa"
if [[ "${LIBDIR}" == */Library/lib/ocaml ]]; then sep=';'; else sep=':'; fi
export OCAMLPATH="${LIBDIR}${OCAMLPATH:+${sep}${OCAMLPATH}}"
WORK="$(mktemp -d)"
cd "${WORK}"
echo '(lang dune 3.0)' > dune-project
echo '(executable (name t) (libraries base))' > dune
cat > t.ml <<'EOF'
let () =
  assert (Base.Int.popcount 7 = 3);
  print_endline (Base.String.uppercase "base ok")
EOF
dune build --root . ./t.exe
./_build/default/t.exe
echo "OK: base"
