#!/usr/bin/env bash
# Compiles a program to WebAssembly with wasm_of_ocaml and runs it under node.
set -euxo pipefail

# dune's shared cache breaks on non-unix (mkdir_p on a mixed-slash cache root)
export DUNE_CACHE=disabled
# non-unix activation does not put ${PREFIX}/Library/lib/ocaml on OCAMLPATH
if [[ -d "${PREFIX}/Library/lib/ocaml" ]]; then
  export OCAMLPATH="${PREFIX}/Library/lib/ocaml${OCAMLPATH:+;${OCAMLPATH}}"
fi

mkdir -p wasmtest && cd wasmtest
cat > dune-project <<'DUNE'
(lang dune 3.20)
DUNE
cat > dune <<'DUNE'
(executable
 (name hello)
 (modes wasm))
DUNE
cat > hello.ml <<'ML'
let () = print_endline (string_of_int (List.fold_left ( + ) 0 [ 1; 2; 3 ]))
ML
dune build --profile=release ./hello.bc.wasm.js
out="$(node _build/default/hello.bc.wasm.js)"
printf '%s\n' "${out}"
[[ "${out}" == "6" ]]
