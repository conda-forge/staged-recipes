#!/usr/bin/env bash
# Checks lwt and lwt.unix are installed and that a dune project using them builds and runs.
set -euxo pipefail

# dune's shared cache breaks on win (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

LIBDIR="${PREFIX}/lib/ocaml"
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then LIBDIR="${PREFIX}/Library/lib/ocaml"; fi
d="${LIBDIR}/lwt"
test -f "${d}/META"
test -f "${d}/lwt.cmxa"
test -f "${d}/unix/lwt_unix.cmxa"
if [[ "${LIBDIR}" == */Library/lib/ocaml ]]; then sep=';'; else sep=':'; fi
export OCAMLPATH="${LIBDIR}${OCAMLPATH:+${sep}${OCAMLPATH}}"
WORK="$(mktemp -d)"
cd "${WORK}"
echo '(lang dune 3.0)' > dune-project
echo '(executable (name t) (libraries lwt lwt.unix))' > dune
cat > t.ml <<'EOF'
let () = Lwt_main.run Lwt.return_unit; print_endline "lwt ok"
EOF
dune build --root . ./t.exe
./_build/default/t.exe
echo "OK: lwt"
