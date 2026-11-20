#!/usr/bin/env bash
# Compiles a program to WebAssembly with wasm_of_ocaml and runs it under node.
set -euxo pipefail

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
